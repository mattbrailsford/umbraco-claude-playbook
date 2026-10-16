#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/Umbraco.Community.SlugRules/Client/public src/Umbraco.Community.SlugRules/Client/src
cat > Directory.Build.props <<'EOF'
<Project>
  <PropertyGroup>
    <Version>2.3.0</Version>
    <Authors>Slug Rules contributors</Authors>
  </PropertyGroup>
</Project>
EOF
cat > src/Umbraco.Community.SlugRules/Umbraco.Community.SlugRules.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <PackageId>Umbraco.Community.SlugRules</PackageId>
    <StaticWebAssetBasePath>/</StaticWebAssetBasePath>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.6.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/Umbraco.Community.SlugRules/Client/package.json <<'EOF'
{
  "name": "slug-rules-client",
  "version": "2.3.0",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build" },
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > src/Umbraco.Community.SlugRules/Client/public/umbraco-package.json <<'EOF'
{
  "name": "Umbraco.Community.SlugRules",
  "allowTelemetry": true,
  "extensions": [
    {
      "type": "backofficeEntryPoint",
      "alias": "SlugRules.EntryPoint",
      "name": "Slug Rules entry point",
      "js": "/App_Plugins/SlugRules/slug-rules.js"
    }
  ]
}
EOF
cat > src/Umbraco.Community.SlugRules/Client/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';

export default defineConfig({
	build: {
		lib: { entry: 'src/index.ts', formats: ['es'], fileName: 'slug-rules' },
		outDir: '../wwwroot/App_Plugins/SlugRules',
		emptyOutDir: true,
		rollupOptions: { external: [/^@umbraco/] },
	},
});
EOF
cat > src/Umbraco.Community.SlugRules/Client/src/index.ts <<'EOF'
import type { UmbEntryPointOnInit } from '@umbraco-cms/backoffice/extension-api';
import { manifests } from './manifests.js';

export const onInit: UmbEntryPointOnInit = (_host, extensionRegistry) => {
	extensionRegistry.registerMany(manifests);
};
EOF
cat > src/Umbraco.Community.SlugRules/Client/src/manifests.ts <<'EOF'
export const manifests: Array<UmbExtensionManifest> = [];
EOF
cat > CHANGELOG.md <<'EOF'
# Changelog

## 2.3.0
- Slug preview in the content workspace.

## 2.2.0
- Per-document-type rules.
EOF
