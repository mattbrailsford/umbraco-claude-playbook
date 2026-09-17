---
name: bdd-specs
description: >-
  Behavior-driven design: write executable specs from a feature's "## Stories & Tasks" plan
  section, structured as Feature > Scenario > Specification with exactly one logical assertion
  per test, using whichever test framework the project already has. Covers both layers a
  feature might touch — C# (xUnit + Shouldly shown as the default) and Lit/TypeScript (Web
  Test Runner + @open-wc/testing shown as the default) — the discipline is identical, only the
  syntax differs. Use when a feature's design and stories are finalized and it's time to turn
  them into a test suite, or when asked to "spec out," "write the tests first," or do BDD/TDD
  for an Umbraco feature. Dispatched by umb-plan; stops and asks if the design or stories don't
  exist yet.
---

# BDD specs

Specs are written before the `builder` subagent implements a task — see "Open question"
below if your team wants to relax that. The spec is the design artifact: it encodes the
intended behavior from the stories, fails (or is marked pending) first, and is
`umb-build-loop`'s definition of done for the task.

This skill states the discipline once and applies it to whichever layer(s) a feature actually
touches — backend (C#), frontend (Lit + TypeScript), or both. The shape (Feature > Scenario >
Specification, one assertion, happy-then-sad, pending by default, a real-entry-point spec) is
identical either way; only the syntax it's expressed in differs. Don't duplicate this
discipline into a second, stack-specific skill — extend the relevant section below instead.

## 🎯 Why: Design for Change

One assertion per Specification means a failing spec names exactly what broke. Segregating
happy path from sad path means you can change one behavior without re-reading the whole
suite. The spec suite is the change-budget for the codebase — treat generating it as
seriously as generating the code it will gate.

## Gate: require the design and the stories first

Read the feature's plan doc.

1. **`## Design`** — if it's missing, still a stub, or full of `TODO`, **stop**. Tell the
   user: "No design yet — run `umb-design` first, so specs are grounded in real extension
   points and API shapes instead of invented ones."
2. **`## Stories & Tasks`** — if it's missing, empty, or full of placeholder text, **stop**.
   Tell the user: "No stories yet — run `umb-plan` first, so specs come from real
   acceptance criteria instead of invented ones."

Do not draft design or stories yourself under this skill — that's `umb-design`'s and
`user-stories`'s job. If both gates pass, proceed.

## Which layer(s) does this feature touch?

Check `## Design`'s "Management API surface" and "Frontend components" sections:

- **Management API surface isn't "none"** → generate backend specs (see "Backend: C#" below).
- **Frontend components isn't "none"** → generate frontend specs (see "Frontend: Lit +
  TypeScript" below).
- Both present → generate both, as separate spec files in their respective projects. A story
  that spans both layers gets a spec in each — don't try to force one file to cover both.

## Hard rules (apply to every spec, either layer)

1. **Happy path first, and exhaustive.** Cover every success outcome the story implies
   before any failure case.
2. **Sad path is segregated** into its own scenario grouping, never interleaved with
   happy-path specs.
3. **Exactly one assertion per test.** No multiple assertion calls in one test, no looped
   assertions across a collection — assert on the collection shape instead (a single-item or
   count check), or split into one test per element being checked.
4. **At least one spec per feature exercises the real entry point** — for a backend story, a
   Management API controller action through an in-memory test server, or a service resolved
   from DI exactly as Umbraco's Composer would wire it up; for a frontend story, the actual
   custom element rendered and driven through its public attributes/properties/events, not an
   internal method called directly. Fakes/mocks are fine for collaborators the spec doesn't
   own; the entry point itself must be real.
5. **Match the project's existing test conventions** before inventing new ones — reuse its
   builders, fakes/mocks, and fixtures rather than writing ad hoc setup per spec.
6. **New specs are pending by default**, marked so cleanly (not failing loudly) until a
   `builder` task makes them pass.
