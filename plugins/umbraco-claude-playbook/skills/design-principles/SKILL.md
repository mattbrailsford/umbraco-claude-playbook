---
name: design-principles
description: >-
  Coupling and cohesion, DRY/YAGNI/KISS, the Law of Demeter, Tell-Don't-Ask, Command-Query
  Separation, and fail-fast. Horizontal principles that apply to almost any code — C# or
  Lit/TypeScript — written in an Umbraco package. Use whenever writing or reviewing
  service/class/component design, not just when a specific pattern question comes up.
---

# Design principles for Umbraco packages

## 🎯 Why: Design for Change

Every principle below is a different lens on the same goal: make the next change small and
local. Read a diff through this file the way you'd read it through a checklist — not because
every rule always applies, but because a violation is usually the first sign a change is
about to get harder than it needs to be.

## Coupling and cohesion

Low coupling: a class should need to know as little as possible about how other classes
work. High cohesion: everything inside a class should be there for the same reason. The two
pull in the same direction — a highly cohesive class naturally has fewer reasons to reach
into other classes' internals.

The concrete rule this playbook recommends as a strong default is **repositories internal to
their owning service** (see `umbraco-package-conventions`). A controller that reaches past
`ItemService` straight into `ItemRepository` is coupled to a layer it has no business knowing
exists — when that repository's shape changes, the controller breaks too, for no reason
related to what the controller actually does.

**Lit/TypeScript:** the same rule, one layer over — `umbraco-backoffice-conventions` requires
that only one layer (a data source) ever imports a generated Management API client type or
domain model past it, mapped once at that boundary. A context or component reaching straight
through to a generated type is the frontend's version of the controller-into-repository leak.

## Law of Demeter — talk to your friends, not strangers

A method should only call methods on: itself, its parameters, objects it creates, and its
own direct fields/properties. Not on the *result* of calling one of those.

```csharp
// BAD — reaches through Item to get to its Profile's Connection's ApiKey
var apiKey = item.Profile.Connection.ApiKey;

// GOOD — ask Item for what you actually need, let it delegate internally
var apiKey = item.GetApiKey();
```

The controller-reaching-into-a-repository violation above is a Law of Demeter violation too
— it's reaching through the service to get to something two hops away.

**Lit/TypeScript:**

```ts
// BAD — reaches through the context to its item's profile's connection
const apiKey = this.#context.item.profile.connection.apiKey;

// GOOD — ask the context for what you actually need
const apiKey = this.#context.getApiKey();
```

## Tell, Don't Ask

Prefer telling an object to do something over asking it for its state and then deciding what
to do with that state yourself. Asking-then-deciding usually means business logic has leaked
out of the object that owns the data:

```csharp
// BAD — asks for state, decides externally
if (connection.Status == ConnectionStatus.Expired)
{
    connection.Status = ConnectionStatus.Active;
    connection.RefreshedAt = DateTimeOffset.UtcNow;
}

// GOOD — tells the object to handle its own transition
connection.RefreshIfExpired();
```

**Lit/TypeScript:**

```ts
// BAD — asks for state, decides externally
if (connection.status === "expired") {
  connection.status = "active";
  connection.refreshedAt = new Date();
}

// GOOD — tells the object to handle its own transition
connection.refreshIfExpired();
```

## Command-Query Separation (CQS)

A method should either do something (a command, returns `void` or `Task`) or answer
something (a query, returns a value) — not both. A method that mutates state *and* returns a
meaningful value invites bugs where a caller triggers a side effect just to read a value, or
vice versa:

```csharp
// BAD — looks like a query, silently commits a mutation
public Item GetOrCreate(Guid id) { /* creates and saves if missing, returns it either way */ }

// GOOD — separate command and query, the caller controls when the side effect happens
public Task<Item?> FindAsync(Guid id);
public Task<Item> CreateAsync(Item item);
```

**Lit/TypeScript:** the `{ data, error }` return shape from `typescript-best-practices`
already enforces this — a query returns the tuple, a command returns `Promise<void>` (or a
`{ error }`-only shape). A method that both saves *and* returns the saved-or-created item
invites the same "did this just have a side effect?" ambiguity:

```ts
// BAD — looks like it might just read, silently creates if missing
async function getOrCreate(id: string): Promise<Item> { /* ... */ }

// GOOD — separate command and query
async function find(id: string): Promise<{ data?: Item; error?: string }>;
async function create(item: Item): Promise<{ data?: Item; error?: string }>;
```

## DRY, YAGNI, KISS — in tension, on purpose

- **DRY** (Don't Repeat Yourself): duplicate *knowledge*, not merely duplicate *text*. Three
  call sites that happen to look similar today but represent different business rules
  should stay three call sites — a shared abstraction built too early just couples things
  that should be free to diverge.
- **YAGNI** (You Aren't Gonna Need It): don't build the extension point, the config flag, or
  the abstract base class for a requirement that doesn't exist yet. An Umbraco package with
  one provider doesn't need a plugin system; add the collection builder when the second
  provider actually shows up.
- **KISS** (Keep It Simple): given two designs that solve the problem equally well, ship the
  one with fewer moving parts. A `switch` statement over three known cases doesn't need the
  Strategy pattern from `gof-patterns` — that's for when the set of cases is genuinely open.

These three principles argue with each other constantly (DRY wants to abstract, YAGNI says
not yet, KISS says the simplest thing might just be the duplication). When they conflict,
default to YAGNI + KISS until a second or third real case proves the abstraction earns its
keep.

**Lit/TypeScript:** the same tension, same defaults — a component rendering three known block
types with a plain conditional doesn't need a manifest-driven plugin system (YAGNI/KISS) until
a fourth, genuinely-open-ended type shows up; three components that happen to render similarly
today but represent different business concepts should stay three components (DRY is about
knowledge, not markup that merely looks alike).

## Fail fast

Validate at the boundary — the Management API request model, the public method's entry — and
throw or reject immediately with a specific, actionable message. Don't let bad input travel
three layers deep before something finally throws a generic `NullReferenceException`:

```csharp
// BAD — the null propagates until something downstream breaks confusingly
public async Task<Item> CreateAsync(ItemRequest request) =>
    await _repository.AddAsync(new Item(request.Alias!, request.Name!));

// GOOD — reject at the boundary with a message that names the actual problem
public async Task<Item> CreateAsync(ItemRequest request)
{
    if (string.IsNullOrWhiteSpace(request.Alias))
        throw new ArgumentException("Alias is required.", nameof(request));
    return await _repository.AddAsync(new Item(request.Alias, request.Name ?? request.Alias));
}
```

**Lit/TypeScript:** validate at the same kind of boundary — a repository/data-source method's
entry, or a component's public setter — and return the `{ error }` shape immediately rather
than letting bad input reach a `fetch()` call that fails with an opaque network error three
layers down:

```ts
// BAD — an empty alias reaches the network call before anything rejects it
async function create(request: ItemRequest) {
  return client.postItem({ body: { alias: request.alias, name: request.name } });
}

// GOOD — reject at the boundary with a message that names the actual problem
async function create(request: ItemRequest): Promise<{ data?: Item; error?: string }> {
  if (!request.alias?.trim()) return { error: "Alias is required." };
  return client.postItem({ body: { alias: request.alias, name: request.name ?? request.alias } });
}
```
