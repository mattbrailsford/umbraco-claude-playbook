#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Stores src/MyPackage/PropertyEditors src/MyPackage.uSync/Serializers
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
    public int Id { get; set; }
    public Guid Key { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
}

public interface IStoreService
{
    Task<Store?> GetAsync(int id);
    Task<Store?> GetAsync(Guid key);
    Task<Store?> GetByAliasAsync(string alias);
}
EOF
cat > src/MyPackage/PropertyEditors/StorePickerPropertyEditor.cs <<'EOF'
namespace MyPackage.PropertyEditors;

[DataEditor("MyPackage.StorePicker", ValueType = ValueTypes.Integer, ValueEditorIsReusable = true)]
public class StorePickerPropertyEditor : DataEditor
{
    public StorePickerPropertyEditor(IDataValueEditorFactory factory) : base(factory) { }
}
EOF
cat > src/MyPackage/PropertyEditors/StorePickerValueConverter.cs <<'EOF'
namespace MyPackage.PropertyEditors;

public class StorePickerValueConverter : PropertyValueConverterBase
{
    private readonly IStoreService _stores;
    public StorePickerValueConverter(IStoreService stores) => _stores = stores;

    public override bool IsConverter(IPublishedPropertyType propertyType)
        => propertyType.EditorAlias == "MyPackage.StorePicker";

    public override Type GetPropertyValueType(IPublishedPropertyType propertyType) => typeof(Store);

    public override object? ConvertIntermediateToObject(IPublishedElement owner, IPublishedPropertyType propertyType,
        PropertyCacheLevel referenceCacheLevel, object? inter, bool preview)
        => inter is int id ? _stores.GetAsync(id).GetAwaiter().GetResult() : null;
}
EOF
cat > src/MyPackage.uSync/Serializers/StoreSerializer.cs <<'EOF'
namespace MyPackage.uSync.Serializers;

[SyncSerializer("6b7e0b6c-3f6a-4f0e-9b1e-2a0c4a7d9e11", "Store serializer", "MyPackageStore")]
public class StoreSerializer : SyncSerializerRoot<Store>, ISyncSerializer<Store>
{
    // Writes Key, Alias and Name; on import, finds by key then alias and keeps the source's key.
}
EOF
