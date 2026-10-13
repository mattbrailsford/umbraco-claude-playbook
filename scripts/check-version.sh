#!/usr/bin/env bash
# Checks the plugin version: the three version fields agree, and the version was bumped if
# this branch changes anything a consumer would load (anything under the plugin folder).
# Compares against the merge base with the main branch, so run it on a feature branch.
#
# Usage: scripts/check-version.sh [base-ref]   (default base-ref: origin/main)
# Exit code: 0 if consistent, 1 if something needs a look.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

marketplace=".claude-plugin/marketplace.json"
plugin="plugins/umbraco-claude-playbook/.claude-plugin/plugin.json"
base_ref="${1:-origin/main}"

meta_version="$(jq -r '.metadata.version' "$marketplace")"
listed_version="$(jq -r '.plugins[0].version' "$marketplace")"
plugin_version="$(jq -r '.version' "$plugin")"

if [[ "$meta_version" != "$listed_version" || "$meta_version" != "$plugin_version" ]]; then
  echo "Version fields disagree:"
  echo "    $marketplace metadata.version:     $meta_version"
  echo "    $marketplace plugins[0].version:   $listed_version"
  echo "    $plugin version: $plugin_version"
  exit 1
fi

if ! base="$(git merge-base HEAD "$base_ref" 2>/dev/null)"; then
  echo "Version fields agree ($plugin_version). Skipped the bump check: no $base_ref to compare with."
  exit 0
fi

# Committed and uncommitted changes since the merge base, excluding the manifest itself.
changed="$(git diff --name-only "$base" -- plugins/umbraco-claude-playbook \
  | grep -vxF "$plugin" || true)"
base_version="$(git show "$base:$plugin" | jq -r '.version')"

if [[ -n "$changed" && "$plugin_version" == "$base_version" ]]; then
  echo "Shipped files changed but the version is still $plugin_version:"
  echo "$changed" | sed 's/^/    /'
  echo "Bump it in all three places: patch for edits, minor for a new skill or agent."
  exit 1
fi

echo "Version fields agree ($plugin_version) and the bump check passes."
