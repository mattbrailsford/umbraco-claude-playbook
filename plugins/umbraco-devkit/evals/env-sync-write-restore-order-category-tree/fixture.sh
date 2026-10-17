#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Catalog src/MyPackage.uSync
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><PackageId>MyCompany.Catalog</PackageId></PropertyGroup>
  <ItemGroup><PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" /></ItemGroup>
</Project>
EOF
cat > src/MyPackage.uSync/MyPackage.uSync.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><PackageId>MyCompany.Catalog.uSync</PackageId></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="uSync.Core" Version="[17.0.0, 18.0.0)" />
    <PackageReference Include="uSync.BackOffice" Version="[17.0.0, 18.0.0)" />
    <ProjectReference Include="../MyPackage/MyPackage.csproj" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/Catalog/ProductCategory.cs <<'EOF'
namespace MyPackage.Catalog;

/// <summary>
/// Product categories form a tree, often four or five levels deep
/// ("Clothing" > "Women" > "Shoes" > "Trainers"). Ids are identity integers; Key is a GUID
/// set on create.
/// </summary>
public class ProductCategory
{
    public int Id { get; set; }
    public Guid Key { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public int? ParentId { get; set; }          // null for a top-level category
    public int SortOrder { get; set; }
    public string? Description { get; set; }
}
EOF
cat > src/MyPackage/Catalog/ICategoryService.cs <<'EOF'
namespace MyPackage.Catalog;

// Save returns the saved category with its Id set. Get* return null when missing.
// Save throws if ParentId points at a category that doesn't exist.
public interface ICategoryService
{
    Task<ProductCategory?> GetAsync(int id);
    Task<ProductCategory?> GetAsync(Guid key);
    Task<ProductCategory?> GetByAliasAsync(string alias);
    Task<IReadOnlyList<ProductCategory>> GetAllAsync();
    Task<ProductCategory> SaveAsync(ProductCategory category);
    Task DeleteAsync(Guid key);
}
EOF
