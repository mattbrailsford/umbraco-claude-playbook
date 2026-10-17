#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Stores src/MyPackage.uSync/Serializers src/MyPackage.uSync/Handlers
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><PackageId>MyCompany.Commerce</PackageId></PropertyGroup>
  <ItemGroup><PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" /></ItemGroup>
</Project>
EOF
cat > src/MyPackage.uSync/MyPackage.uSync.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><PackageId>MyCompany.Commerce.uSync</PackageId></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="uSync.Core" Version="[17.0.0, 18.0.0)" />
    <PackageReference Include="uSync.BackOffice" Version="[17.0.0, 18.0.0)" />
    <ProjectReference Include="../MyPackage/MyPackage.csproj" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/Stores/Entities.cs <<'EOF'
namespace MyPackage.Stores;

// Database ids are identity integers; Key is a GUID set on create.
public class Store
{
    public int Id { get; set; }
    public Guid Key { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string CurrencyCode { get; set; } = "EUR";
}

public class Country
{
    public int Id { get; set; }
    public Guid Key { get; set; }
    public int StoreId { get; set; }
    public string IsoCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
}

public class TaxRate
{
    public int Id { get; set; }
    public Guid Key { get; set; }
    public int CountryId { get; set; }
    public string Alias { get; set; } = string.Empty;
    public decimal Rate { get; set; }
}
EOF
cat > src/MyPackage/Stores/IStoreService.cs <<'EOF'
namespace MyPackage.Stores;

// Each Save returns the saved entity with its Id set. Get* return null when missing.
public interface IStoreService
{
    Task<Store?> GetStoreAsync(int id);
    Task<Store?> GetStoreAsync(Guid key);
    Task<Store?> GetStoreByAliasAsync(string alias);
    Task<Store> SaveStoreAsync(Store store);
    Task<Country?> GetCountryAsync(int id);
    Task<Country?> GetCountryAsync(Guid key);
    Task<Country> SaveCountryAsync(Country country);
    Task<TaxRate?> GetTaxRateAsync(int id);
    Task<TaxRate?> GetTaxRateAsync(Guid key);
    Task<IReadOnlyList<TaxRate>> GetTaxRatesForStoreAsync(int storeId);
    Task<TaxRate> SaveTaxRateAsync(TaxRate taxRate);
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
        return SyncAttempt<XElement>.Succeed(item.Name, node, ChangeType.Export);
    }

    protected override SyncAttempt<Store> DeserializeCore(XElement node, SyncSerializerOptions options)
    {
        var key = node.GetKey();
        var alias = node.GetAlias();
        var store = FindItem(key, alias) ?? new Store { Key = key, Alias = alias };
        store.Name = node.Element("Name")!.Value;
        store.CurrencyCode = node.Element("CurrencyCode")!.Value;
        return SyncAttempt<Store>.Succeed(store.Name, store, ChangeType.Import);
    }

    public override Store? FindItem(Guid key, string alias)
        => _stores.GetStoreAsync(key).GetAwaiter().GetResult()
            ?? _stores.GetStoreByAliasAsync(alias).GetAwaiter().GetResult();

    public override void SaveItem(Store item) => _stores.SaveStoreAsync(item).GetAwaiter().GetResult();
}
EOF
cat > src/MyPackage.uSync/Serializers/CountrySerializer.cs <<'EOF'
namespace MyPackage.uSync.Serializers;

[SyncSerializer("0d3c2a51-9e4b-4c7a-8f2e-61b5a9c0e7d2", "Country serializer", "MyPackageCountry")]
public class CountrySerializer : SyncSerializerRoot<Country>, ISyncSerializer<Country>
{
    private readonly IStoreService _stores;

    public CountrySerializer(IStoreService stores, ILogger<CountrySerializer> logger) : base(logger)
        => _stores = stores;

    protected override SyncAttempt<XElement> SerializeCore(Country item, SyncSerializerOptions options)
    {
        var store = _stores.GetStoreAsync(item.StoreId).GetAwaiter().GetResult()!;
        var node = InitializeBaseNode(item, $"{store.Alias}_{item.IsoCode}");
        node.Add(new XElement("Store", store.Key));
        node.Add(new XElement("IsoCode", item.IsoCode));
        node.Add(new XElement("Name", item.Name));
        return SyncAttempt<XElement>.Succeed(item.Name, node, ChangeType.Export);
    }

