#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyCompany.HelpText/Services
cat > Directory.Build.props <<'EOF'
<Project>
  <PropertyGroup>
    <Version>3.4.0</Version>
  </PropertyGroup>
</Project>
EOF
cat > Directory.Packages.props <<'EOF'
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
    <PackageVersion Include="Markdig" Version="0.40.0" />
  </ItemGroup>
</Project>
EOF
cat > src/MyCompany.HelpText/MyCompany.HelpText.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <PackageId>MyCompany.HelpText</PackageId>
    <Description>Markdown help text for Umbraco properties.</Description>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" />
    <PackageReference Include="Markdig" />
  </ItemGroup>
</Project>
EOF
cat > src/MyCompany.HelpText/Services/HelpTextRenderer.cs <<'EOF'
using Markdig;

namespace MyCompany.HelpText.Services;

internal sealed class HelpTextRenderer
{
    private static readonly MarkdownPipeline Pipeline = new MarkdownPipelineBuilder()
        .UseAdvancedExtensions()
        .Build();

    public string Render(string markdown) => Markdown.ToHtml(markdown, Pipeline);
}
EOF
cat > CHANGELOG.md <<'EOF'
# Changelog

## 3.4.0
- Help text can be shown inline or in a popover.

## 3.3.0
- Help text supports culture-specific variants.
EOF
