---
type: llm
weight: 2
focus: trace
---
PASS if the change updates the uSync StoreSerializer so both TaxRegion and the store's
shipping zones are written on export and read on import, with the zones stored as zone keys
(not integer ids or embedded zone objects).

FAIL if the serializer isn't changed, or either new field is missing from the export or the
import.
