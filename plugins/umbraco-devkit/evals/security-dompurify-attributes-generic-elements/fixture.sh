#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/rich-text client/src/components
cat > client/package.json <<'EOF'
{
  "name": "content-blocks-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/rich-text/sanitize-editor-html.ts <<'EOF'
import { DOMPurify } from '@umbraco-cms/backoffice/external/dompurify';

/**
 * Sanitizes editor-written HTML for the block previews. Allows our own elements.
 * Every time we add an element we have to add it (and its attributes) here.
 */
export function sanitizeEditorHtml(html: string): string {
	return DOMPurify.sanitize(html, {
		ADD_TAGS: ['cb-tooltip', 'cb-callout'],
		ADD_ATTR: ['text', 'variant'],
	});
}
EOF
cat > client/src/components/tooltip.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** <cb-tooltip text="More info">term</cb-tooltip> */
@customElement('cb-tooltip')
export class CbTooltipElement extends UmbLitElement {
	@property() text = '';
	override render() {
		return html`<span title=${this.text}><slot></slot></span>`;
	}
}
EOF
cat > client/src/components/callout.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** <cb-callout variant="warning">Text</cb-callout> */
@customElement('cb-callout')
export class CbCalloutElement extends UmbLitElement {
	@property() variant: 'info' | 'warning' = 'info';
	override render() {
		return html`<uui-box><slot></slot></uui-box>`;
	}
}
EOF
cat > client/src/components/product-card.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** <cb-product-card product-key="..." show-price layout="compact"></cb-product-card> */
@customElement('cb-product-card')
export class CbProductCardElement extends UmbLitElement {
	@property({ attribute: 'product-key' }) productKey = '';
	@property({ type: Boolean, attribute: 'show-price' }) showPrice = false;
	@property() layout: 'compact' | 'full' = 'full';
	override render() {
		return html`<div>${this.productKey}</div>`;
	}
}
EOF
