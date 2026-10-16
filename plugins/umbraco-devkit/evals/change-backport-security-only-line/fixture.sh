#!/usr/bin/env bash
set -euo pipefail
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.TagCloud

An Umbraco package (C# plus a Lit backoffice client).

## Version lines

| Line | Integration branch | Release branch | Phase |
|---|---|---|---|
| Umbraco 17 | `v17/dev` | `v17/main` | Active: features and fixes |
| Umbraco 13 | `v13/dev` | `v13/main` | Security fixes only, until 2026-12-14 |

## Issue tracker

- Type: GitHub Issues
- Location: this repo, `jodean/Umbraco.Community.TagCloud`
- Access: `gh`
- State labels: the defaults
EOF
cat > PR-120.json <<'EOF'
{
  "number": 120,
  "title": "feat(tag-filters): let editors hide tags by name or prefix",
  "state": "MERGED",
  "baseRefName": "v17/dev",
  "mergedAt": "2026-10-14T09:12:00Z",
  "body": "Adds TagFilterOptions (bound from TagCloud:Filters) and a TagFilter that TagCloudService applies before ordering. Closes #97."
}
EOF
cat > PR-120.diff <<'EOF'
diff --git a/src/Umbraco.Community.TagCloud/TagFilterOptions.cs b/src/Umbraco.Community.TagCloud/TagFilterOptions.cs
new file mode 100644
--- /dev/null
+++ b/src/Umbraco.Community.TagCloud/TagFilterOptions.cs
@@ -0,0 +1,7 @@
+namespace Umbraco.Community.TagCloud;
+
+public class TagFilterOptions
+{
+    public List<string> Names { get; set; } = [];
+    public List<string> Prefixes { get; set; } = [];
+}
EOF
