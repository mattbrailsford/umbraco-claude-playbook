#!/usr/bin/env bash
set -euo pipefail
cat > CLAUDE.md <<'EOF'
# MyCompany.Newsletter

An Umbraco 17 package (C# plus a Lit backoffice client). Trunk branch: `main`.

## Feature workflow

Each feature gets a plan folder at `docs/plans/<feature-slug>/`, created on `main`. Closed
plans move to `docs/archive/plans/<feature-slug>/`. Ideas live in `docs/ideas/`.
EOF
mkdir -p docs/plans/subscriptions
cat > docs/plans/subscriptions/README.md <<'EOF'
# Subscriptions

Read these in order:

1. [x] [BRIEF.md](./BRIEF.md) — editors can let members subscribe to topics
2. [ ] [ARCHITECTURE.md](./ARCHITECTURE.md) — <pending>
3. [ ] [SPEC.md](./SPEC.md) — <pending>
4. [ ] [STORIES.md](./STORIES.md) — <pending>
5. [ ] [PLAN.md](./PLAN.md) — <pending>
6. [ ] [BUILD-LOG.md](./BUILD-LOG.md) — <pending>

See [DECISION-LOG.md](./DECISION-LOG.md) for why things changed along the way.
EOF
cat > docs/plans/subscriptions/BRIEF.md <<'EOF'
# Subscriptions: brief

## Problem
Members can't choose which newsletter topics they get, so they unsubscribe from everything.

## Who
Site members, and the editors who manage topics.

## Success
Unsubscribe rate drops by a third within three months of release.

## Out of scope
Paid subscriptions. Sending email (the existing sender does that).
EOF
