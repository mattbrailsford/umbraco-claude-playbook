#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Stores src/MyPackage/Shipping src/MyPackage.uSync/Serializers
cat > MyPackage.sln <<'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
EOF
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><PackageId>MyCompany.MyPackage</PackageId></PropertyGroup>
  <ItemGroup><PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" /></ItemGroup>
</Project>
EOF
cat > src/MyPackage.uSync/MyPackage.uSync.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><PackageId>MyCompany.MyPackage.uSync</PackageId></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="uSync.Core" Version="[17.0.0, 18.0.0)" />
    <ProjectReference Include="../MyPackage/MyPackage.csproj" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/Stores/Store.cs <<'EOF'
namespace MyPackage.Stores;

public class Store
{
    public Guid Key { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string CurrencyCode { get; set; } = "EUR";
    public decimal FreeShippingThreshold { get; set; }
}
EOF
cat > src/MyPackage/Stores/StoreService.cs <<'EOF'
namespace MyPackage.Stores;

public interface IStoreService
{
    Task<IReadOnlyList<Store>> GetAllAsync();
    Task<Store?> GetAsync(Guid key);
    Task<Store?> GetByAliasAsync(string alias);
    Task SaveAsync(Store store);
}
EOF
cat > src/MyPackage/Stores/StoreDto.cs <<'EOF'
namespace MyPackage.Stores;

public sealed record StoreDto(Guid Key, string Alias, string Name, string CurrencyCode, decimal FreeShippingThreshold)
{
    public static StoreDto From(Store s) => new(s.Key, s.Alias, s.Name, s.CurrencyCode, s.FreeShippingThreshold);
}
EOF
cat > src/MyPackage/Shipping/ShippingZone.cs <<'EOF'
namespace MyPackage.Shipping;

public class ShippingZone
{
    public Guid Key { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string[] CountryCodes { get; set; } = [];
}

public interface IShippingZoneService
{
    Task<ShippingZone?> GetAsync(Guid key);
    Task<ShippingZone?> GetByAliasAsync(string alias);
}
EOF
cat > src/MyPackage.uSync/Serializers/StoreSerializer.cs <<'EOF'
namespace MyPackage.uSync.Serializers;

[SyncSerializer("6b7e0b6c-3f6a-4f0e-9b1e-2a0c4a7d9e11", "Store serializer", "MyPackageStore")]
public class StoreSerializer : SyncSerializerRoot<Store>, ISyncSerializer<Store>
{
    private readonly IStoreService _stores;

    public StoreSerializer(IStoreService stores, ILogger<StoreSerializer> logger) : base(logger)
        => _stores = stores;

    protected override SyncAttempt<XElement> SerializeCore(Store item, SyncSerializerOptions options)
    {
        var node = InitializeBaseNode(item, item.Alias);
        node.Add(new XElement("Name", item.Name));
        node.Add(new XElement("CurrencyCode", item.CurrencyCode));
        node.Add(new XElement("FreeShippingThreshold", item.FreeShippingThreshold.ToString("0.00", CultureInfo.InvariantCulture)));
        return SyncAttempt<XElement>.Succeed(item.Name, node, ChangeType.Export);
    }

    protected override SyncAttempt<Store> DeserializeCore(XElement node, SyncSerializerOptions options)
    {
        var key = node.GetKey();
        var alias = node.GetAlias();
        var store = FindItem(key, alias) ?? new Store { Key = key, Alias = alias };

        store.Name = node.Element("Name")!.Value;
        store.CurrencyCode = node.Element("CurrencyCode")!.Value;
        store.FreeShippingThreshold = decimal.Parse(node.Element("FreeShippingThreshold")!.Value, CultureInfo.InvariantCulture);

        return SyncAttempt<Store>.Succeed(store.Name, store, ChangeType.Import);
    }

    public override Store? FindItem(Guid key, string alias)
        => _stores.GetAsync(key).GetAwaiter().GetResult() ?? _stores.GetByAliasAsync(alias).GetAwaiter().GetResult();

    public override void SaveItem(Store item) => _stores.SaveAsync(item).GetAwaiter().GetResult();
}
EOF
