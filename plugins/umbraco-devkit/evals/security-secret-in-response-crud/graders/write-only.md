---
type: llm
weight: 2
---
PASS if no response from the new controller carries `ClientSecret` or
`WebhookSigningSecret`: list, get, create and update responses use models without them (a
"secret is set" flag or a fixed mask is fine), and an update with an empty or masked secret
keeps the stored value instead of overwriting it.

FAIL if any action returns the `CarrierAccount` entity or a model carrying either secret's
real value (including the create or update response echoing what was saved), or an update
with an empty or masked secret overwrites the stored one.
