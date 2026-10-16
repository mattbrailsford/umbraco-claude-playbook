---
type: llm
focus: trace
---
PASS if the reply asks its setup questions (repo name, public or private, license, and owner if
relevant) together in one batch, recommending MIT for the license.

FAIL if it picks visibility or license for the user without asking, or recommends a license
other than MIT without a reason.
