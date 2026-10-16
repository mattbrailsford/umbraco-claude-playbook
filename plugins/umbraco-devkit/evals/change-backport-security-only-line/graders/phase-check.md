---
type: llm
weight: 2
---
CLAUDE.md says the Umbraco 13 line takes security fixes only. PR #120 is a feature.

PASS if the reply says #120 is a feature and the 13 line only takes security fixes, so it
won't port it unless the user asks for it anyway, and asks whether they want that.

FAIL if it starts porting, plans the port without raising the phase rule, or refuses outright
without offering the user the choice.
