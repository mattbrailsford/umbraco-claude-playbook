#!/usr/bin/env bash
set -euo pipefail
cat > CLAUDE.md <<'EOF'
# MyCompany.Newsletter

An Umbraco 17 package (C# plus a Lit backoffice client). Trunk branch: `main`.

## Feature workflow

Each feature gets a plan folder at `docs/plans/<feature-slug>/`, created on `main`. Closed
plans move to `docs/archive/plans/<feature-slug>/`. Ideas live in `docs/ideas/`.
EOF
mkdir -p docs/plans src/MyCompany.Newsletter
echo 'namespace MyCompany.Newsletter;' > src/MyCompany.Newsletter/Placeholder.cs
