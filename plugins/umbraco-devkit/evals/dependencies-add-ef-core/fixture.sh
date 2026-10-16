#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage
cat > Directory.Packages.props <<'EOF'
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
    <PackageVersion Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <PackageId>MyCompany.MyPackage</PackageId>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" />
    <PackageReference Include="Umbraco.Cms.Api.Management" />
  </ItemGroup>
</Project>
EOF
