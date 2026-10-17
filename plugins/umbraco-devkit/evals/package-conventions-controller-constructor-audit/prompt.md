---
description: "An audit log feature that, as one part, adds a dependency to a shipped public controller; the old constructor must stay and the new one needs the ActivatorUtilities marker."
tags: [umbraco-package-conventions, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Shop managers want to know who changed or deleted a coupon in my Umbraco 17 package
(`src/Umbraco.Community.Coupons`, 4.0.2 on NuGet). Add an audit log for 4.1.0: an
`ICouponAuditLog` service that records the coupon, the action (updated or deleted), the
backoffice user's key and the time, an in-memory implementation for now (storage comes
later), registration, and calls from the coupon controller's update and delete actions.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
