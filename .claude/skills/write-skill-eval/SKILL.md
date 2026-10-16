---
name: write-skill-eval
description: >-
  Repo-only guide to writing an eval case for one of this devkit's skills, running it with
  and without the plugin, and proving each grader can fail before trusting its score. Use
  when the user asks to add, write, or fix an eval, test whether a skill earns its place,
  or close a gap that `scripts/check-evals.sh` reports. Not shipped with the plugin.
---

# Write a skill eval

An eval case earns its place when plain Claude fails it and the skill fixes that. Follow
the eval rules in `CLAUDE.md` ("No build, lint, or test step") throughout; this skill is the
order to apply them in.

## 1. Pick the behavior

Read the skill's `SKILL.md` and find what it adds:

- **Knowledge skill:** a fact or rule plain Claude gets wrong without it. Prefer a real bug
  that was fixed in a package; tag that case `real-bug`.
- **Workflow skill** (`feature-*`, `quick-fix`, `issue-*`, ...): a rule the skill must keep,
  such as stopping when its input is missing or never touching git.

One case tests one behavior. If you find two, write two cases.

## 2. Write the prompt

Create `plugins/umbraco-devkit/evals/<case-name>/prompt.md`. Name the case like its
neighbors: the skill's short name, then what it tests (`env-sync-access-rules`).

```markdown
---
description: <one line: what this case proves>
tags: [<skill-name>, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

<the request, as a package developer would type it>
```

- **Ask for the change, not a review.** Given a short snippet to review, plain Claude
  catches most mistakes. Review only a realistic multi-file diff, as in
  `reviewer-feature-diff`.
- **Hide the trap.** The prompt states the task, never the rule being tested. If the prompt
  names the trap, both arms pass.
- **Say what the sandbox lacks.** Git, dotnet and the network don't run in an eval. Say so
  in the prompt ("Git can't run here") so the answer doesn't stall trying.
- **Tags:** the skill's name, then `should-trigger`, `should-not-trigger`, or `workflow`.
  Add `real-bug` when it applies.

For a should-not-trigger case, write a nearby request the skill should stay out of.

## 3. Scaffold the project, if the task needs files

When the answer has to read or change code, add `fixture.sh` (bash that writes the starting
files) and a `case.yaml`:

```yaml
schema_version: "1.1"
name: <case-name>
context:
  scaffold_script: fixture.sh
```

Keep the fixture to the few files the task touches, but real enough that the trap lives in
the code, not the prompt.

## 4. Write the graders

One file per check in `graders/`. Each checks one thing and passes every valid fix, not only
the one you had in mind.

- **Did the skill load:** a `skill-fired.md`, copied from a neighbor case. Under the default
  with/without run it reports whether the skill fired and isn't scored. For a
  should-not-trigger case, use `min: 0`, `max: 0`, `arm: both`.
- **Mechanical checks:** `type: regex` or `type: file_exists`. Free and exact; prefer them
  when they're enough.
- **Judgment checks:** `type: llm` with a `PASS if ...` and a `FAIL if ...` paragraph. Use
  `focus: trace` to grade the whole answer, or `focus: {source: file, path: ...}` for one
  written file. Give the grader for the core behavior `weight: 2`.

## 5. Prove each grader can fail

Run the case once with a single run per arm:

```bash
claude plugin eval plugins/umbraco-devkit --case <case-name> --runs 1 \
  --judge-model sonnet --no-publish --scaffold
```

Drop `--scaffold` for a case with no `fixture.sh`.

- **A grader that passes without the plugin measures nothing.** Make the prompt or grader
  harder, or delete the grader.
- **If every grader passes without the plugin**, the case is too easy. Rework it in step 2.
- **Workflow cases** run with `--ablation none`, so there is no baseline. Read each grader
  against an answer that breaks the rule; if it would still pass, tighten it.

## 6. Run it properly

Run it with the default three runs per arm, Sonnet judging:

```bash
claude plugin eval plugins/umbraco-devkit --tag <skill-name> --judge-model sonnet \
  --no-publish --scaffold
```

Three runs are noisy. Don't judge a close or zero gain on one run: rerun with `--runs 6`
first.

## 7. Finish

- If the skill was on `scripts/eval-gap-allowlist.txt`, remove it.
- Run `scripts/check-evals.sh`.
- Put the with and without scores in the PR. A knowledge skill that shows no gain doesn't
  ship.
- `evals/` ships but never loads for a consumer, so a new case needs no version bump.
