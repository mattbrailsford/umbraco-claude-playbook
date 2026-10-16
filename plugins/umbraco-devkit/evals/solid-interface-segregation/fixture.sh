#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Providers
cat > src/MyPackage/Providers/IProductProvider.cs <<'EOF'
namespace MyPackage.Providers;

public sealed record Product(string Id, string Name, decimal Price);

public interface IProductProvider
{
    string Alias { get; }
    Task<IReadOnlyList<Product>> ListAsync(CancellationToken ct = default);
    Task<Product?> GetAsync(string id, CancellationToken ct = default);
    Task SaveAsync(Product product, CancellationToken ct = default);
    Task DeleteAsync(string id, CancellationToken ct = default);
}
EOF
cat > src/MyPackage/Providers/ShopApiProvider.cs <<'EOF'
namespace MyPackage.Providers;

internal sealed class ShopApiProvider : IProductProvider
{
    private readonly HttpClient _http;
    public ShopApiProvider(HttpClient http) => _http = http;

    public string Alias => "shop-api";
    public async Task<IReadOnlyList<Product>> ListAsync(CancellationToken ct = default)
        => await _http.GetFromJsonAsync<List<Product>>("products", ct) ?? [];
    public Task<Product?> GetAsync(string id, CancellationToken ct = default)
        => _http.GetFromJsonAsync<Product>($"products/{id}", ct);
    public async Task SaveAsync(Product product, CancellationToken ct = default)
        => (await _http.PutAsJsonAsync($"products/{product.Id}", product, ct)).EnsureSuccessStatusCode();
    public async Task DeleteAsync(string id, CancellationToken ct = default)
        => (await _http.DeleteAsync($"products/{id}", ct)).EnsureSuccessStatusCode();
}
EOF
cat > src/MyPackage/Providers/ProductSyncService.cs <<'EOF'
namespace MyPackage.Providers;

public sealed class ProductSyncService
{
    private readonly IEnumerable<IProductProvider> _providers;
    public ProductSyncService(IEnumerable<IProductProvider> providers) => _providers = providers;

    public async Task<IReadOnlyList<Product>> ListAllAsync(CancellationToken ct = default)
    {
        var all = new List<Product>();
        foreach (var provider in _providers) all.AddRange(await provider.ListAsync(ct));
        return all;
    }

    public Task PushAsync(string providerAlias, Product product, CancellationToken ct = default)
        => _providers.Single(p => p.Alias == providerAlias).SaveAsync(product, ct);
}
EOF
