#!/usr/bin/env bash
# Checks the plugin version: it's set only in plugin.json, and it was bumped if this branch
# changes anything a consumer would load (anything under the plugin folder).
# Compares against the merge base with the main branch, so run it on a feature branch.
#
# Usage: scripts/check-version.sh [base-ref]   (default base-ref: origin/main)
# Exit code: 0 if consistent, 1 if something needs a look.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

marketplace=".claude-plugin/marketplace.json"
plugin="plugins/umbraco-devkit/.claude-plugin/plugin.json"
base_ref="${1:-origin/main}"

# Claude Code reads plugin.json first and ignores a marketplace entry version, so a second
# copy can only drift. Keep the version in plugin.json alone.
extra_versions="$(jq -r '[.metadata.version, .plugins[].version] | map(select(. != null)) | length' "$marketplace")"
if [[ "$extra_versions" != "0" ]]; then
  echo "$marketplace sets a version. Remove it; the version lives only in $plugin."
  exit 1
fi

plugin_version="$(jq -r '.version' "$plugin")"

if ! base="$(git merge-base HEAD "$base_ref" 2>/dev/null)"; then
  echo "Version is set once ($plugin_version). Skipped the bump check: no $base_ref to compare with."
  exit 0
fi

# Committed and uncommitted changes since the merge base, excluding the manifest itself.
changed="$(git diff --name-only "$base" -- plugins/umbraco-devkit \
  | grep -vxF "$plugin" || true)"
# Find the manifest by name at the base, so a renamed plugin folder still compares.
base_plugin="$(git ls-tree -r --name-only "$base" -- plugins \
  | grep -m1 '/\.claude-plugin/plugin\.json$')"
base_version="$(git show "$base:$base_plugin" | jq -r '.version')"

if [[ -n "$changed" && "$plugin_version" == "$base_version" ]]; then
  echo "Shipped files changed but the version is still $plugin_version:"
  echo "$changed" | sed 's/^/    /'
  echo "Bump it in $plugin: patch for edits, minor for a new skill or agent."
  exit 1
fi

echo "Version is set once ($plugin_version) and the bump check passes."
