---
type: llm
---
PASS if the section names the configuration section MyPackage:SearchBoost and every
setting with its default (Enabled true, MaxBoostedResults 5 with its 1-20 range,
BoostedDocumentTypes empty, CacheDuration 10 minutes).

FAIL if any setting, default or the range is missing.
