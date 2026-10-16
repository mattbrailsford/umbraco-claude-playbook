#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Items src/MyPackage/Reports
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><Nullable>enable</Nullable></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddHttpClient<IItemClient, ItemClient>(c => c.BaseAddress = new Uri("https://api.example-pim.com/"));
        builder.Services.AddScoped<ItemSyncService>();
        builder.Services.AddScoped<ItemPickerService>();
        builder.Services.AddScoped<ReportExporter>();
    }
}
EOF
cat > src/MyPackage/Items/IItemClient.cs <<'EOF'
namespace MyPackage.Items;

public sealed record Item(Guid Id, string Name, decimal Price, DateTime UpdatedUtc);

public interface IItemClient
{
    Task<Item?> GetAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<Item>> SearchAsync(string query, CancellationToken ct = default);
}
EOF
cat > src/MyPackage/Items/ItemClient.cs <<'EOF'
namespace MyPackage.Items;

// Thin wrapper over the PIM's REST API.
internal sealed class ItemClient : IItemClient
{
    private readonly HttpClient _http;
    public ItemClient(HttpClient http) => _http = http;

    public Task<Item?> GetAsync(Guid id, CancellationToken ct = default)
        => _http.GetFromJsonAsync<Item>($"items/{id}", ct);

    public async Task<IReadOnlyList<Item>> SearchAsync(string query, CancellationToken ct = default)
        => await _http.GetFromJsonAsync<List<Item>>($"items?q={Uri.EscapeDataString(query)}", ct) ?? [];
}
EOF
cat > src/MyPackage/Items/ItemSyncService.cs <<'EOF'
namespace MyPackage.Items;

public sealed class ItemSyncService
{
    private readonly IItemClient _client;
    public ItemSyncService(IItemClient client) => _client = client;

    public async Task<Item?> RefreshAsync(Guid id, CancellationToken ct) => await _client.GetAsync(id, ct);
}
EOF
cat > src/MyPackage/Items/ItemPickerService.cs <<'EOF'
namespace MyPackage.Items;

public sealed class ItemPickerService
{
    private readonly IItemClient _client;
    public ItemPickerService(IItemClient client) => _client = client;

    public Task<IReadOnlyList<Item>> SearchAsync(string query, CancellationToken ct) => _client.SearchAsync(query, ct);
    public Task<Item?> GetAsync(Guid id, CancellationToken ct) => _client.GetAsync(id, ct);
}
EOF
cat > src/MyPackage/Reports/ReportExporter.cs <<'EOF'
namespace MyPackage.Reports;

public sealed record ReportRow(string Name, decimal Price, DateTime UpdatedUtc);

public sealed class ReportExporter
{
    public (string ContentType, byte[] Content) Export(IReadOnlyList<ReportRow> rows, string format)
    {
        if (format != "csv") throw new NotSupportedException($"Unknown format '{format}'");

        var sb = new StringBuilder("Name,Price,UpdatedUtc\n");
        foreach (var r in rows) sb.Append($"\"{r.Name.Replace("\"", "\"\"")}\",{r.Price},{r.UpdatedUtc:O}\n");
        return ("text/csv", Encoding.UTF8.GetBytes(sb.ToString()));
    }
}
EOF
