#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Client/src tests/MyPackage.Tests .github/workflows
cat > Directory.Packages.props <<'EOF'
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
    <PackageVersion Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18.0.0)" />
    <PackageVersion Include="Microsoft.EntityFrameworkCore.SqlServer" Version="10.0.0" />
    <PackageVersion Include="Microsoft.EntityFrameworkCore.Sqlite" Version="10.0.0" />
    <PackageVersion Include="Microsoft.EntityFrameworkCore.Design" Version="10.0.0" />
    <PackageVersion Include="Markdig" Version="0.40.0" />
    <PackageVersion Include="MinVer" Version="6.0.0" />
    <PackageVersion Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageVersion Include="xunit.v3" Version="3.0.1" />
    <PackageVersion Include="NSubstitute" Version="5.3.0" />
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
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" PrivateAssets="all" />
    <PackageReference Include="Markdig" />
    <PackageReference Include="MinVer" PrivateAssets="all" />
  </ItemGroup>
</Project>
EOF
cat > tests/MyPackage.Tests/MyPackage.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><IsPackable>false</IsPackable></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" />
    <PackageReference Include="xunit.v3" />
    <PackageReference Include="NSubstitute" />
    <ProjectReference Include="../../src/MyPackage/MyPackage.csproj" />
  </ItemGroup>
</Project>
EOF
cat > MyPackage.sln <<'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
EOF
cat > src/MyPackage/Client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build", "generate-client": "openapi-ts" },
  "dependencies": { "marked": "^15.0.0" },
  "devDependencies": {
    "@umbraco-cms/backoffice": "^17.0.0",
    "@hey-api/openapi-ts": "^0.80.0",
    "typescript": "^5.9.0",
    "vite": "^7.0.0"
  }
}
EOF
cat > src/MyPackage/Client/package-lock.json <<'EOF'
{
  "name": "my-package-client",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": { "name": "my-package-client", "dependencies": { "marked": "^15.0.0" }, "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "@hey-api/openapi-ts": "^0.80.0", "typescript": "^5.9.0", "vite": "^7.0.0" } },
    "node_modules/@umbraco-cms/backoffice": {
      "version": "17.0.0",
      "dev": true,
      "peerDependencies": { "@umbraco-ui/uui": "^1.16.0", "lit": "^3.3.0", "rxjs": "^7.8.0", "dompurify": "^3.2.0", "marked": "^15.0.0", "monaco-editor": "^0.52.0", "luxon": "^3.6.0" }
    },
    "node_modules/marked": { "version": "15.0.12" }
  }
}
EOF
cat > src/MyPackage/Client/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';
export default defineConfig({
	build: { lib: { entry: 'src/index.ts', formats: ['es'] }, rollupOptions: { external: [/^@umbraco/] } },
});
EOF
cat > src/MyPackage/Client/src/help.ts <<'EOF'
import { marked } from 'marked';
export const renderHelp = (md: string) => marked.parse(md);
EOF
cat > commitlint.config.js <<'EOF'
export default {
	extends: ['@commitlint/config-conventional'],
	rules: {
		'type-enum': [2, 'always', ['feat', 'fix', 'chore', 'docs', 'refactor', 'test', 'ci']],
	},
};
EOF
cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
      - run: dotnet build
EOF
