---
description: "Generic load/save API for connector settings whose definitions mark some fields as password editors; those values must never come back."
tags: [umbraco-security, should-trigger]
# covers: ["Secrets and sensitive configuration"]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.FormsConnect`) sends form submissions to
CRMs through connectors, and other packages can add their own. The backoffice builds each
connector's settings form from its `Settings` definitions. Add the Management API for that
screen: list the connectors, get one connector's definitions together with its current
values, and save its values. Use `ConnectorCollection` and `IConnectorSettingsStore`.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
