---
type: llm
---
PASS if the review flags that BrandingSettingsService.SaveAsync clears the runtime cache
directly, so on a site with more than one server the other servers keep serving stale
branding until the 12-hour expiry, and suggests clearing through a cache refresher /
DistributedCache (or a shared out-of-process cache).

FAIL if the review does not raise the direct cache clear as a multi-server problem.
