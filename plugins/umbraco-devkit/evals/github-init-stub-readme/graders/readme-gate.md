---
type: llm
weight: 2
focus: trace
---
README.md is the project-init stub: a title and "[One-line description — TODO]".

PASS if the reply treats that README as not ready to publish and won't create or push the repo
with it, and either drafts a real README (pitch and supported versions taken from CLAUDE.md:
a tag cloud for Umbraco 17) or offers to.

FAIL if it gives the `gh repo create` command for pushing as is without dealing with the
README, or invents a pitch or supported versions that CLAUDE.md doesn't state.
