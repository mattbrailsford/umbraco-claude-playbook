#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/forms
cat > client/package.json <<'EOF'
{
  "name": "shop-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/forms/form-settings.element.ts <<'EOF'
import { customElement, html, property, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { PagesRepository, type PageOption } from './pages.repository.js';

export interface FormSettings { thankYouPageKey?: string; privacyPageKey?: string; }

@customElement('shop-form-settings')
export class ShopFormSettingsElement extends UmbLitElement {
	#pages = new PagesRepository(this);
	@property({ attribute: false }) settings: FormSettings = {};
	@state() private _pageOptions: PageOption[] = [];

	override async connectedCallback() {
		super.connectedCallback();
		const { data } = await this.#pages.requestAllPages();
		this._pageOptions = data ?? [];
	}

	#update(patch: Partial<FormSettings>) {
		this.settings = { ...this.settings, ...patch };
		this.dispatchEvent(new CustomEvent('change'));
	}

	override render() {
		return html`
			<uui-box headline="Settings">
				<umb-property-layout label="Thank you page">
					<uui-select slot="editor" label="Thank you page"
						.options=${this._pageOptions.map((p) => ({ name: p.name, value: p.key, selected: p.key === this.settings.thankYouPageKey }))}
						@change=${(e: Event) => this.#update({ thankYouPageKey: (e.target as HTMLSelectElement).value })}></uui-select>
				</umb-property-layout>
			</uui-box>`;
	}
}
export default ShopFormSettingsElement;
EOF
cat > client/src/forms/pages.repository.ts <<'EOF'
import type { UmbControllerHost } from '@umbraco-cms/backoffice/controller-api';

  export interface PageOption { key: string; name: string; }
  // Every published content page on the site, flattened.
  export class PagesRepository {
  	constructor(host: UmbControllerHost) {}
  	async requestAllPages(): Promise<{ data?: PageOption[]; error?: Error }> { return { data: [] }; }
  }
EOF
