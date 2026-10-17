#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/lang client/src/subscribers
cat > client/package.json <<'EOF'
{
  "name": "shop-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/subscribers/subscribers-list.element.ts <<'EOF'
import { css, customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { SubscribersRepository, type Subscriber } from './subscribers.repository.js';

@customElement('shop-subscribers-list')
export class ShopSubscribersListElement extends UmbLitElement {
	#repo = new SubscribersRepository(this);
	@state() private _items: Subscriber[] = [];
	@state() private _selection: string[] = [];

	override connectedCallback() {
		super.connectedCallback();
		this.#load();
	}

	async #load() {
		const { data } = await this.#repo.requestAll();
		this._items = data ?? [];
	}

	#toggle(id: string, on: boolean) {
		this._selection = on ? [...this._selection, id] : this._selection.filter((s) => s !== id);
	}

	override render() {
		return html`
			<uui-box headline=${this.localize.term('shop_subscribers')}>
				<uui-table>
					<uui-table-head>
						<uui-table-head-cell></uui-table-head-cell>
						<uui-table-head-cell>${this.localize.term('shop_email')}</uui-table-head-cell>
						<uui-table-head-cell>${this.localize.term('shop_subscribedOn')}</uui-table-head-cell>
					</uui-table-head>
					${this._items.map((s) => html`
						<uui-table-row>
							<uui-table-cell>
								<uui-checkbox label=${this.localize.term('shop_selectSubscriber', s.email)}
									@change=${(e: Event) => this.#toggle(s.id, (e.target as HTMLInputElement).checked)}></uui-checkbox>
							</uui-table-cell>
							<uui-table-cell>${s.email}</uui-table-cell>
							<uui-table-cell>${s.subscribedOn}</uui-table-cell>
						</uui-table-row>`)}
				</uui-table>
			</uui-box>`;
	}

	static override styles = css`:host { display: block; }`;
}
export default ShopSubscribersListElement;
EOF
cat > client/src/subscribers/subscribers.repository.ts <<'EOF'
import type { UmbControllerHost } from '@umbraco-cms/backoffice/controller-api';

  export interface Subscriber { id: string; email: string; subscribedOn: string; }
  export class SubscribersRepository {
  	constructor(host: UmbControllerHost) {}
  	async requestAll(): Promise<{ data?: Subscriber[]; error?: Error }> { return { data: [] }; }
  	async exportCsv(): Promise<{ data?: Blob; error?: Error }> { return {}; }
  	async unsubscribe(ids: string[]): Promise<{ error?: Error }> { return {}; }
  }
EOF
cat > client/src/lang/en.ts <<'EOF'
export default {
	shop: {
		subscribers: 'Subscribers',
		email: 'Email',
		subscribedOn: 'Subscribed on',
		selectSubscriber: 'Select %0%',
	},
};
EOF
