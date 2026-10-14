# Design principles — Lit/TypeScript examples

## Coupling and cohesion

The same rule as the backend, one layer over — `umbraco-backoffice-conventions` requires that
only one layer (a data source) ever imports a generated Management API client type or domain
model past it, mapped once at that boundary. A context or component reaching straight through
to a generated type is the frontend's version of the controller-into-repository leak.

## Law of Demeter

```ts
// BAD — reaches through the context to its item's profile's connection
const apiKey = this.#context.item.profile.connection.apiKey;

// GOOD — ask the context for what you actually need
const apiKey = this.#context.getApiKey();
```

## Tell, Don't Ask

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

The `{ data, error }` return shape from `typescript-best-practices` already enforces this — a
query returns the tuple, a command returns `Promise<void>` (or a `{ error }`-only shape). A
method that both saves *and* returns the saved-or-created item invites the same "did this just
have a side effect?" ambiguity:

```ts
// BAD — looks like it might just read, silently creates if missing
async function getOrCreate(id: string): Promise<Item> { /* ... */ }

// GOOD — separate command and query
async function find(id: string): Promise<{ data?: Item; error?: string }>;
async function create(item: Item): Promise<{ data?: Item; error?: string }>;
```

## DRY, YAGNI, KISS

The same tension, same defaults — a component rendering three known block types with a plain
conditional doesn't need a manifest-driven plugin system (YAGNI/KISS) until a fourth,
genuinely-open-ended type shows up; three components that happen to render similarly today
but represent different business concepts should stay three components (DRY is about
knowledge, not markup that merely looks alike).

## Fail fast

Validate at the same kind of boundary — a repository/data-source method's entry, or a
component's public setter — and return the `{ error }` shape immediately rather than letting
bad input reach a `fetch()` call that fails with an opaque network error three layers down:

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
