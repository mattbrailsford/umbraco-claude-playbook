#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyCompany.Forms.Core src/MyCompany.Forms.Web src/MyCompany.Forms .github/workflows
cat > Directory.Build.props <<'EOF'
<Project>
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Version>3.2.0</Version>
  </PropertyGroup>
</Project>
EOF
cat > src/MyCompany.Forms.Core/MyCompany.Forms.Core.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Core" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/MyCompany.Forms.Web/MyCompany.Forms.Web.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
    <ProjectReference Include="../MyCompany.Forms.Core/MyCompany.Forms.Core.csproj" />
  </ItemGroup>
</Project>
EOF
cat > src/MyCompany.Forms/MyCompany.Forms.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <IncludeBuildOutput>false</IncludeBuildOutput>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="../MyCompany.Forms.Core/MyCompany.Forms.Core.csproj" />
    <ProjectReference Include="../MyCompany.Forms.Web/MyCompany.Forms.Web.csproj" />
  </ItemGroup>
</Project>
EOF
cat > .github/workflows/release.yml <<'EOF'
name: Release
on:
  push:
    tags: ['v*']
jobs:
  pack:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
      - run: dotnet pack MyCompany.Forms.sln -c Release -o ./artifacts
      - run: dotnet nuget push "./artifacts/*.nupkg" --api-key ${{ secrets.NUGET_KEY }} --source https://api.nuget.org/v3/index.json
EOF
echo 'Microsoft Visual Studio Solution File, Format Version 12.00' > MyCompany.Forms.sln
