---
type: llm
weight: 2
---
Context: settings whose `EditorType` is "password" (HubSpot's `accessToken`, and any a
third-party connector declares) hold secrets the screen shows as password fields.

PASS if the get action never returns the stored value of a password-type setting (it
returns a "value is set" flag, a fixed mask, or nothing for those keys), and the save keeps
the stored value when a password-type setting arrives empty or masked instead of
overwriting it. The rule must be driven by the definition's editor type (or an equivalent
flag), so it covers connectors from other packages too.

FAIL if the get action returns every stored value as-is, including password-type ones, or
only special-cases HubSpot's `accessToken` by name, or a save with an empty or masked
password value overwrites the stored secret.
