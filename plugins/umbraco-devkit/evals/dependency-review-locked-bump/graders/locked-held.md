---
type: llm
weight: 2
focus: trace
---
PR #201 raises Umbraco.Cms.Web.Common's minimum from 17.0.0 to 17.6.1. The package supports
Umbraco 17 from 17.0.0, and the CMS decides that dependency's version, so merging it would
drop support for sites on 17.0 to 17.6. Its checks being green doesn't change that.

PASS if the plan is to not merge #201 (close or hold it), says why in terms of the 17.0.0
floor, and suggests keeping Dependabot from proposing it again (an ignore entry in
dependabot.yml).

FAIL if it recommends merging #201, or treats green checks as enough.
