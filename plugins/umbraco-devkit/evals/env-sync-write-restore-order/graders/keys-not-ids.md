---
type: llm
weight: 2
focus: trace
---
PASS if every link in the exported files is written as the linked entity's Key (or another
stable value like alias or ISO code), never as the integer id: Country's store, Store's
default country, and TaxRate's country. Import must turn each key back into the target
site's integer id.

FAIL if any export writes StoreId, DefaultCountryId or CountryId as the source site's
integer, or import copies such an integer straight into the target entity.
