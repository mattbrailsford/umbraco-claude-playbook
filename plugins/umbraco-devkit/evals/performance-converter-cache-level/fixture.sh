#!/usr/bin/env bash
set -euo pipefail
d=src/MyPackage
mkdir -p $d/PropertyEditors/Rating $d/PropertyEditors/Color
cat > $d/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/PropertyEditors/Rating/RatingValue.cs <<'EOF'
namespace MyPackage.PropertyEditors.Rating;

public record RatingValue(int Stars, int OutOf);
EOF
cat > $d/PropertyEditors/Rating/RatingValueConverter.cs <<'EOF'
using System.Text.Json;
using Umbraco.Cms.Core.Models.PublishedContent;
using Umbraco.Cms.Core.PropertyEditors;

namespace MyPackage.PropertyEditors.Rating;

public class RatingValueConverter : PropertyValueConverterBase
{
    public override bool IsConverter(IPublishedPropertyType propertyType)
        => propertyType.EditorAlias == "MyPackage.Rating";

    public override Type GetPropertyValueType(IPublishedPropertyType propertyType)
        => typeof(RatingValue);

    public override object? ConvertSourceToIntermediate(IPublishedElement owner, IPublishedPropertyType propertyType, object? source, bool preview)
        => source is string json && !string.IsNullOrWhiteSpace(json)
            ? JsonSerializer.Deserialize<RatingValue>(json, new JsonSerializerOptions(JsonSerializerDefaults.Web))
            : null;
}
EOF
cat > $d/PropertyEditors/Color/ColorValue.cs <<'EOF'
namespace MyPackage.PropertyEditors.Color;

public record ColorValue(string Hex, string Label);
EOF