    protected override SyncAttempt<Country> DeserializeCore(XElement node, SyncSerializerOptions options)
    {
        var key = node.GetKey();
        var store = _stores.GetStoreAsync(Guid.Parse(node.Element("Store")!.Value)).GetAwaiter().GetResult();
        if (store is null)
            return SyncAttempt<Country>.Fail(node.GetAlias(), ChangeType.Fail, "Store not found");

        var country = FindItem(key, node.GetAlias()) ?? new Country { Key = key };
        country.StoreId = store.Id;
        country.IsoCode = node.Element("IsoCode")!.Value;
        country.Name = node.Element("Name")!.Value;
        return SyncAttempt<Country>.Succeed(country.Name, country, ChangeType.Import);
    }

    public override Country? FindItem(Guid key, string alias) => _stores.GetCountryAsync(key).GetAwaiter().GetResult();

    public override void SaveItem(Country item) => _stores.SaveCountryAsync(item).GetAwaiter().GetResult();
}
EOF
cat > src/MyPackage.uSync/Serializers/TaxRateSerializer.cs <<'EOF'
namespace MyPackage.uSync.Serializers;

[SyncSerializer("a9f1e6c4-2b7d-4e3a-9c5f-8d0b1e2a3c4f", "Tax rate serializer", "MyPackageTaxRate")]
public class TaxRateSerializer : SyncSerializerRoot<TaxRate>, ISyncSerializer<TaxRate>
{
    private readonly IStoreService _stores;

    public TaxRateSerializer(IStoreService stores, ILogger<TaxRateSerializer> logger) : base(logger)
        => _stores = stores;

    protected override SyncAttempt<XElement> SerializeCore(TaxRate item, SyncSerializerOptions options)
    {
        var country = _stores.GetCountryAsync(item.CountryId).GetAwaiter().GetResult()!;
        var node = InitializeBaseNode(item, item.Alias);
        node.Add(new XElement("Country", country.Key));
        node.Add(new XElement("Rate", item.Rate.ToString(CultureInfo.InvariantCulture)));
        return SyncAttempt<XElement>.Succeed(item.Alias, node, ChangeType.Export);
    }

    protected override SyncAttempt<TaxRate> DeserializeCore(XElement node, SyncSerializerOptions options)
    {
        var key = node.GetKey();
        var country = _stores.GetCountryAsync(Guid.Parse(node.Element("Country")!.Value)).GetAwaiter().GetResult();
        if (country is null)
            return SyncAttempt<TaxRate>.Fail(node.GetAlias(), ChangeType.Fail, "Country not found");

        var rate = FindItem(key, node.GetAlias()) ?? new TaxRate { Key = key, Alias = node.GetAlias() };
        rate.CountryId = country.Id;
        rate.Rate = decimal.Parse(node.Element("Rate")!.Value, CultureInfo.InvariantCulture);
        return SyncAttempt<TaxRate>.Succeed(rate.Alias, rate, ChangeType.Import);
    }

    public override TaxRate? FindItem(Guid key, string alias) => _stores.GetTaxRateAsync(key).GetAwaiter().GetResult();

    public override void SaveItem(TaxRate item) => _stores.SaveTaxRateAsync(item).GetAwaiter().GetResult();
}
EOF
cat > src/MyPackage.uSync/Handlers/Handlers.cs <<'EOF'
namespace MyPackage.uSync.Handlers;

// Lower priority imports first: stores, then countries, then tax rates.

[SyncHandler("myPackageStoreHandler", "Stores", "MyPackage/Stores", 1100, Icon = "icon-store")]
public class StoreHandler : SyncHandlerRoot<Store, Store>, ISyncHandler { /* lookups via IStoreService */ }

[SyncHandler("myPackageCountryHandler", "Countries", "MyPackage/Countries", 1110, Icon = "icon-globe")]
public class CountryHandler : SyncHandlerRoot<Country, Country>, ISyncHandler { /* lookups via IStoreService */ }

[SyncHandler("myPackageTaxRateHandler", "Tax rates", "MyPackage/TaxRates", 1120, Icon = "icon-coins")]
public class TaxRateHandler : SyncHandlerRoot<TaxRate, TaxRate>, ISyncHandler { /* lookups via IStoreService */ }
EOF
