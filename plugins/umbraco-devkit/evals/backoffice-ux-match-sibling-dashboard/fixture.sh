#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src client/src/customers client/src/lang client/src/orders
cat > client/package.json <<'EOF'
{
  "name": "shop-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/orders/orders-dashboard.element.ts <<'EOF'
import { css, customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { OrdersRepository, type Order } from './orders.repository.js';

@customElement('shop-orders-dashboard')
export class ShopOrdersDashboardElement extends UmbLitElement {
	#repo = new OrdersRepository(this);
	@state() private _orders: Order[] = [];

	override async connectedCallback() {
		super.connectedCallback();
		const { data } = await this.#repo.requestAll();
		this._orders = data ?? [];
	}

	override render() {
		return html`
			<uui-box headline=${this.localize.term('shop_ordersHeadline')}>
				<uui-button slot="header-actions" look="secondary" compact
					label=${this.localize.term('shop_refresh')} @click=${() => this.connectedCallback()}>
					<uui-icon name="icon-refresh"></uui-icon>
				</uui-button>
				<uui-table>
					<uui-table-head>
						<uui-table-head-cell>${this.localize.term('shop_orderNumber')}</uui-table-head-cell>
						<uui-table-head-cell>${this.localize.term('shop_total')}</uui-table-head-cell>
					</uui-table-head>
					${this._orders.map((o) => html`
						<uui-table-row>
							<uui-table-cell>${o.number}</uui-table-cell>
							<uui-table-cell>${o.total}</uui-table-cell>
						</uui-table-row>`)}
				</uui-table>
			</uui-box>`;
	}

	static override styles = css`
		:host { display: block; padding: var(--uui-size-layout-1); }
		uui-box { --uui-box-default-padding: 0; }
	`;
}
export default ShopOrdersDashboardElement;
EOF
cat > client/src/orders/orders.repository.ts <<'EOF'
import type { UmbControllerHost } from '@umbraco-cms/backoffice/controller-api';

  export interface Order { id: string; number: string; total: string; }
  export class OrdersRepository {
  	constructor(host: UmbControllerHost) {}
  	async requestAll(): Promise<{ data?: Order[]; error?: Error }> { return { data: [] }; }
  }
EOF
cat > client/src/customers/customers.repository.ts <<'EOF'
import type { UmbControllerHost } from '@umbraco-cms/backoffice/controller-api';

  export interface Customer { id: string; name: string; email: string; orderCount: number; }
  // Both return { data, error } and never throw.
  export class CustomersRepository {
  	constructor(host: UmbControllerHost) {}
  	async requestAll(): Promise<{ data?: Customer[]; error?: Error }> { return { data: [] }; }
  	async exportCsv(): Promise<{ data?: Blob; error?: Error }> { return {}; }
  }
EOF
cat > client/src/manifests.ts <<'EOF'
export const manifests: Array<UmbExtensionManifest> = [
	{
		type: 'dashboard',
		alias: 'Shop.Dashboard.Orders',
		name: 'Shop Orders Dashboard',
		element: () => import('./orders/orders-dashboard.element.js'),
		meta: { label: '#shop_ordersDashboard', pathname: 'orders' },
		conditions: [{ alias: 'Umb.Condition.SectionAlias', match: 'Shop.Section' }],
	},
];
EOF
cat > client/src/lang/en.ts <<'EOF'
export default {
	shop: {
		ordersDashboard: 'Orders',
		ordersHeadline: 'Orders',
		refresh: 'Refresh',
		orderNumber: 'Order number',
		total: 'Total',
	},
};
EOF
