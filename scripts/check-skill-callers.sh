#!/usr/bin/env bash
# Flags shipped skill or agent text that changes behavior based on which skill started it
# ("if `issue-resolve` called this skill", "saying it was called from `issue-backlog`").
# CLAUDE.md's "Skills calling skills" section says behavior comes from inputs instead. The
# one allowed caller check, the standard Hand off line ("If another skill started this
# one"), names no skill, so it never matches. A real exception goes in
# skill-caller-allowlist.txt.
#
# Usage: scripts/check-skill-callers.sh
# Exit code: 0 if nothing matches, 1 if something needs a look.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_dir="plugins/umbraco-claude-playbook"
allowlist_file="scripts/skill-caller-allowlist.txt"

skill='`[a-z][a-z0-9]*(-[a-z0-9]+)*`'
patterns=(
  "called (from|by) $skill"
  "$skill (called|calls|started|starts|invoked|invokes|dispatched|dispatches|ran|runs) this (skill|agent)"
  "(when|if|once) $skill (called|calls|started|starts|invoked|invokes|dispatched|dispatches) (it|this|you)"
  "handed (over|off|back)? ?by $skill"
  "saying (it was|you were) (called|started|invoked|dispatched)"
  "tell (it|them) (who|which skill) (called|started)"
)

allow="$(mktemp)"
trap 'rm -f "$allow"' EXIT
if [[ -f "$allowlist_file" ]]; then
  sed 's/#.*$//' "$allowlist_file" | sed 's/[[:space:]]*$//' | grep -v '^[[:space:]]*$' > "$allow" || true
fi

hits="$(mktemp)"
trap 'rm -f "$allow" "$hits"' EXIT
for pattern in "${patterns[@]}"; do
  git ls-files "$plugin_dir/skills/*.md" "$plugin_dir/agents/*.md" \
    | xargs grep -niE "$pattern" >> "$hits" || true
done

found=0
while IFS= read -r hit; do
  if [[ -s "$allow" ]] && grep -qF -f "$allow" <<< "$hit"; then
    continue
  fi
  found=1
  echo "    $hit"
done < <(sort -u "$hits")

if [[ "$found" -eq 0 ]]; then
  echo "No skill changes behavior based on which skill started it."
  exit 0
else
  echo
  echo "Pass an input instead (an argument, a file section, a value), per CLAUDE.md's" \
    "\"Skills calling skills\" section. A real exception goes in $allowlist_file."
  exit 1
fi
