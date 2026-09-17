---
name: design-principles
description: >-
  Coupling and cohesion, DRY/YAGNI/KISS, the Law of Demeter, Tell-Don't-Ask, Command-Query
  Separation, and fail-fast. Horizontal principles that apply to almost any code — C# or
  Lit/TypeScript — written in an Umbraco package. Use whenever writing or reviewing
  service/class/component design, not just when a specific pattern question comes up. This
  skill's references/ files carry the C# and Lit/TypeScript illustrations — read whichever
  layer the task is actually in.
---

# Design principles for Umbraco packages

## 🎯 Why: Design for Change

Every principle below is a different lens on the same goal: make the next change small and
local. Read a diff through this file the way you'd read it through a checklist — not because
every rule always applies, but because a violation is usually the first sign a change is
about to get harder than it needs to be.

## The principles

- **Coupling and cohesion** — low coupling (a class needs to know as little as possible about
  how others work) and high cohesion (everything inside a class is there for the same reason)
  pull in the same direction. The concrete rule this playbook recommends: repositories
  internal to their owning service (backend), only one layer importing a generated client
  type (frontend).
- **Law of Demeter** — talk to your friends, not strangers. A method should only call methods
  on itself, its parameters, objects it creates, and its own direct fields — not on the
  *result* of calling one of those.
- **Tell, Don't Ask** — tell an object to do something rather than asking for its state and
  deciding what to do with it yourself. Asking-then-deciding usually means business logic has
  leaked out of the object that owns the data.
- **Command-Query Separation (CQS)** — a method either does something or answers something,
  not both. A method that mutates state *and* returns a meaningful value invites bugs where a
  caller triggers a side effect just to read a value.
- **DRY, YAGNI, KISS** — in tension, on purpose. DRY is about duplicated *knowledge*, not
  duplicated text. YAGNI says don't build the extension point before a second real case shows
  up. KISS says the simplest design that solves the problem wins. When they conflict, default
  to YAGNI + KISS until a second or third case proves an abstraction earns its keep.
- **Fail fast** — validate at the boundary and reject immediately with a specific, actionable
  message. Don't let bad input travel several layers deep before something finally breaks
  confusingly.

## Examples

Read whichever layer the task is in — don't load both for a single-layer change:

- **`references/csharp.md`** — all six, backend/C# examples.
- **`references/frontend.md`** — all six, Lit/TypeScript examples.
