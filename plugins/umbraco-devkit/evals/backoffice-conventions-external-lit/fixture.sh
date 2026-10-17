#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/Umbraco.Community.Greeting/Client/public
cat > src/Umbraco.Community.Greeting/Umbraco.Community.Greeting.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <StaticWebAssetBasePath>/</StaticWebAssetBasePath>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/Umbraco.Community.Greeting/Client/package.json <<'EOF'
{
  "name": "greeting-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "tsc && vite build" },
  "dependencies": { "lit": "^3.3.0" },
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > src/Umbraco.Community.Greeting/Client/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "experimentalDecorators": true,
    "useDefineForClassFields": false,
    "strict": true,
    "types": ["@umbraco-cms/backoffice/extension-types"]
  },
  "include": ["src"]
}
EOF
cat > src/Umbraco.Community.Greeting/Client/public/umbraco-package.json <<'EOF'
{
  "name": "Umbraco.Community.Greeting",
  "version": "0.1.0",
  "extensions": [
    {
      "type": "dashboard",
      "alias": "Greeting.Dashboard",
      "name": "Greeting dashboard",
      "element": "/App_Plugins/Greeting/greeting.js",
      "meta": { "label": "Welcome", "pathname": "welcome" },
      "conditions": [{ "alias": "Umb.Condition.SectionAlias", "match": "Umb.Section.Content" }]
    }
  ]
}
EOF
