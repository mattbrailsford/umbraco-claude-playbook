#!/usr/bin/env bash
# Records eval scores in docs/eval-scores.json so the coverage report (scripts/eval-coverage.sh)
# can show them on GitHub. Eval results stay local (evals/results/ is gitignored); this keeps
# the latest score for each case. Run it after an eval run you want to keep, then commit.
#
# A run's score here leaves out the skill-fired grader, so with-plugin and without-plugin
# scores mean the same thing under either --ablation mode. Errored runs are left out. A run
# with no baseline arm (--ablation none) keeps the case's last recorded without-plugin score.
#
# Usage: scripts/record-eval-scores.sh [--baseline] [aggregate-result.json ...]
#        (no file: the newest run under plugins/umbraco-devkit/evals/results/)
#   --baseline  the run used an empty plugin (see "Removing a rule" in write-skill-eval), so its
#               only arm is plain Claude: record it as the without-plugin score.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

scores="docs/eval-scores.json"
results_dir="plugins/umbraco-devkit/evals/results"
baseline=false
if [[ "${1:-}" == "--baseline" ]]; then baseline=true; shift; fi

if [[ $# -eq 0 ]]; then
  newest="$(ls -d "$results_dir"/*/aggregate-result.json 2>/dev/null | sort | tail -1 || true)"
  [[ -n "$newest" ]] || { echo "No results under $results_dir" >&2; exit 1; }
  set -- "$newest"
fi

[[ -f "$scores" ]] || echo '{}' > "$scores"

for result in "$@"; do
  jq --slurpfile current "$scores" --argjson baseline "$baseline" '
    # Score of one run, without the skill-fired grader.
    def run_score: [.graders[] | select(.name != "skill-fired")] as $g
      | if ($g | length) == 0 then null
        else ([$g[] | .weight * (if .passed then 1 else 0 end)] | add)
             / ([$g[] | .weight] | add) end;
    def mean: if length == 0 then null else (add / length * 100 | round) end;
    def valid: [.[]? | select(.error == null)];

    (.startedAt[0:10]) as $date
    | $current[0] + (
        [.cases[] | (.arms.with | valid) as $with | (.arms.without | valid) as $without
         | select(($with | length) > 0)
         | ($current[0][.name] // {}) as $old
         | if $baseline then
             {key: .name, value: ($old + {
               without: ([$with[] | run_score] | map(select(. != null)) | mean),
               withoutDate: $date})}
           else
           {key: .name, value: ({
             date: $date,
             with: ([$with[] | run_score] | map(select(. != null)) | mean),
             runs: ($with | length),
             skillLoaded: ([$with[] | select(any(.graders[]; .name == "skill-fired" and .passed))] | length)
           } + (if ($without | length) > 0
                then {without: ([$without[] | run_score] | map(select(. != null)) | mean),
                      withoutDate: $date}
                else {without: $old.without, withoutDate: $old.withoutDate} end))}
           end]
        | from_entries)
  ' "$result" > "$scores.tmp"
  mv "$scores.tmp" "$scores"
  echo "Recorded $(jq '.cases | length' "$result") case(s) from $result"
done

# Keep the file sorted so diffs stay small.
jq -S . "$scores" > "$scores.tmp" && mv "$scores.tmp" "$scores"
