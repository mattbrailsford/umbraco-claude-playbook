#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/lang client/src/settings
cat > client/package.json <<'EOF'
{
  "name": "shop-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/settings/settings-view.element.ts <<'EOF'
import { css, customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

interface Licence { expiresInDays: number; }

@customElement('shop-settings-view')
export class ShopSettingsViewElement extends UmbLitElement {
	@state() private _hasApiKey = false;
	@state() private _licence: Licence = { expiresInDays: 12 };

	override render() {
		return html`
			${this._hasApiKey ? '' : html`
				<div class="banner banner-info">
					<uui-icon name="icon-info"></uui-icon>
					<span>${this.localize.term('shop_apiKeyMissing')}</span>
				</div>`}
			<uui-box headline=${this.localize.term('shop_settings')}>
				<slot></slot>
			</uui-box>`;
	}

	static override styles = css`
		:host { display: block; padding: var(--uui-size-layout-1); }
		.banner {
			display: flex;
			gap: 8px;
			align-items: center;
			padding: 12px 16px;
			margin-bottom: 16px;
			border-radius: 3px;
		}
		.banner-info {
			background: #e8f1fb;
			color: #1b264f;
			border-left: 4px solid #3544b1;
		}
	`;
}
export default ShopSettingsViewElement;
EOF
cat > client/src/lang/en.ts <<'EOF'
export default { shop: { settings: 'Settings', apiKeyMissing: 'Add your API key to start syncing.' } };
EOF
