#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyCompany.Bookings tests/MyCompany.Bookings.Tests
cat > Directory.Build.props <<'EOF'
<Project>
  <PropertyGroup>
    <Version>2.1.0</Version>
  </PropertyGroup>
</Project>
EOF
cat > Directory.Packages.props <<'EOF'
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Umbraco.Cms.Core" Version="[17.0.0, 18.0.0)" />
    <PackageVersion Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
    <PackageVersion Include="Microsoft.EntityFrameworkCore.SqlServer" Version="10.0.0" />
    <PackageVersion Include="Microsoft.EntityFrameworkCore.Sqlite" Version="10.0.0" />
  </ItemGroup>
  <ItemGroup Label="Tests">
    <PackageVersion Include="xunit.v3" Version="3.0.0" />
    <PackageVersion Include="Microsoft.NET.Test.Sdk" Version="17.14.0" />
  </ItemGroup>
</Project>
EOF
cat > src/MyCompany.Bookings/MyCompany.Bookings.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <PackageId>MyCompany.Bookings</PackageId>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" />
  </ItemGroup>
</Project>
EOF
cat > tests/MyCompany.Bookings.Tests/MyCompany.Bookings.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="xunit.v3" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" />
    <ProjectReference Include="../../src/MyCompany.Bookings/MyCompany.Bookings.csproj" />
  </ItemGroup>
</Project>
EOF
cat > DEPENDABOT-PRS.md <<'EOF'
Open Dependabot PRs (all green in CI):

- #212 Bump Microsoft.EntityFrameworkCore.SqlServer from 10.0.0 to 10.0.10
- #213 Bump Microsoft.EntityFrameworkCore.Sqlite from 10.0.0 to 10.0.10
- #214 Bump xunit.v3 from 3.0.0 to 3.0.1
- #215 Bump Microsoft.NET.Test.Sdk from 17.14.0 to 17.14.1
EOF
