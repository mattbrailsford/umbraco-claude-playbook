#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/loyalty
cat > client/package.json <<'EOF'
{
  "name": "shop-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/loyalty/types.ts <<'EOF'
export interface LoyaltyStatus {
	tier: 'bronze' | 'silver' | 'gold';
	points: number;
	/** Points needed to reach the next tier; null at gold. */
	pointsToNextTier: number | null;
	memberSince: string; // ISO date
}
EOF
cat > client/src/loyalty/manifests.ts <<'EOF'
export const manifests: Array<UmbExtensionManifest> = [
	{
		type: 'workspaceView',
		alias: 'Shop.WorkspaceView.CustomerLoyalty',
		name: 'Customer loyalty',
		element: () => import('./customer-loyalty-view.element.js'),
		meta: { label: 'Loyalty', pathname: 'loyalty', icon: 'icon-medal' },
		conditions: [{ alias: 'Umb.Condition.WorkspaceAlias', match: 'Shop.Workspace.Customer' }],
	},
	{
		// Shows in the order workspace's info sidebar.
		type: 'workspaceInfoApp',
		alias: 'Shop.WorkspaceInfoApp.OrderCustomerLoyalty',
		name: 'Order customer loyalty',
		element: () => import('./order-loyalty-info-app.element.js'),
		weight: 90,
		conditions: [{ alias: 'Umb.Condition.WorkspaceAlias', match: 'Shop.Workspace.Order' }],
	},
];
EOF
cat > client/src/loyalty/customer-loyalty-view.element.ts <<'EOF'
import { customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import type { LoyaltyStatus } from './types.js';

@customElement('shop-customer-loyalty-view')
export class ShopCustomerLoyaltyViewElement extends UmbLitElement {
	// Filled from the customer workspace context elsewhere.
	@state() private _status?: LoyaltyStatus;

	override render() {
		return html`<uui-box headline="Loyalty">TODO</uui-box>`;
	}
}

export default ShopCustomerLoyaltyViewElement;
EOF
cat > client/src/loyalty/order-loyalty-info-app.element.ts <<'EOF'
import { customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import type { LoyaltyStatus } from './types.js';

@customElement('shop-order-loyalty-info-app')
export class ShopOrderLoyaltyInfoAppElement extends UmbLitElement {
	// Filled from the order's customer elsewhere.
	@state() private _status?: LoyaltyStatus;

	override render() {
		return html`<uui-box headline="Customer loyalty">TODO</uui-box>`;
	}
}

export default ShopOrderLoyaltyInfoAppElement;
EOF
