---
type: llm
---
PASS if the migration name carries a package-specific prefix or name (for example
`AcmeReviews_InitialCreate` or `AcmeReviewsInitial`), or the answer advises using one so it
can't collide with other packages' migrations.

FAIL if the migration is just called something generic like `InitialCreate` with no
package-specific part and no such advice.
