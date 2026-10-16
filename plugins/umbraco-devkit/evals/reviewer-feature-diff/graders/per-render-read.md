---
type: llm
---
PASS if the review flags SignupFormViewComponent: every front-end render loads and
deserializes all the form's steps from the database, and suggests caching the result with
clearing when steps are saved (or computing it on save).

FAIL if the review does not raise the per-render database read as a problem.
