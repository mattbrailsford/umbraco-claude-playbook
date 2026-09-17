# BDD specs — Backend: C#

**Detect and match the project's actual test framework and assertion library — don't import
new ones to follow this skill.** xUnit + Shouldly is shown as the default because it reads
cleanly in examples; NUnit and native `Assert.*` are equally valid real choices.

- **Test framework** — if the project uses NUnit, map the same shape onto its terms:
  `[TestFixture]` instead of a plain class, `[Test]` instead of `[Fact]`, `[SetUp]` for
  per-test arrange instead of a constructor.
- **Assertion library** — use a fluent library (Shouldly, FluentAssertions) if the project
  already has one; native assertions are fine otherwise — don't add a dependency just for
  syntax.

## The shape: Feature > Scenario > Specification

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
