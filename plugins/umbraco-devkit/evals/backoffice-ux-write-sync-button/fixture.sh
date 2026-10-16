#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/sync
cat > client/src/sync/repository.ts <<'EOF'
import type { UmbControllerHost } from '@umbraco-cms/backoffice/controller-api';

export interface SyncResult { itemsSynced: number; finishedAt: string; }

// Returns { data, error } and never throws. error.message is technical (HTTP status, provider code).
export class MySyncRepository {
	constructor(host: UmbControllerHost) {}
	async syncAll(): Promise<{ data?: SyncResult; error?: Error }> { return {}; }
	async lastSync(): Promise<{ data?: SyncResult; error?: Error }> { return {}; }
}
EOF
cat > client/src/sync/sync-dashboard.element.ts <<'EOF'
import { html, css, customElement, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { MySyncRepository, type SyncResult } from './repository.js';

@customElement('my-sync-dashboard')
export class MySyncDashboardElement extends UmbLitElement {
	#repository = new MySyncRepository(this);

	@state() private _last?: SyncResult;

	override async connectedCallback() {
		super.connectedCallback();
		const { data } = await this.#repository.lastSync();
		this._last = data;
	}

	override render() {
		return html`
			<uui-box headline="Sync">
				<p>${this._last ? `Last synced ${this._last.finishedAt}` : 'Never synced'}</p>
			</uui-box>
		`;
	}

	static override styles = css`
		:host { display: block; padding: var(--uui-size-layout-1); }
	`;
}

export default MySyncDashboardElement;
EOF
