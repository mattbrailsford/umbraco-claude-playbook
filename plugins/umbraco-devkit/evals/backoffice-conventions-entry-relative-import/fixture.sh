#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/api client/src/dashboard client/public
cat > client/package.json <<'EOF'
{
  "name": "status-board-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build" },
  "devDependencies": { "@umbraco-cms/backoffice": "^18.1.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';

export default defineConfig({
	build: {
		lib: {
			entry: {
				entry: 'src/entry.ts',
				dashboard: 'src/dashboard/dashboard.element.ts',
			},
			formats: ['es'],
		},
		outDir: '../src/StatusBoard/wwwroot/App_Plugins/StatusBoard',
		emptyOutDir: true,
		sourcemap: true,
		rollupOptions: { external: [/^@umbraco/] },
	},
});
EOF
cat > client/public/umbraco-package.json <<'EOF'
{
  "name": "StatusBoard",
  "version": "2.3.0",
  "extensions": [
    {
      "type": "backofficeEntryPoint",
      "alias": "StatusBoard.EntryPoint",
      "name": "Status Board entry point",
      "js": "/App_Plugins/StatusBoard/entry.js"
    },
    {
      "type": "dashboard",
      "alias": "StatusBoard.Dashboard",
      "name": "Status Board",
      "element": "/App_Plugins/StatusBoard/dashboard.js",
      "meta": { "label": "Status", "pathname": "status" },
      "conditions": [{ "alias": "Umb.Condition.SectionAlias", "match": "Umb.Section.Content" }]
    }
  ],
  "importmap": {
    "imports": {
      "@status-board/core": "/App_Plugins/StatusBoard/entry.js"
    }
  }
}
EOF
cat > client/src/api/client.ts <<'EOF'
// Small fetch wrapper for the package's Management API controller.
export interface StatusItem {
	name: string;
	healthy: boolean;
}

let baseUrl = '';
let token: () => Promise<string | undefined> = async () => undefined;

export function configureStatusClient(config: { baseUrl: string; token: () => Promise<string | undefined> }) {
	baseUrl = config.baseUrl;
	token = config.token;
}

export async function getStatus(): Promise<StatusItem[]> {
	const response = await fetch(`${baseUrl}/umbraco/status-board/api/v1/status`, {
		headers: { Authorization: `Bearer ${await token()}` },
	});
	if (!response.ok) throw new Error(`Status request failed: ${response.status}`);
	return response.json();
}
EOF
cat > client/src/api/index.ts <<'EOF'
export * from './client.js';
EOF
cat > client/src/entry.ts <<'EOF'
import type { UmbEntryPointOnInit } from '@umbraco-cms/backoffice/extension-api';
import { UMB_AUTH_CONTEXT } from '@umbraco-cms/backoffice/auth';
import { configureStatusClient } from './api/index.js';

let markClientReady: () => void;

/** Resolves once the status client has a server URL and a token. */
export const clientReady = new Promise<void>((resolve) => (markClientReady = resolve));

// Public API for other packages, through the "@status-board/core" import map entry.
export * from './api/index.js';

export const onInit: UmbEntryPointOnInit = (host) => {
	host.consumeContext(UMB_AUTH_CONTEXT, (auth) => {
		if (!auth) return;
		const config = auth.getOpenApiConfiguration();
		configureStatusClient({ baseUrl: config.base, token: config.token });
		markClientReady();
	});
};
EOF
cat > client/src/dashboard/dashboard.element.ts <<'EOF'
import { css, customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { getStatus, type StatusItem } from '../api/index.js';

@customElement('status-board-dashboard')
export class StatusBoardDashboardElement extends UmbLitElement {
	@state() private _items: StatusItem[] = [];
	@state() private _error?: string;

	override async connectedCallback() {
		super.connectedCallback();
		try {
			this._items = await getStatus();
		} catch (e) {
			this._error = (e as Error).message;
		}
	}

	override render() {
		if (this._error) return html`<uui-box headline="Status">${this._error}</uui-box>`;
		return html`<uui-box headline="Status">
			<ul>
				${this._items.map((i) => html`<li>${i.name}: ${i.healthy ? 'OK' : 'Down'}</li>`)}
			</ul>
		</uui-box>`;
	}

	static override styles = css`
		:host {
			display: block;
			padding: var(--uui-size-layout-1);
		}
	`;
}

export default StatusBoardDashboardElement;

declare global {
	interface HTMLElementTagNameMap {
		'status-board-dashboard': StatusBoardDashboardElement;
	}
}
EOF
