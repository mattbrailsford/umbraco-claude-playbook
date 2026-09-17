---
name: bdd-specs-dotnet
description: >-
  Behavior-driven design for .NET: write executable specs from a feature's "## Stories &
  Tasks" plan section, structured as Feature > Scenario > Specification with exactly one
  logical assertion per test, using whichever test framework and assertion library the
  project already has (xUnit + Shouldly is the default shown here, but the shape is what
  matters, not the library). Use when a feature's design and stories are finalized and it's
  time to turn them into a test suite, or when asked to "spec out," "write the tests first,"
  or do BDD/TDD for a .NET/Umbraco feature. Dispatched by umb-plan; stops and asks if the
  design or stories don't exist yet.
---

# BDD specs for .NET

Specs are written before the `builder` subagent implements a task — see "Open question"
below if your team wants to relax that. The spec is the design artifact: it encodes the
intended behavior from the stories, fails (or is marked pending) first, and is
`umb-build-loop`'s definition of done for the task.

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

## Test framework and assertion library: match what your project already uses

**Detect and match the project's actual test framework and assertion library — don't import
new ones to follow this skill.** xUnit + Shouldly is shown as the default because it reads
cleanly in examples; NUnit and native `Assert.*` are equally valid real choices.

- **Test framework** — if the project uses NUnit, map the same Feature/Scenario/Specification
  shape onto its terms: `[TestFixture]` instead of a plain class, `[Test]` instead of `[Fact]`,
  `[SetUp]` for per-test arrange instead of a constructor. The shape carries the discipline,
  not the framework.
- **Assertion library** — use a fluent library (Shouldly, FluentAssertions) if the project
  already has one; native assertions (`Assert.Equal`, `Assert.That`) are fine otherwise — don't
  add a dependency just for syntax. What matters is **exactly one logical assertion per
  test**, not which API expresses it.

## The shape: Feature > Scenario > Specification

xUnit (and NUnit) don't have JavaScript's nested `describe` blocks, so the three levels need
a C# structure to map onto. Two real options — pick based on the scenario's shape, not
precedent alone:

- **Flat class, descriptive method names, grouped by region** — a pattern with real
  precedent in Umbraco test suites: one test class per feature area, `[Fact]` methods
  named `Method_Scenario_ExpectedResult` (e.g. `GetProfileAsync_WithExistingId_ReturnsProfile`),
  optionally grouped under `#region` blocks for related scenarios. Good fit when scenarios
  share the same arrange, or the project's existing tests already look like this.
- **Nested `Given...` classes per scenario** — a well-established BDD technique in the xUnit
  ecosystem: arrange once in the nested class's constructor (xUnit runs it fresh per test
  method), making "what does this scenario assume" a single, unmissable place to look, and
  grouping a scenario's specifications together the way a `describe` block would. Reach for
  it whenever a feature has several scenarios with meaningfully different setups — the
  stronger choice for that case, not a fallback:

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
    `IClassFixture<T>` / `ICollectionFixture<T>` instead of re-arranging per test. Match the
    project's existing fixture conventions (e.g. an in-memory SQLite fixture for EF Core
    repository tests) rather than inventing a new one.
  - Do **not** fall back to a private `Arrange...()` helper called at the top of every test
    method — that re-runs the same arrange logic per test instead of arranging once, and
    hides the scenario's precondition inside a method body instead of the constructor where
    it's the first thing a reader sees.

Pick whichever of the two matches (or extends) what the project's tests already look like;
don't mix both schemes in the same test class.

- **Feature** → one test class, named after the feature, e.g. `AtomicCreateOrderEntitlementsTests`.
  One feature per file/class, sourced from one story. Put the story id in a single XML doc
  comment or a comment at the top of the class — that's the only place the id appears; the
  class name itself should read naturally, no `Story007` prefix.
- **Scenario** → either a `#region` grouping (flat style) or a nested `Given...` class
  (nested style) — see above.
- **Specification** → one `[Fact]` (or one `[Theory]` case), **exactly one assertion** — a
  single chain evaluating one logical outcome, in whichever library the project uses. Need to
  check a second thing → write a second `[Fact]`, don't add a second assertion to the same
  test.
- **Mocks** → use **Moq** (or the project's existing mocking library) for collaborators the
  spec doesn't own. Set them up alongside the rest of the arrange, not inline inside a test
  method.

The example below uses the nested-class style with Shouldly, since it's the more compact
illustration — swap in the flat/region style or a different assertion library to match your
own project without changing anything else about the discipline:

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

## Hard rules

1. **Happy path first, and exhaustive.** Cover every success outcome the story implies
   before any failure case.
2. **Sad path is segregated** into its own scenario grouping (a nested `Given...` class or a
   clearly-named `#region`, e.g. `GivenAConnectionAliasThatDoesNotExist`), never interleaved
   with happy-path tests.
3. **Exactly one assertion per test.** No multiple assertion calls in one `[Fact]`, no looped
   assertions across a collection — assert on the collection shape instead (a single-item or
   count check), or split into one test per element being checked.
4. **At least one spec per feature exercises the real entry point** — a Management API
   controller action through `WebApplicationFactory`/an in-memory test server, or a service
   resolved from DI exactly as Umbraco's Composer would wire it up (mirroring this project's
   own DI-resolution test pattern, if it has one) — not calling an internal method directly
   and bypassing the wiring. Moq is fine for external collaborators within that spec; the
   entry point itself must be real.
5. **Match the project's existing test conventions** before inventing new ones — reuse its
   builders (fluent test-data construction), fakes/mocks (Moq for collaborators, or the
   project's own test doubles), and fixtures (expensive shared setup via `IClassFixture`/
   `ICollectionFixture`) rather than writing ad hoc setup code per spec.
6. **New specs are pending by default.** Mark a spec `[Fact(Skip = "pending implementation")]`
   in xUnit, `[Ignore("pending implementation")]` in NUnit (or the project's equivalent
   convention if one already exists) until a `builder` task makes it pass. A spec generated by
   this skill should skip cleanly, not fail loudly, before anyone has implemented it.
7. Never invent acceptance criteria. If a story is underspecified, stop and send the user
   back to `user-stories` to tighten it.

## File / naming convention

One test class per Feature, named for the feature (e.g. `AtomicCreateOrderEntitlementsTests`),
never for the story id. Put the story id in a single comment at the top of the file — that's
the only place it appears.

## Open question: before or alongside implementation?

This skill assumes specs are written and pending before `umb-build-loop` dispatches the
`builder` for the matching task — strict TDD. Writing tests alongside the implementation
instead, with the same one-assertion/happy-then-sad rigor applied after the fact, is equally
legitimate. Confirm which stance a project wants once, early (e.g. in its `CLAUDE.md`), rather
than letting it drift task by task.
