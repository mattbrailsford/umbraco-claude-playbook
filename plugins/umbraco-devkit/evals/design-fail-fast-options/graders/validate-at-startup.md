---
type: llm
weight: 2
focus: trace
---
PASS if the new settings are validated when the site starts, with a specific message per
problem: for example data annotations ([Required], [Url], [Range]) with
ValidateDataAnnotations() and ValidateOnStart(), an IValidateOptions<T> implementation
registered with ValidateOnStart(), or an explicit check in the composer that throws a
clear error naming the bad setting.

FAIL if a missing URL, empty secret, or zero/negative timeout is only discovered when a
webhook is first sent (or silently falls back to a default), with no validation at startup.
