#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Stores src/MyPackage.uSync
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
    public int? DefaultCountryId { get; set; }   // must be one of this store's countries
}

public class Country
{
    public int Id { get; set; }
    public Guid Key { get; set; }
    public int StoreId { get; set; }             // every country belongs to a store
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
    Task<IReadOnlyList<Store>> GetStoresAsync();
    Task<Store> SaveStoreAsync(Store store);
    Task<Country?> GetCountryAsync(int id);
    Task<Country?> GetCountryAsync(Guid key);
    Task<IReadOnlyList<Country>> GetCountriesAsync(int storeId);
    Task<Country> SaveCountryAsync(Country country);
    Task<TaxRate?> GetTaxRateAsync(Guid key);
    Task<IReadOnlyList<TaxRate>> GetTaxRatesAsync(int countryId);
    Task<TaxRate> SaveTaxRateAsync(TaxRate taxRate);
}
EOF
