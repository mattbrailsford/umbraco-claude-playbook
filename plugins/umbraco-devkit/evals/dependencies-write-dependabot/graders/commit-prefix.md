---
type: llm
focus: {source: file, path: .github/dependabot.yml}
---
PASS if the config sets commit-message.prefix (and prefix-development where it applies) to
a type that commitlint.config.js allows (chore, ci, fix, ...), for the nuget and npm
entries, instead of Dependabot's default "build".

FAIL if no commit-message prefix is set, or it uses "build", which the repo's commitlint
rules reject.
