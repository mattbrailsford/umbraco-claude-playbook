# Creational patterns (C#)

Patterns that hide *how* and *when* an object gets created.

## Factory Method

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

## Abstract Factory

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

## Builder

Use when constructing a complex object needs many optional steps and a constructor with ten
parameters would be unreadable and error-prone.

```csharp
var request = new ItemRequestBuilder()
    .WithAlias("hero-banner")
    .WithName("Hero Banner")
    .WithProperty("title", "Welcome")
    .Build();
```

## Prototype

Use when creating a new instance is expensive or awkward compared to copying an existing,
already-configured one.

```csharp
public record ItemTemplate(string Alias, IReadOnlyDictionary<string, object?> Defaults)
{
    public ItemTemplate Clone() => this with { Defaults = new Dictionary<string, object?>(Defaults) };
}
```

**Idiom note:** a `record`'s built-in `with` expression covers most shallow-copy needs;
implement `Clone()` by hand only when you need a real deep copy.

## Singleton

Use when exactly one instance must exist for the app's lifetime. In a DI-based app this is
almost always `AddSingleton`, not a hand-rolled static instance:

```csharp
builder.Services.AddSingleton<IFeatureFlagCache, FeatureFlagCache>();
// reach for a hand-rolled `private static readonly Instance` only outside a DI container
```

**Idiom note:** prefer `AddSingleton` in DI over a static instance — you get lazy
construction, testability, and no manual thread-safety code for free.
