---
name: gof-patterns
description: >-
  All 23 Gang of Four design patterns (creational, structural, behavioral) as a fast C#
  reference — a one-or-two-sentence "when to use" plus a short idiomatic snippet per pattern.
  Use when choosing or reviewing a design pattern in an Umbraco package, or answering "which
  pattern fits here" — not as a checklist to force into every class.
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

## Creational

Patterns that hide *how* and *when* an object gets created.

### Factory Method

Use when a class can't know in advance which concrete type it needs to create — push the
decision into an overridable creation method.

```csharp
public interface IItemClientFactory { IItemClient Create(ConnectionSettings settings); }

public class ItemClientFactory : IItemClientFactory
{
    public IItemClient Create(ConnectionSettings settings) =>
        settings.Provider switch
        {
            "vendor-a" => new VendorAClient(settings.ApiKey),
            "vendor-b" => new VendorBClient(settings.Endpoint, settings.ApiKey),
            _ => throw new NotSupportedException(settings.Provider)
        };
}
```

### Abstract Factory

Use when you need to create *families* of related objects that must stay consistent with
each other (e.g. a UI kit's button + checkbox + dialog all matching one theme).

```csharp
public interface IWidgetFactory
{
    IButton CreateButton();
    ICheckbox CreateCheckbox();
}

public class DarkThemeWidgetFactory : IWidgetFactory
{
    public IButton CreateButton() => new DarkButton();
    public ICheckbox CreateCheckbox() => new DarkCheckbox();
}
```

### Builder

Use when constructing a complex object needs many optional steps and a constructor with ten
parameters would be unreadable and error-prone.

```csharp
var request = new ItemRequestBuilder()
    .WithAlias("hero-banner")
    .WithName("Hero Banner")
    .WithProperty("title", "Welcome")
    .Build();
```

### Prototype

Use when creating a new instance is expensive or awkward compared to copying an existing,
already-configured one.

```csharp
public record ItemTemplate(string Alias, IReadOnlyDictionary<string, object?> Defaults)
{
    public ItemTemplate Clone() => this with { Defaults = new Dictionary<string, object?>(Defaults) };
}
```

### Singleton

Use when exactly one instance must exist for the app's lifetime. In a DI-based app this is
almost always `AddSingleton`, not a hand-rolled static instance:

```csharp
builder.Services.AddSingleton<IFeatureFlagCache, FeatureFlagCache>();
// reach for a hand-rolled `private static readonly Instance` only outside a DI container
```

## Structural

Patterns that compose classes and objects into larger structures without making those
structures brittle.

### Adapter

Use when you need to make an incompatible interface (usually a third-party SDK) fit the
interface your code already depends on.

```csharp
public interface IItemClient { Task<Item> GetAsync(Guid id); }

public class ThirdPartySdkAdapter : IItemClient
{
    private readonly ThirdPartySdkClient _sdk;
    public ThirdPartySdkAdapter(ThirdPartySdkClient sdk) => _sdk = sdk;
    public async Task<Item> GetAsync(Guid id) => Map(await _sdk.FetchRecordAsync(id.ToString()));
}
```

### Bridge

Use when an abstraction and its implementation both need to vary independently, and
subclassing every combination would explode the class count.

```csharp
public interface IRenderer { string Render(string content); }

public abstract class Document
{
    protected readonly IRenderer Renderer;
    protected Document(IRenderer renderer) => Renderer = renderer;
}

public class Report : Document
{
    public Report(IRenderer renderer) : base(renderer) { }
    public string Print(string body) => Renderer.Render(body); // HtmlRenderer, PdfRenderer, … vary freely
}
```

### Composite

Use when individual objects and groups of objects need to be treated identically by calling
code — a content tree is the textbook case: every node exposes the same "children"-shaped
interface regardless of depth.

```csharp
public interface IContentNode
{
    string Alias { get; }
    IEnumerable<IContentNode> Children { get; }
}

public IEnumerable<IContentNode> Flatten(IContentNode node) =>
    new[] { node }.Concat(node.Children.SelectMany(Flatten));
```

### Decorator

Use when you need to add behavior (logging, caching, retry) to an object without changing it
or its callers, by wrapping it in something implementing the same interface.

```csharp
public class LoggingItemClient : IItemClient
{
    private readonly IItemClient _inner;
    private readonly ILogger _logger;
    public LoggingItemClient(IItemClient inner, ILogger logger) { _inner = inner; _logger = logger; }

    public async Task<Item> GetAsync(Guid id)
    {
        _logger.LogInformation("Fetching item {Id}", id);
        return await _inner.GetAsync(id);
    }
}
```

An ordered collection builder (`umbraco-extensibility`) manages layering like this for you —
`Append()`/`InsertBefore<T>()`/`InsertAfter<T>()` — instead of nesting decorators by hand.

### Facade

Use when a subsystem has many moving parts and most callers only need one simple entry point
into it.

```csharp
public class ItemImportFacade
{
    public async Task ImportAsync(Stream file)
    {
        var parsed = _parser.Parse(file);
        var validated = _validator.Validate(parsed);
        await _repository.AddRangeAsync(validated);
    }
}
```

### Flyweight

Use when you have many fine-grained objects and most of their state can be shared —
separate the shared (intrinsic) state from the per-instance (extrinsic) state.

```csharp
public sealed class GlyphStyle // shared, cached by key — the flyweight
{
    public string FontFamily { get; init; } = "";
    public int Size { get; init; }
}

// callers pass the per-character position separately, they don't get their own GlyphStyle
public void Draw(GlyphStyle style, char c, int x, int y) { /* ... */ }
```

### Proxy

Use when you need a stand-in that controls access to the real object — lazy loading, a
permission check, or a remote call hidden behind a local-looking interface.

```csharp
public class LazyItemProxy : IItem
{
    private readonly Lazy<IItem> _real;
    public LazyItemProxy(Func<IItem> factory) => _real = new Lazy<IItem>(factory);
    public string Name => _real.Value.Name; // real object only loaded on first access
}
```

## Behavioral

Patterns concerned with how objects communicate and divide responsibility.

### Chain of Responsibility

Use when a request should be passed along a series of handlers until one of them handles
it, without the sender knowing which one will. See `umbraco-extensibility` for the ordered
collection builder, which gives you this shape for free — each registered handler decides
whether to act or fall through.

```csharp
public interface IRequestHandler { bool TryHandle(Request request); }

public Task HandleAsync(Request request, IEnumerable<IRequestHandler> handlers)
{
    foreach (var handler in handlers)
        if (handler.TryHandle(request)) return Task.CompletedTask;
    throw new NotSupportedException("No handler matched.");
}
```

### Command

Use when a request itself needs to be an object — for undo/redo, queuing, or logging what
was asked for separately from when it runs.

```csharp
public interface ICommand { Task ExecuteAsync(); Task UndoAsync(); }

public class RenameItemCommand : ICommand
{
    private readonly Item _item;
    private readonly string _newName;
    private string? _previousName;
    public RenameItemCommand(Item item, string newName) { _item = item; _newName = newName; }
    public Task ExecuteAsync() { _previousName = _item.Name; _item.Name = _newName; return Task.CompletedTask; }
    public Task UndoAsync() { _item.Name = _previousName!; return Task.CompletedTask; }
}
```

### Interpreter

Use rarely — when you have a small, stable grammar to evaluate repeatedly (a filter DSL, a
rules mini-language) and a full parser generator would be overkill.

```csharp
public interface IExpression { bool Evaluate(Item item); }

public class AliasEquals : IExpression
{
    private readonly string _alias;
    public AliasEquals(string alias) => _alias = alias;
    public bool Evaluate(Item item) => item.Alias == _alias;
}
```

### Iterator

Use when callers need to traverse a collection without knowing how it's stored. In C#,
`IEnumerable<T>` already gives you this — implement `IEnumerator<T>` by hand only for
non-standard traversal (skip-ahead, bidirectional, lazy generation beyond `yield return`).

```csharp
public IEnumerable<Item> GetActiveItems()
{
    foreach (var item in _items)
        if (item.IsActive) yield return item;
}
```

### Mediator

Use when several objects would otherwise need direct references to each other — route their
interaction through one hub so no pair is directly coupled.

```csharp
public interface IWorkflowMediator { Task NotifyStepCompletedAsync(string stepId); }

public class ImportWorkflowMediator : IWorkflowMediator
{
    public async Task NotifyStepCompletedAsync(string stepId)
    {
        if (stepId == "validate") await _importer.StartAsync();
        if (stepId == "import") await _notifier.SendCompletionAsync();
    }
}
```

### Memento

Use when you need to capture an object's internal state and restore it later without
breaking its encapsulation — the basis of undo and draft/versioning features.

```csharp
public sealed record ItemMemento(string Name, string Alias);

public class Item
{
    public string Name { get; set; } = "";
    public string Alias { get; set; } = "";
    public ItemMemento Save() => new(Name, Alias);
    public void Restore(ItemMemento memento) { Name = memento.Name; Alias = memento.Alias; }
}
```

### Observer

Use when one or more dependents need to react to a state change without the source object
knowing who they are. See `umbraco-extensibility` — `INotificationHandler<T>` registered via a
composer *is* this pattern; prefer it over a hand-rolled event subscription.

```csharp
public interface IItemChangedObserver { Task OnItemChangedAsync(Item item); }
// publish: foreach (var observer in _observers) await observer.OnItemChangedAsync(item);
```

### State

Use when an object's behavior should change based on its internal state, and a field of
flags plus `if`/`switch` everywhere has become hard to follow — model each state as a class.

```csharp
public interface IConnectionState { IConnectionState Refresh(Connection c); }

public class ExpiredState : IConnectionState
{
    public IConnectionState Refresh(Connection c) { c.Token = RefreshToken(c); return new ActiveState(); }
}
```

### Strategy

Use when you need to swap one of several interchangeable algorithms at runtime, selected by
config, alias, or context. See `umbraco-extensibility` — the collection-builder-based provider
model (each provider implementing a shared capability interface) is this pattern at package
scale; resolve by alias or DI rather than a `switch` on a type field.

```csharp
public interface IPricingStrategy { decimal CalculatePrice(Order order); }

public class MemberDiscountPricing : IPricingStrategy
{
    public decimal CalculatePrice(Order order) => order.Subtotal * 0.9m;
}
```

### Template Method

Use when several variants share a fixed sequence of steps but differ in one or two of them —
put the sequence in a base class, make the varying steps abstract or virtual.

```csharp
public abstract class ProviderBase
{
    public async Task<Result> ExecuteAsync(Request request, CancellationToken ct)
    {
        Validate(request);
        var prepared = await PrepareAsync(request, ct);
        return await ExecuteCoreAsync(prepared, ct); // the only step a subclass must implement
    }

    protected virtual void Validate(Request request) { }
    protected virtual Task<Request> PrepareAsync(Request request, CancellationToken ct) => Task.FromResult(request);
    protected abstract Task<Result> ExecuteCoreAsync(Request request, CancellationToken ct);
}
```

### Visitor

Use when you need to add a new operation across a stable set of types without touching each
type's own source — useful for walking a tree structure with varying, unrelated operations.

```csharp
public interface IItemVisitor { void Visit(TextItem item); void Visit(ImageItem item); }

public abstract class Item { public abstract void Accept(IItemVisitor visitor); }

public class TextItem : Item
{
    public override void Accept(IItemVisitor visitor) => visitor.Visit(this);
}
```

## C#-specific guidance

- **Singleton**: prefer `AddSingleton` in DI over a static instance — you get lazy
  construction, testability, and no manual thread-safety code for free.
- **Strategy / Command / State**: a small delegate (`Func<T, TResult>`) or a discriminated
  shape (a closed set of `record`s with a `switch` expression) is sometimes lighter than a
  full class hierarchy — reach for classes once a variant carries its own state or
  dependencies.
- **Prototype**: a `record`'s built-in `with` expression covers most shallow-copy needs;
  implement `Clone()` by hand only when you need a real deep copy.
- **Observer**: prefer the DI-registered notification-handler shape (`umbraco-extensibility`)
  over C# `event`/`delegate` — it's testable in isolation and doesn't leak subscriptions
  across app restarts.
- **Iterator**: reach for `yield return` before hand-writing `IEnumerator<T>` — it covers the
  overwhelming majority of cases.
- Favor `sealed` classes for pattern participants that aren't designed to be further
  extended (most Decorators, Adapters, Commands) — it documents intent and closes off
  accidental inheritance.
