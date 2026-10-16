#!/usr/bin/env bash
set -euo pipefail
d=src/MyPackage
mkdir -p $d/PropertyEditors $d/Composers
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
cat > $d/PropertyEditors/TagListConfiguration.cs <<'EOF'
using Umbraco.Cms.Core.PropertyEditors;

namespace MyPackage.PropertyEditors;

public class TagListConfiguration
{
    [ConfigurationField("maxItems")]
    public int MaxItems { get; set; } = 10;
}
EOF
cat > $d/PropertyEditors/TagListPropertyEditor.cs <<'EOF'
using Umbraco.Cms.Core.IO;
using Umbraco.Cms.Core.PropertyEditors;

namespace MyPackage.PropertyEditors;

/// <summary>A list of free-text tags, stored as a JSON array of strings.</summary>
[DataEditor(Alias, ValueType = ValueTypes.Json, ValueEditorIsReusable = true)]
public class TagListPropertyEditor(IDataValueEditorFactory dataValueEditorFactory, IIOHelper ioHelper)
    : DataEditor(dataValueEditorFactory)
{
    public const string Alias = "MyPackage.TagList";

    protected override IConfigurationEditor CreateConfigurationEditor()
        => new TagListConfigurationEditor(ioHelper);
}

public class TagListConfigurationEditor(IIOHelper ioHelper) : ConfigurationEditor<TagListConfiguration>(ioHelper);
EOF
cat > $d/Composers/MyPackageComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;

namespace MyPackage.Composers;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
    }
}
EOF
