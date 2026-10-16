#!/usr/bin/env bash
set -euo pipefail
mkdir -p docs
cat > docs/v4-dev-notes.md <<'EOF'
Internal notes for the v4 upgrade doc (devs wrote these, site devs will read the doc):

- sync engine refactored to be idempotent + resumable via a checkpoint row in
  MyPackage_SyncCheckpoint. if a sync crashes it resumes from the last committed batch
  instead of restarting.
- BatchSize setting moved: was MyPackage:BatchSize, now MyPackage:Sync:BatchSize. old key
  still read in v4 with a warning in the log, removed in v5. default 500, max 5000, values
  over 5000 are clamped.
- ISyncProvider.Fetch(int page) replaced by FetchAsync(SyncCursor cursor, CancellationToken ct).
  old method marked [Obsolete], still works in v4 via a shim, removed in v5. custom providers
  should move now.
- requires Umbraco 17.2+ (we use the new IDistributedBackgroundJob overloads), was 17.0.
- the DB migration adds the checkpoint table, runs automatically on startup, takes < 1s,
  no downtime needed. can't be rolled back by downgrading the package, restore a DB backup
  instead.
- NB: it might be worth considering that sites with very large sync sets could potentially
  see the first sync after upgrade take a bit longer, as the checkpoint table gets populated
  (roughly +10% on the first run only).
EOF
