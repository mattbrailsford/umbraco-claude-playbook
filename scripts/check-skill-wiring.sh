#!/usr/bin/env bash
# Flags skills that exist but aren't wired in: missing from the README's skill tables, or
# never referenced from an agent or another skill (an orphan nothing routes to, so the
# builder, reviewer and pipeline phases never load it). Complements check-skill-refs.sh,
# which catches the opposite: references to skills that don't exist.
#
# Usage: scripts/check-skill-wiring.sh
# Exit code: 0 if every skill is listed and referenced, 1 if something needs a look.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_dir="plugins/umbraco-claude-playbook"
skills_dir="$plugin_dir/skills"

problems=0
for skill_file in "$skills_dir"/*/SKILL.md; do
  name="$(grep -m1 '^name:' "$skill_file" | sed 's/^name:[[:space:]]*//')"
  folder="$(basename "$(dirname "$skill_file")")"

  if ! grep -qF "$skills_dir/$folder/SKILL.md" README.md; then
    problems=1
    echo "Not in README: \`$name\` (add a row linking $skills_dir/$folder/SKILL.md)"
  fi

  inbound="$(grep -rlF "\`$name\`" "$plugin_dir" --include='*.md' \
    | grep -v "^$skills_dir/$folder/" || true)"
  if [[ -z "$inbound" ]]; then
    problems=1
    echo "Orphan: \`$name\` (no agent or other skill references it; route to it from" \
      "builder, reviewer, umb-design, or a related skill)"
  fi
done

if [[ "$problems" -eq 0 ]]; then
  echo "Every skill is in the README and referenced from somewhere else."
  exit 0
else
  exit 1
fi
