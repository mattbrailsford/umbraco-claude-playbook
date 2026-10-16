#!/usr/bin/env bash
set -euo pipefail
git init -q -b main
git config user.email eval@example.com && git config user.name eval
mkdir -p src/Umbraco.Community.TagCloud
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.TagCloud

A tag cloud for Umbraco 17 sites: editors pick a tag group, and the cloud sizes each tag by how
many published items use it. Supports Umbraco 17. Trunk branch: `main`.

## Build & test

- `dotnet build`
- `dotnet test`
EOF
cat > README.md <<'EOF'
# Umbraco.Community.TagCloud

[One-line description — TODO]
EOF
cat > src/Umbraco.Community.TagCloud/Umbraco.Community.TagCloud.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
git add -A && git commit -qm "chore: initial commit"
