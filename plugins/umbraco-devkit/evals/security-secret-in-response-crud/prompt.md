---
description: "Full CRUD API for carrier accounts that hold a client secret and webhook signing secret shown as password fields; no response may carry them."
tags: [umbraco-security, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 shipping package (`src/Umbraco.Community.Shipping`) needs the Management API
behind its new "Carrier accounts" screens: an overview table (name, carrier, account number,
sandbox or live, last updated) and an edit screen with every field, where the client secret
and webhook signing secret are password inputs. Add a controller with list, get, create,
update and delete, using `ICarrierAccountService`, with request and response models.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
