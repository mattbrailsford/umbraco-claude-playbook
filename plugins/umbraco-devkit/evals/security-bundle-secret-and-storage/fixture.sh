#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/vendor client/src/dashboard src/MyPackage
cat > client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build" },
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/.env <<'EOF'
VITE_VENDOR_BASE_URL=https://api.coolvendor.example
VITE_VENDOR_SECRET_KEY=sk_live_REPLACE_ME
EOF
cat > client/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';

export default defineConfig({
	build: {
		lib: { entry: 'src/index.ts', formats: ['es'] },
		outDir: '../src/MyPackage/wwwroot/App_Plugins/MyPackage',
		rollupOptions: { external: [/^@umbraco/] },
	},
});
EOF
cat > client/src/vendor/README.md <<'EOF'
# CoolVendor API

- Token: `POST {base}/oauth/token` with header `Authorization: Bearer <secret key>`.
  Returns `{ "access_token": "...", "expires_in": 3600 }`.
- Products: `GET {base}/v2/products` with header `Authorization: Bearer <access_token>`.
  Returns `[{ "sku": "...", "name": "...", "stock": 0 }]`.
- Rate limit: 10 token requests per minute per account.
EOF
cat > client/src/dashboard/vendor-products-dashboard.element.ts <<'EOF'
import { customElement, html, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

interface VendorProduct {
	sku: string;
	name: string;
	stock: number;
}

@customElement('my-vendor-products-dashboard')
export class MyVendorProductsDashboardElement extends UmbLitElement {
	@state() private _products: VendorProduct[] = [];

	// TODO: load products from CoolVendor

	override render() {
		return html`<uui-box headline="CoolVendor products">
			${this._products.map((p) => html`<div>${p.sku} ${p.name}: ${p.stock}</div>`)}
		</uui-box>`;
	}
}

export default MyVendorProductsDashboardElement;
EOF
