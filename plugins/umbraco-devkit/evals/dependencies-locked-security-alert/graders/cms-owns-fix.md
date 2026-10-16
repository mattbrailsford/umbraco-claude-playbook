---
type: llm
weight: 2
---
PASS if the answer explains that Microsoft.Extensions.Caching.Memory reaches sites through
Umbraco CMS (the CMS decides its version), so raising it in the package would force an
untested version onto every site on the package's CMS floor, and that the fix belongs in a
CMS patch release. It should leave the decision to the maintainer: wait for the CMS fix,
or raise the package's CMS floor once a CMS release with the fix exists.

FAIL if the answer bumps or pins Microsoft.Extensions.Caching.Memory in the package
(directly or with transitive pinning) as the fix, or recommends doing so.
