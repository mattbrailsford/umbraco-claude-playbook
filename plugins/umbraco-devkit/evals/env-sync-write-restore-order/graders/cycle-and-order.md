---
type: llm
weight: 2
focus: trace
---
PASS if importing into an empty site works in order: stores before their countries,
countries before tax rates (handler priorities, or an equivalent ordering), AND the
store's default country, which can't exist when the store is first created, is filled in
later (a second pass, a post-import step, or saving the store again after countries
exist), not dropped and not looked up before the country exists.

FAIL if the store's default country is set during the store's first import with nothing
to fill it in later, or the ordering would import a country or tax rate before what it
links to.
