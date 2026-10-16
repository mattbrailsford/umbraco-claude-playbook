---
type: llm
weight: 2
focus: trace
---
PASS if the outcome is a type where each case carries only its own data, so a consumer
can't read a response time on a failure or an error on success: an abstract record (or
class) with sealed subtypes per outcome, handled with a switch or pattern match, or an
equivalent discriminated-union shape such as OneOf.

FAIL if the outcome is one class or record with a status enum or string plus nullable
properties for every case's data (ResponseTime?, Error?), or a tuple.
