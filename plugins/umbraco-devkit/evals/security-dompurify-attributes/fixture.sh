#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/help-text client/src/components
cat > client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/components/tooltip.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** <my-pkg-tooltip text="More info">term</my-pkg-tooltip> */
@customElement('my-pkg-tooltip')
export class MyPkgTooltipElement extends UmbLitElement {
	@property() text = '';
	override render() {
		return html`<span title=${this.text}><slot></slot></span>`;
	}
}
EOF
cat > client/src/components/badge.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** <my-pkg-badge color="positive" label="New"></my-pkg-badge> */
@customElement('my-pkg-badge')
export class MyPkgBadgeElement extends UmbLitElement {
	@property() color: 'default' | 'positive' | 'warning' | 'danger' = 'default';
	@property() label = '';
	override render() {
		return html`<uui-tag color=${this.color}>${this.label}</uui-tag>`;
	}
}
EOF
cat > client/src/help-text/help-text.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** Shows a data type's help text under the property editor. */
@customElement('my-pkg-help-text')
export class MyPkgHelpTextElement extends UmbLitElement {
	/** Written by editors in the data type settings. */
	@property() markup = '';

	override render() {
		return html`<div class="help">${this.markup}</div>`;
	}
}
EOF
