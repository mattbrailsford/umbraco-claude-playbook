# SOLID principles — Lit/TypeScript examples

## Single Responsibility

The same violation shows up as a component that fetches its own data, validates it, *and*
renders — three reasons to change one class:

```ts
// BAD — one element, three reasons to change
class UmbItemFormElement extends UmbLitElement {
  async #save() { /* validate */ /* fetch() with hand-built request */ /* render error state */ }
}

// GOOD — split by reason to change
class UmbItemFormElement extends UmbLitElement {
  #repository = new UmbItemRepository(this); // owns the fetch
  #validator = new ItemValidator(); // owns the rules
  async #save() {
    const errors = this.#validator.validate(this.item);
    if (errors.length) return this.#showErrors(errors); // owns the rendering
    await this.#repository.save(this.item);
  }
}
```

## Open/Closed

The manifest-based extension system (see `umbraco-backoffice-conventions` and the official
Backoffice Skills plugin) *is* Open/Closed at the package level — a new block type ships as a
new manifest entry, never a change to a shared renderer:

```ts
// BAD — every new block type means editing this component's switch
render() {
  switch (this.block.alias) {
    case "hero": return this.#renderHero();
    case "gallery": return this.#renderGallery();
  }
}

// GOOD — closed to modification; a new block type registers its own manifest + element,
// this component just resolves whichever one matches
{ type: "blockEditorCustomView", alias: "MyCompany.BlockView.Hero", forContentTypeAlias: "hero", element: () => import("./hero-view.element.js") }
```

## Liskov Substitution

The same break shows up in a data-source implementing a shared repository interface:

```ts
interface UmbItemDataSource {
  get(id: string): Promise<{ data?: Item; error?: string }>;
}

// BAD — silently returns an error instead of honoring the contract callers expect
class ReadOnlyItemDataSource implements UmbItemDataSource {
  async get(id: string) {
    return this.canRead(id) ? this.#fetch(id) : { error: "not supported" }; // callers coded
    // against UmbItemDataSource don't expect a real id to just fail like this
  }
}
```

## Interface Segregation

```ts
// BAD — a read-only source is forced to implement write/delete it can't support
interface UmbItemDataSource { get(id: string): Promise<Item>; save(item: Item): Promise<void>; remove(id: string): Promise<void>; }

// GOOD — segregated by capability
interface UmbItemReadDataSource { get(id: string): Promise<Item>; }
interface UmbItemWriteDataSource { save(item: Item): Promise<void>; remove(id: string): Promise<void>; }
```

## Dependency Inversion

A component that reaches for a concrete data source directly is welded to it the same way;
depend on the Umbraco context API instead, so a test (or a future data source) can provide a
fake:

```ts
// BAD — the component is welded to this one concrete data source, untestable without a real API
class UmbItemWorkspace extends UmbLitElement {
  #dataSource = new UmbItemServerDataSource(this);
}

// GOOD — consumes a context, resolved to whatever provided it (real or a test fake)
class UmbItemWorkspace extends UmbLitElement {
  #repository?: UmbItemRepository;
  constructor() {
    super();
    this.consumeContext(UMB_ITEM_REPOSITORY_CONTEXT, (instance) => (this.#repository = instance));
  }
}
```
