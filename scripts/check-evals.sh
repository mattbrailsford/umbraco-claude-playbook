#!/usr/bin/env bash
# Flags skills with no eval case. CLAUDE.md requires every skill to ship with at least one
# eval tagged with its name; this makes that rule fail loudly instead of drifting. A case
# tagged only `should-not-trigger` doesn't count: it shows when the skill stays quiet, not
# what it adds.
#
# Usage: scripts/check-evals.sh
# Exit code: 0 if every skill has an eval, 1 if something needs a look.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_dir="plugins/umbraco-devkit"
skills_dir="$plugin_dir/skills"
evals_dir="$plugin_dir/evals"

# Skill names tagged on a case that isn't a should-not-trigger case, one per line.
tagged="$(grep -h '^tags:' "$evals_dir"/*/prompt.md 2>/dev/null \
  | grep -v 'should-not-trigger' \
  | sed 's/^tags:[[:space:]]*\[//; s/\].*$//' \
  | tr ',' '\n' | tr -d ' ' | sort -u || true)"

problems=0
for skill_file in "$skills_dir"/*/SKILL.md; do
  name="$(basename "$(dirname "$skill_file")")"
  if ! grep -qxF "$name" <<<"$tagged"; then
    problems=1
    echo "No eval: \`$name\` (add a case under $evals_dir/ tagged with its name)"
  fi
done

if [[ "$problems" -eq 0 ]]; then
  echo "Every skill has an eval."
  exit 0
else
  exit 1
fi
