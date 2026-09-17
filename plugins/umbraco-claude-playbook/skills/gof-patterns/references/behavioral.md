# Behavioral patterns (C#)

Patterns concerned with how objects communicate and divide responsibility.

## Chain of Responsibility

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

## Command

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

**Idiom note:** a small delegate (`Func<T, TResult>`) or a discriminated shape (a closed set
of `record`s with a `switch` expression) is sometimes lighter than a full class hierarchy —
reach for a class once a variant carries its own state or dependencies. Applies to Strategy
and State below too.

## Interpreter

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

## Iterator

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

**Idiom note:** reach for `yield return` before hand-writing `IEnumerator<T>` — it covers the
overwhelming majority of cases.

## Mediator

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

## Memento

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

## Observer

Use when one or more dependents need to react to a state change without the source object
knowing who they are. See `umbraco-extensibility` — `INotificationHandler<T>` registered via a
composer *is* this pattern; prefer it over a hand-rolled event subscription.

```csharp
public interface IItemChangedObserver { Task OnItemChangedAsync(Item item); }
// publish: foreach (var observer in _observers) await observer.OnItemChangedAsync(item);
```

**Idiom note:** prefer the DI-registered notification-handler shape (`umbraco-extensibility`)
over C# `event`/`delegate` — it's testable in isolation and doesn't leak subscriptions across
app restarts.

## State

Use when an object's behavior should change based on its internal state, and a field of
flags plus `if`/`switch` everywhere has become hard to follow — model each state as a class.

```csharp
public interface IConnectionState { IConnectionState Refresh(Connection c); }

public class ExpiredState : IConnectionState
{
    public IConnectionState Refresh(Connection c) { c.Token = RefreshToken(c); return new ActiveState(); }
}
```

## Strategy

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

## Template Method

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

## Visitor

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
