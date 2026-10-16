#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Client/src
cat > src/MyPackage/Client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build" },
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "lit": "^3.3.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > src/MyPackage/Client/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';
export default defineConfig({
	build: { lib: { entry: 'src/index.ts', formats: ['es'] }, rollupOptions: { external: [/^@umbraco/] } },
});
EOF
