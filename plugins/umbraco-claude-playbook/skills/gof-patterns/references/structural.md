# Structural patterns (C#)

Patterns that compose classes and objects into larger structures without making those
structures brittle.

## Adapter

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

## Bridge

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

## Composite

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

## Decorator

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

## Facade

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

## Flyweight

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

## Proxy

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
