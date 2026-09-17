---
name: solid-principles
description: >-
  The five SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution,
  Interface Segregation, Dependency Inversion), grounded in Umbraco package development. Use
  when adding or reshaping a service, class, component, or interface in either layer of an
  Umbraco package, or when reviewing whether a design will hold up as the package grows. The
  principles are the same regardless of layer; this skill's references/ files carry the C# and
  Lit/TypeScript illustrations — read whichever layer the task is actually in.
---

# SOLID principles for Umbraco packages

## 🎯 Why: Design for Change

SOLID isn't a checklist to satisfy, it's five different answers to the same question: when
this changes, how big is the diff, and who else does it drag down with it? Apply whichever
principle actually shrinks the next change. Applying one that doesn't is just ceremony.

## The five principles

- **Single Responsibility** — a class (or component) should have one reason to change. The
  classic violation bundles business logic, persistence, and formatting/rendering into one
  type; split by reason to change instead.
- **Open/Closed** — open for extension, closed for modification. A package that lets
  consumers register new behavior (a collection builder on the backend, a manifest entry on
  the frontend) never needs its own source touched to support a new case.
- **Liskov Substitution** — a subtype must honor its supertype's contract everywhere the base
  type is expected. A derived type that throws where the base promised a value, or silently
  does less, breaks every caller coded against the base.
- **Interface Segregation** — don't force a consumer to implement capabilities it doesn't
  need. A fat interface discourages exactly the kind of extension a package should be
  encouraging.
- **Dependency Inversion** — depend on abstractions, not concrete implementations. High-level
  code (a service, a component) should never be welded to one concrete database client, HTTP
  client, or data source — it depends on an interface, resolved through DI or a context.

## Examples

Read whichever layer the task is in — don't load both for a single-layer change:

- **`references/csharp.md`** — all five principles, backend/C# examples.
- **`references/frontend.md`** — all five principles, Lit/TypeScript examples.
