#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/stock
cat > client/package.json <<'EOF'
{
  "name": "shop-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/stock/manifests.ts <<'EOF'
export const manifests: Array<UmbExtensionManifest> = [
	{
		type: 'workspaceView',
		alias: 'Shop.WorkspaceView.Stock',
		name: 'Stock',
		element: () => import('./stock-view.element.js'),
		meta: { label: 'Stock', pathname: 'stock', icon: 'icon-box' },
		conditions: [{ alias: 'Umb.Condition.WorkspaceAlias', match: 'Shop.Workspace.Product' }],
	},
	{
		type: 'workspaceInfoApp',
		alias: 'Shop.WorkspaceInfoApp.Stock',
		name: 'Stock info app',
		element: () => import('./stock-info-app.element.js'),
		weight: 100,
		conditions: [{ alias: 'Umb.Condition.WorkspaceAlias', match: 'Shop.Workspace.Product' }],
	},
];
EOF
cat > client/src/stock/stock-view.element.ts <<'EOF'
import { customElement, html } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import './stock-summary.element.js';

@customElement('shop-stock-view')
export class ShopStockViewElement extends UmbLitElement {
	override render() {
		return html`<uui-box headline="Stock"><shop-stock-summary .summary=${{ inStock: 120, reserved: 8, onOrder: 40, soldThisMonth: 310 }}></shop-stock-summary></uui-box>`;
	}
}
export default ShopStockViewElement;
EOF
cat > client/src/stock/stock-info-app.element.ts <<'EOF'
import { customElement, html } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import './stock-summary.element.js';

// Rendered in the product workspace's info sidebar, next to "General" and "History".
@customElement('shop-stock-info-app')
export class ShopStockInfoAppElement extends UmbLitElement {
	override render() {
		return html`<uui-box headline="Stock"><shop-stock-summary .summary=${{ inStock: 120, reserved: 8, onOrder: 40, soldThisMonth: 310 }}></shop-stock-summary></uui-box>`;
	}
}
export default ShopStockInfoAppElement;
EOF
