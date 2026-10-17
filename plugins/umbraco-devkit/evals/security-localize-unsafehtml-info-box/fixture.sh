#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/campaigns/workspace client/src/lang
cat > client/package.json <<'EOF'
{
  "name": "campaigns-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/lang/en.ts <<'EOF'
export default {
	campaigns: {
		infoHeadline: 'Info',
		status: 'Status',
		lastEdited: 'Last edited by <strong>%0%</strong> on %1%',
		createdFrom: 'Created from the <em>%0%</em> template',
		recipients: 'Recipients',
	},
};
EOF
cat > client/src/campaigns/workspace/campaign.model.ts <<'EOF'
export interface CampaignModel {
	id: string;
	name: string;
	status: 'draft' | 'scheduled' | 'sent';
	recipientCount: number;
	/** Display name of the backoffice user who last saved it. Users set their own names. */
	lastEditedBy: string;
	lastEditedAt: string;
	/** Name of the template it was created from. Editors name templates. */
	templateName: string;
}
EOF
cat > client/src/campaigns/workspace/campaign-info.element.ts <<'EOF'
import { css, customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import type { CampaignModel } from './campaign.model.js';
import { CAMPAIGN_WORKSPACE_CONTEXT } from './campaign-workspace.context-token.js';

/** The Info workspace view of a campaign. */
@customElement('campaigns-campaign-info')
export class CampaignsCampaignInfoElement extends UmbLitElement {
	@state() private _campaign?: CampaignModel;

	constructor() {
		super();
		this.consumeContext(CAMPAIGN_WORKSPACE_CONTEXT, (context) => {
			this.observe(context?.data, (data) => (this._campaign = data));
		});
	}

	override render() {
		if (!this._campaign) return html`<uui-loader></uui-loader>`;
		return html`
			<uui-box headline=${this.localize.term('campaigns_infoHeadline')}>
				<dl>
					<dt>${this.localize.term('campaigns_status')}</dt>
					<dd><uui-tag>${this._campaign.status}</uui-tag></dd>
					<dt>${this.localize.term('campaigns_recipients')}</dt>
					<dd>${this.localize.number(this._campaign.recipientCount)}</dd>
				</dl>
			</uui-box>
		`;
	}

	static override styles = css`
		dl {
			display: grid;
			grid-template-columns: max-content 1fr;
			gap: var(--uui-size-space-2) var(--uui-size-space-5);
			margin: 0;
		}
	`;
}

export default CampaignsCampaignInfoElement;
EOF
cat > client/src/campaigns/workspace/campaign-workspace.context-token.ts <<'EOF'
import { UmbContextToken } from '@umbraco-cms/backoffice/context-api';
import type { Observable } from '@umbraco-cms/backoffice/external/rxjs';
import type { CampaignModel } from './campaign.model.js';

export interface CampaignWorkspaceContext {
	data: Observable<CampaignModel | undefined>;
}

export const CAMPAIGN_WORKSPACE_CONTEXT = new UmbContextToken<CampaignWorkspaceContext>('UmbWorkspaceContext', 'Campaigns.Workspace');
EOF
