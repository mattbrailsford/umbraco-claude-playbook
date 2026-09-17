# Frontend (Lit + TypeScript) equivalents

The same 23 patterns apply on the frontend — the "when to use" in the C# reference files
(`creational.md`, `structural.md`, `behavioral.md`) doesn't change, only the syntax does. Full
treatment for the ones that come up often in backoffice component work; a one-line pointer for
the rest rather than doubling every section for parity's sake.

## State

A component's behavior changing based on internal state, modeled as data instead of a spread
of boolean flags:

```ts
type WorkspaceViewState = { mode: "view" } | { mode: "edit"; draft: Item } | { mode: "saving" };

class UmbItemWorkspaceElement extends UmbLitElement {
  #state: WorkspaceViewState = { mode: "view" };
  #startEditing() {
    this.#state = { mode: "edit", draft: { ...this.item } };
    this.requestUpdate();
  }
}
```

## Strategy

Swap an algorithm/renderer at runtime, resolved by alias rather than a conditional on a type
field — the collection-builder-based provider model `umbraco-extensibility` describes for the
backend, expressed as an extension-registry lookup on the frontend:

```ts
const renderer = umbExtensionsRegistry.getByAlias<UmbBlockRendererApi>(block.rendererAlias);
return renderer?.render(block);
```

## Command

Encapsulate a request as an object — the basis of undo/redo in an editor:

```ts
interface UmbCommand { execute(): void; undo(): void; }

class RenameItemCommand implements UmbCommand {
  #previousName?: string;
  constructor(private item: Item, private newName: string) {}
  execute() { this.#previousName = this.item.name; this.item.name = this.newName; }
  undo() { this.item.name = this.#previousName!; }
}
```

## Composite

Treat an individual component and a group of them uniformly — the shape a nested-block or
content tree already needs:

```ts
interface UmbTreeNode { render(): TemplateResult; }

class UmbTreeItem implements UmbTreeNode {
  render() { return html`<li>${this.label}</li>`; }
}

class UmbTreeGroup implements UmbTreeNode {
  #children: UmbTreeNode[] = [];
  render() { return html`<ul>${this.#children.map((c) => c.render())}</ul>`; } // treats a
  // leaf and a group the same way — the caller never checks which one it has
}
```

## Everything else

Same "when to use" as the C# reference files; real, but less frequent in typical backoffice
component work, so a pointer instead of a full example:

- **Observer** → don't repeat it here — see `umbraco-backoffice-conventions`'s
  observable-subscription section (`this.observe()`, not raw `.subscribe()`).
- **Adapter** → wrap an incompatible third-party API or web component behind the shape your
  own code expects.
- **Facade** → one exported function/class hiding a multi-step flow (parse, validate, save)
  behind a single call.
- **Decorator** → a higher-order function wrapping a data-source method (logging, retry)
  rather than editing it; a mixin is the class-level equivalent, used sparingly.
- **Chain of Responsibility** → an ordered array of handlers tried in turn, mirroring the
  backend's collection-builder shape.
- **Template Method** → a base class extending `UmbLitElement` with a fixed lifecycle, one or
  two steps left overridable by a subclass.
- **Iterator, Builder, Factory Method, Abstract Factory, Bridge, Proxy, Mediator, Memento** —
  translate directly from the C# examples in the reference files; nothing frontend-specific
  changes the shape enough to warrant a separate illustration.
- **Flyweight, Interpreter, Visitor, Singleton, Prototype** — genuinely rare in a typical
  backoffice component. Reach for the C# reference files if the same need shows up on the
  frontend; the translation is mechanical.
