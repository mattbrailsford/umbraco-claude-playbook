#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/Umbraco.Community.ColorSwatch
cat > Umbraco.Community.ColorSwatch.slnx <<'EOF'
<Solution>
  <Project Path="src/Umbraco.Community.ColorSwatch/Umbraco.Community.ColorSwatch.csproj" />
</Solution>
EOF
cat > src/Umbraco.Community.ColorSwatch/Umbraco.Community.ColorSwatch.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.ColorSwatch

A colour swatch property editor for Umbraco 17.

## Conventions

- File-scoped namespaces everywhere.
- Every release gets a line in CHANGELOG.md, newest first.
- Never rename a property editor alias: sites store it in their data.
EOF
