#!/usr/bin/env bash
set -euo pipefail
c=client
mkdir -p $c/src/property-editors/release-notes $c/src/shared $c/public
cat > $c/package.json <<'EOF'
{
  "name": "release-notes-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "tsc && vite build" },
  "dependencies": { "marked": "^15.0.0", "dompurify": "^3.2.0" },
  "devDependencies": { "@umbraco-cms/backoffice": "^17.0.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > $c/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';

export default defineConfig({
	build: {
		lib: { entry: 'src/index.ts', formats: ['es'], fileName: 'release-notes' },
		outDir: '../wwwroot/App_Plugins/ReleaseNotes',
		emptyOutDir: true,
		rollupOptions: { external: [/^@umbraco/] },
	},
});
EOF
cat > $c/public/umbraco-package.json <<'EOF'
{
  "name": "ReleaseNotes",
  "version": "1.2.0",
  "extensions": [
    {
      "type": "propertyEditorUi",
      "alias": "ReleaseNotes.PropertyEditorUi.Notes",
      "name": "Release notes editor",
      "element": "/App_Plugins/ReleaseNotes/release-notes.js",
      "elementName": "release-notes-property-editor-ui",
      "meta": {
        "label": "Release notes",
        "icon": "icon-notepad",
        "group": "richContent",
        "propertyEditorSchemaAlias": "Umbraco.TextArea"
      }
    }
  ]
}
EOF
cat > $c/src/property-editors/release-notes/release-notes-property-editor-ui.element.ts <<'EOF'
import { css, customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { UmbChangeEvent } from '@umbraco-cms/backoffice/event';
import type { UmbPropertyEditorUiElement } from '@umbraco-cms/backoffice/property-editor';

/** Editors write release notes in Markdown. */
@customElement('release-notes-property-editor-ui')
export class ReleaseNotesPropertyEditorUiElement extends UmbLitElement implements UmbPropertyEditorUiElement {
	@property() value?: string;

	#onInput(e: InputEvent) {
		this.value = (e.target as HTMLTextAreaElement).value;
		this.dispatchEvent(new UmbChangeEvent());
	}

	override render() {
		return html`<uui-textarea .value=${this.value ?? ''} @input=${this.#onInput} auto-height></uui-textarea>`;
	}

	static override styles = css`
		:host {
			display: block;
		}
	`;
}

export default ReleaseNotesPropertyEditorUiElement;
EOF
cat > $c/src/index.ts <<'EOF'
export * from './property-editors/release-notes/release-notes-property-editor-ui.element.js';
EOF
