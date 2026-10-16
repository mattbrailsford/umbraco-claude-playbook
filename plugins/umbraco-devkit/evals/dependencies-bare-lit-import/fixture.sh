#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/elements
cat > client/package.json <<'EOF'
{
  "name": "order-status-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "tsc && vite build" },
  "dependencies": { "lit": "^3.3.0" },
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';

export default defineConfig({
	build: {
		lib: { entry: 'src/index.ts', formats: ['es'], fileName: 'order-status' },
		outDir: '../wwwroot/App_Plugins/OrderStatus',
		emptyOutDir: true,
		rollupOptions: { external: [/^@umbraco/] },
	},
});
EOF
cat > client/src/elements/order-summary.element.ts <<'EOF'
import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('order-status-summary')
export class OrderSummaryElement extends LitElement {
	@property() orderNumber = '';
	@property({ type: Number }) total = 0;

	override render() {
		return html`<uui-box headline="Order ${this.orderNumber}">Total: ${this.total.toFixed(2)}</uui-box>`;
	}

	static override styles = css`
		:host {
			display: block;
		}
	`;
}
EOF
cat > client/src/index.ts <<'EOF'
export * from './elements/order-summary.element.js';
EOF
