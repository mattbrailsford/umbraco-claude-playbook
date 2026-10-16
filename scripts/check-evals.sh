#!/usr/bin/env bash
# Flags skills with no eval case. CLAUDE.md requires every skill to ship with at least one
# eval tagged with its name; this makes that rule fail loudly instead of drifting. A case
# tagged only `should-not-trigger` doesn't count: it shows when the skill stays quiet, not
# what it adds.
#
# Skills that predate the rule are listed in scripts/eval-gap-allowlist.txt. That list only
# shrinks: an entry for a skill that now has an eval, or no longer exists, is flagged too.
#
# Usage: scripts/check-evals.sh
# Exit code: 0 if every skill has an eval or is allowlisted, 1 if something needs a look.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_dir="plugins/umbraco-devkit"
skills_dir="$plugin_dir/skills"
evals_dir="$plugin_dir/evals"
allowlist="scripts/eval-gap-allowlist.txt"

# Skill names tagged on a case that isn't a should-not-trigger case, one per line.
tagged="$(grep -h '^tags:' "$evals_dir"/*/prompt.md 2>/dev/null \
  | grep -v 'should-not-trigger' \
  | sed 's/^tags:[[:space:]]*\[//; s/\].*$//' \
  | tr ',' '\n' | tr -d ' ' | sort -u || true)"

allowed="$(sed 's/#.*//' "$allowlist" | tr -d ' ' | grep -v '^$' | sort -u || true)"

problems=0
for skill_file in "$skills_dir"/*/SKILL.md; do
  name="$(basename "$(dirname "$skill_file")")"
  has_eval=0
  grep -qxF "$name" <<<"$tagged" && has_eval=1
  is_allowed=0
  grep -qxF "$name" <<<"$allowed" && is_allowed=1

  if [[ "$has_eval" -eq 0 && "$is_allowed" -eq 0 ]]; then
    problems=1
    echo "No eval: \`$name\` (add a case under $evals_dir/ tagged with its name)"
  elif [[ "$has_eval" -eq 1 && "$is_allowed" -eq 1 ]]; then
    problems=1
    echo "Has an eval now: \`$name\` (remove it from $allowlist)"
  fi
done

while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  if [[ ! -f "$skills_dir/$name/SKILL.md" ]]; then
    problems=1
    echo "Not a skill: \`$name\` (remove it from $allowlist)"
  fi
done <<<"$allowed"

if [[ "$problems" -eq 0 ]]; then
  echo "Every skill has an eval, or is on the allowlist."
  exit 0
else
  exit 1
fi
