#!/usr/bin/env bash
set -euo pipefail
cat > CLAUDE.md <<'EOF'
# MyCompany.Newsletter

An Umbraco 17 package (C# plus a Lit backoffice client). Trunk branch: `main`.

## Feature workflow

Each feature gets a plan folder at `docs/plans/<feature-slug>/`, created on `main`. Closed
plans move to `docs/archive/plans/<feature-slug>/`. Ideas live in `docs/ideas/`.
EOF
mkdir -p docs/ideas docs/plans
cat > docs/ideas/topic-subscriptions.md <<'EOF'
# Topic subscriptions

Members keep unsubscribing from the whole newsletter because they only care about one or two
topics. Let members pick topics (Events, Product news, Research) on their profile page, and
let editors add or retire topics in the backoffice. Retired topics stop being sent but keep
their history. Paid tiers are not part of this. Target: Umbraco 17.
EOF
