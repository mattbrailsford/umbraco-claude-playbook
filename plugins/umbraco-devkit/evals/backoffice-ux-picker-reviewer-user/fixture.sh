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
cat > client/src/campaigns/campaign-editor.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

export interface Campaign { id: string; name: string; subject: string; reviewerKey?: string; }

@customElement('shop-campaign-editor')
export class ShopCampaignEditorElement extends UmbLitElement {
	@property({ attribute: false }) campaign!: Campaign;

	#update(patch: Partial<Campaign>) {
		this.campaign = { ...this.campaign, ...patch };
		this.dispatchEvent(new CustomEvent('change'));
	}

	override render() {
		return html`
			<uui-box headline="Campaign">
				<umb-property-layout label="Name">
					<uui-input slot="editor" .value=${this.campaign.name}
						@input=${(e: InputEvent) => this.#update({ name: (e.target as HTMLInputElement).value })}></uui-input>
				</umb-property-layout>
				<umb-property-layout label="Subject">
					<uui-input slot="editor" .value=${this.campaign.subject}
						@input=${(e: InputEvent) => this.#update({ subject: (e.target as HTMLInputElement).value })}></uui-input>
				</umb-property-layout>
			</uui-box>`;
	}
}
export default ShopCampaignEditorElement;
EOF
