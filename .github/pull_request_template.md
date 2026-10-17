## What this does

<!-- One or two lines. -->

## Checklist

- [ ] Skill, agent or template changed? Version bumped in `plugin.json` (patch, minor or major per CLAUDE.md).
- [ ] New or changed rule? An eval proves plain Claude fails it and the skill fixes it, with `# covers:` naming the section.
- [ ] Changed a skill's "Use when"? Its evals rerun, and it still stays quiet on its should-not-trigger cases.
- [ ] Evals run? Scores recorded (`scripts/record-eval-scores.sh`) and the report regenerated (`scripts/eval-coverage.sh`).
- [ ] New background or scope section? Italic heading (`## *Background*`), no eval needed.

## Eval scores

<!-- With / without plugin, and skill loaded, for each eval run. "None run" is fine for docs-only changes. -->
