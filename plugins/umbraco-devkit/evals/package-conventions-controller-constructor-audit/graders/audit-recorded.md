---
type: llm
---
PASS if both the update and delete actions record an audit entry with the coupon, the
action, the current backoffice user's key and a timestamp, and `ICouponAuditLog` is
registered in DI.

FAIL if either action doesn't record an entry, or the service isn't registered.