7. Never invent acceptance criteria. If a story is underspecified, stop and send the user
   back to `user-stories` to tighten it.

---

## Backend: C#

**Detect and match the project's actual test framework and assertion library — don't import
new ones to follow this skill.** xUnit + Shouldly is shown as the default because it reads
cleanly in examples; NUnit and native `Assert.*` are equally valid real choices.

- **Test framework** — if the project uses NUnit, map the same shape onto its terms:
  `[TestFixture]` instead of a plain class, `[Test]` instead of `[Fact]`, `[SetUp]` for
  per-test arrange instead of a constructor.
- **Assertion library** — use a fluent library (Shouldly, FluentAssertions) if the project
  already has one; native assertions are fine otherwise — don't add a dependency just for
  syntax.

### The shape: Feature > Scenario > Specification

xUnit (and NUnit) don't have JavaScript's nested `describe` blocks, so the three levels need
a C# structure to map onto. Two real options — pick based on the scenario's shape, not
precedent alone:

- **Flat class, descriptive method names, grouped by region** — one test class per feature
  area, `[Fact]` methods named `Method_Scenario_ExpectedResult`. Good fit when scenarios
  share the same arrange, or the project's existing tests already look like this.
- **Nested `Given...` classes per scenario** — arrange once in the nested class's constructor
  (xUnit runs it fresh per test method), making "what does this scenario assume" a single,
  unmissable place to look. Reach for it whenever a feature has several scenarios with
  meaningfully different setups:

  ```csharp
  public class AtomicCreateOrderWithShippingProfileTests
  {
      public class GivenAValidShippingProfileAlias
      {
          public GivenAValidShippingProfileAlias() { /* arrange once, per test method */ }
          [Fact] public void CreatesTheOrder() { /* ... */ }
      }
  }
  ```

  - For **expensive** shared arrange (a real database, a `WebApplicationFactory`), use
    `IClassFixture<T>` / `ICollectionFixture<T>` instead of re-arranging per test.
  - Do **not** fall back to a private `Arrange...()` helper called at the top of every test
    method — that hides the scenario's precondition inside a method body instead of the
    constructor where it's the first thing a reader sees.

Pick whichever of the two matches (or extends) what the project's tests already look like;
don't mix both schemes in the same test class.

