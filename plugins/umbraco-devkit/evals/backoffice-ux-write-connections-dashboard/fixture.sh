#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/connections
cat > client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/connections/repository.ts <<'EOF'
import type { UmbControllerHost } from '@umbraco-cms/backoffice/controller-api';

export interface Connection {
	id: string;
	name: string;
	provider: 'mailchimp' | 'brevo' | 'klaviyo';
	contentKey: string;      // the Umbraco document this connection links to
	contentName: string;
}

export interface NewConnection {
	name: string;
	provider: Connection['provider'];
	contentKey: string;
}

// Both methods return { data, error } and never throw. requestAll can take a few seconds.
export class MyConnectionRepository {
	constructor(host: UmbControllerHost) {}
	async requestAll(): Promise<{ data?: Connection[]; error?: Error }> { return { data: [] }; }
	async create(input: NewConnection): Promise<{ data?: Connection; error?: Error }> { return {}; }
}
EOF
