---
name: gof-patterns
description: >-
  All 23 Gang of Four design patterns (creational, structural, behavioral) as a fast reference
  — a one-or-two-sentence "when to use" plus a short idiomatic snippet per pattern, in both C#
  and (for the ones common in backoffice component work) Lit/TypeScript. The full examples live
  in this skill's references/ files, read on demand — only pull in the category or layer
  actually relevant to the question at hand, not all of them. Use when choosing or reviewing a
  design pattern in an Umbraco package, or answering "which pattern fits here" — not as a
  checklist to force into every class or component. For the principles that tell you a pattern
  is warranted in the first place, see `design-principles` and `solid-principles` — reach for
  this skill once a recurring shape needs a name, not before.
---

# GoF patterns for Umbraco packages

## 🎯 Why: Design for Change

Patterns are tactics, not goals. Each one is a named answer to "how do I let this vary
without editing the code that doesn't need to know it's varying." Pick the smallest pattern
that fits the variation you actually have today — an interface with one implementation is
just an interface wearing a costume. Add the pattern when a second real case shows up, not
in anticipation of one.

## Decision guide — symptom → pattern

| You are trying to… | Consider |
|---|---|
| Create objects without naming the concrete class | Factory Method, Abstract Factory |
| Build a complex object step by step | Builder |
| Copy an existing object cheaply | Prototype |
| Guarantee exactly one instance | Singleton (often just a DI `AddSingleton`) |
| Make an incompatible interface usable | Adapter |
| Vary abstraction and implementation independently | Bridge |
| Treat individual objects and groups uniformly | Composite |
| Add behavior to an object without subclassing | Decorator |
| Hide a complex subsystem behind one interface | Facade |
| Share many fine-grained objects cheaply | Flyweight |
| Control access to an object (lazy, remote, guarded) | Proxy |
| Pass a request along a series of handlers | Chain of Responsibility |
| Encapsulate a request as an object (undo, queue) | Command |
| Evaluate sentences in a small language | Interpreter |
| Traverse a collection without exposing its structure | Iterator (`IEnumerable<T>`) |
| Reduce many-to-many coupling between objects | Mediator |
| Capture and restore an object's state | Memento |
| Notify dependents of a state change | Observer |
| Change behavior when internal state changes | State |
| Swap one of several algorithms at runtime | Strategy |
| Fix an algorithm's skeleton, vary its steps | Template Method |
| Add operations to a stable type hierarchy without editing it | Visitor |

## Where the examples live

Once the decision guide points at a pattern, read only the reference file that has it — don't
load all of them for a single question:

- **`references/creational.md`** — Factory Method, Abstract Factory, Builder, Prototype,
  Singleton (C#).
- **`references/structural.md`** — Adapter, Bridge, Composite, Decorator, Facade, Flyweight,
  Proxy (C#).
- **`references/behavioral.md`** — Chain of Responsibility, Command, Interpreter, Iterator,
  Mediator, Memento, Observer, State, Strategy, Template Method, Visitor (C#).
- **`references/frontend.md`** — Lit/TypeScript treatment: full examples for State, Strategy,
  Command, and Composite (the ones that come up often in backoffice component work), and a
  one-line pointer to the C# files for the rest, since the translation is mechanical.

## Cross-cutting note

Favor `sealed` classes for pattern participants that aren't designed to be further extended
(most Decorators, Adapters, Commands) — it documents intent and closes off accidental
inheritance. This applies across every category above, which is why it's here instead of
repeated in each reference file.