- **Feature** → one test class, named after the feature, e.g. `AtomicCreateOrderEntitlementsTests`.
- **Scenario** → either a `#region` grouping (flat style) or a nested `Given...` class.
- **Specification** → one `[Fact]` (or one `[Theory]` case), exactly one assertion.
- **Mocks** → use **Moq** (or the project's existing mocking library) for collaborators the
  spec doesn't own.

```csharp
// STORY-014 — Atomic create of an order with its default shipping profile
public class AtomicCreateOrderWithShippingProfileTests
{
    public class GivenAValidShippingProfileAlias
    {
        private readonly Order _order;
        private readonly ShippingProfile _shippingProfile;

        public GivenAValidShippingProfileAlias()
        {
            _shippingProfile = new ShippingProfileBuilder().WithCarrierAlias("standard-post").Build();
            _order = new OrderBuilder().WithReference("ORD-1").WithShippingProfile(_shippingProfile).Build();
        }

        [Fact]
        public void CreatesTheOrder()
        {
            _order.ShouldNotBeNull();
        }

        [Fact]
        public void LinksTheShippingProfileByAlias()
        {
            _order.ShippingProfileAlias.ShouldBe(_shippingProfile.Alias);
        }
    }

    public class GivenAShippingProfileAliasThatDoesNotExist
    {
        private readonly Mock<IShippingProfileLookup> _shippingProfileLookup = new();
        private readonly OrderService _service;

        public GivenAShippingProfileAliasThatDoesNotExist()
        {
            _shippingProfileLookup
                .Setup(x => x.FindByAliasAsync("missing"))
                .ReturnsAsync((ShippingProfile?)null);
            _service = new OrderService(_shippingProfileLookup.Object);
        }

        [Fact]
        public async Task ThrowsShippingProfileNotFoundException()
        {
            await Should.ThrowAsync<ShippingProfileNotFoundException>(
                () => _service.CreateOrderAsync(new OrderBuilder().WithShippingProfileAlias("missing").Build()));
        }
    }
}
```

**File / naming:** one test class per Feature, named for the feature, never for the story id.
Put the story id in a single comment at the top of the file — the only place it appears.

---

## Frontend: Lit + TypeScript

**Detect and match the project's actual test framework — don't import a new one to follow this
skill.** Web Test Runner + `@open-wc/testing` is shown as the default because it's the
standard, browser-based way to test real custom elements (Lit components render into actual
shadow DOM, which a DOM-shimmed runner can't always faithfully reproduce); Vitest with a
browser-mode or DOM environment is equally valid if the project already uses it. Either way,
this is component/unit-level specs — Playwright-driven end-to-end flows through a real running
backoffice are `umb-build-loop`'s "smoke the real entry point" step, a different layer, not
this skill's job.

### The shape: Feature > Scenario > Specification

Unlike C#, JavaScript test frameworks have native nested blocks, so the mapping is direct:

```ts
import { fixture, html, expect } from "@open-wc/testing";
import "./feature-card.element.js";
import type { UmbFeatureCardElement } from "./feature-card.element.js";

// STORY-014 — Feature card shows the linked shipping profile
describe("Feature: feature card", () => {
  describe("Scenario: a valid shipping profile is linked", () => {
    let el: UmbFeatureCardElement;

    beforeEach(async () => {
      el = await fixture(html`<umb-feature-card .profileAlias=${"standard-post"}></umb-feature-card>`);
    });

    it("renders the profile's alias", () => {
      expect(el.shadowRoot!.textContent).to.include("standard-post");
    });

    it("dispatches a change event when the alias updates", async () => {
      const spy = /* set up a spy/listener on el */ null;
      // ... exactly one assertion on the dispatched event
    });
  });

  describe("Scenario: no shipping profile is linked", () => {
    let el: UmbFeatureCardElement;

    beforeEach(async () => {
      el = await fixture(html`<umb-feature-card></umb-feature-card>`);
    });

    it("renders an empty-state message", () => {
      expect(el.shadowRoot!.textContent).to.include("No shipping profile");
    });
  });
});
```

- **Feature** → the outermost `describe`, titled `Feature: …`, one per file.
- **Scenario** → a nested `describe`, titled `Scenario: …`. Arrange **all** of a scenario's
  required state in a `beforeEach` — render the component with `fixture()` there, not inside
  the `it` blocks.
- **Specification** → an `it`, exactly one assertion — a real DOM/shadow-DOM assertion or a
  dispatched-event assertion, not an internal-state check that bypasses what the component
  actually renders or emits.
- **Stub collaborators at the component's real boundary** — a context or repository the
  component consumes — rather than mocking network calls inside the component itself. If the
  component consumes an Umbraco state/context observable (see the official Backoffice Skills
  plugin's `umbraco-state-management` and this playbook's `umbraco-backoffice-conventions` for
  that pattern), provide a fake context exposing the same observable shape, not a real backend
  call.
- **New specs pending by default** — `it.skip("pending implementation", () => { ... })` (Mocha
  BDD interface, which both Web Test Runner and Vitest support) until a `builder` task makes
  it pass.

**File / naming:** one spec file per Feature, kebab-case, matching the component it exercises
(e.g. `feature-card.spec.ts`), never named for the story id. Put the story id in a single
comment at the top of the file — the only place it appears.

---

## Open question: before or alongside implementation?

This skill assumes specs are written and pending before `umb-build-loop` dispatches the
`builder` for the matching task — strict TDD. Writing tests alongside the implementation
instead, with the same one-assertion/happy-then-sad rigor applied after the fact, is equally
legitimate. Confirm which stance a project wants once, early (e.g. in its `CLAUDE.md`), rather
than letting it drift task by task.
