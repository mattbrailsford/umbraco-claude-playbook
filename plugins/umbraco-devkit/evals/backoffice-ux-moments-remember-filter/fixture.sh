#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/campaigns
cat > client/package.json <<'EOF'
{
  "name": "shop-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/campaigns/campaigns-dashboard.element.ts <<'EOF'
import { customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { CampaignsRepository, type CampaignSummary } from './campaigns.repository.js';

@customElement('shop-campaigns-dashboard')
export class ShopCampaignsDashboardElement extends UmbLitElement {
	#repo = new CampaignsRepository(this);
	@state() private _items: CampaignSummary[] = [];

	override async connectedCallback() {
		super.connectedCallback();
		const { data } = await this.#repo.requestAll();
		this._items = data ?? [];
	}

	override render() {
		return html`
			<uui-box headline="Campaigns">
				<uui-table>
					<uui-table-head>
						<uui-table-head-cell>Name</uui-table-head-cell>
						<uui-table-head-cell>Status</uui-table-head-cell>
						<uui-table-head-cell>Created</uui-table-head-cell>
					</uui-table-head>
					${this._items.map((c) => html`
						<uui-table-row>
							<uui-table-cell>${c.name}</uui-table-cell>
							<uui-table-cell>${c.status}</uui-table-cell>
							<uui-table-cell>${c.createdUtc}</uui-table-cell>
						</uui-table-row>`)}
				</uui-table>
			</uui-box>`;
	}
}
export default ShopCampaignsDashboardElement;
EOF
cat > client/src/campaigns/campaigns.repository.ts <<'EOF'
import type { UmbControllerHost } from '@umbraco-cms/backoffice/controller-api';

  export interface CampaignSummary { id: string; name: string; status: 'draft' | 'scheduled' | 'sent'; createdUtc: string; }
  export class CampaignsRepository {
  	constructor(host: UmbControllerHost) {}
  	async requestAll(): Promise<{ data?: CampaignSummary[]; error?: Error }> { return { data: [] }; }
  }
EOF
