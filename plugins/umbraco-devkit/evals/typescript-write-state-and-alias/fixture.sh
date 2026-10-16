#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/connections
cat > client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "tsc && vite build" },
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "experimentalDecorators": true,
    "useDefineForClassFields": false
  },
  "include": ["src"]
}
EOF
cat > client/src/connections/types.ts <<'EOF'
export interface Connection {
	id: string;
	name: string;
	providerAlias: string;
	baseUrl: string;
}

export interface ProblemDetails {
	title: string;
	status: number;
	detail?: string;
}
EOF
cat > client/src/connections/api.ts <<'EOF'
// Thin wrapper over the package's Management API. Each call resolves with the HTTP response;
// it rejects only on network failure.
import type { Connection } from './types.js';

const BASE = '/umbraco/management/api/v1/my-package/connections';

export const getConnection = (id: string) => fetch(`${BASE}/${id}`, { credentials: 'include' });
export const putConnection = (connection: Connection) =>
	fetch(`${BASE}/${connection.id}`, {
		method: 'PUT',
		credentials: 'include',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(connection),
	});
export const postConnectionTest = (id: string) =>
	fetch(`${BASE}/${id}/test`, { method: 'POST', credentials: 'include' });
EOF
