---
type: llm
focus: trace
---
PASS if the first migration's name carries a package-specific prefix (for example
`AcmeReviews_InitialCreate` or `AcmeReviewsInitial`), so the package's migrations can't
collide with other packages' migrations.

FAIL if the migration is just called something generic like `InitialCreate` with no
package-specific part.
