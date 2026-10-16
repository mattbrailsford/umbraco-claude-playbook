#!/usr/bin/env bash
set -euo pipefail
git init -q -b main
git config user.email eval@example.com && git config user.name eval
mkdir -p client/src/summary client/src/shared
cat > client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "vite build" },
  "dependencies": { "dompurify": "^3.2.0" },
  "peerDependencies": { "@umbraco-cms/backoffice": "^17.0.0" },
  "devDependencies": { "vite": "^7.0.0", "typescript": "^5.9.0" }
}
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
cat > client/src/index.ts <<'EOF'
export const manifests: Array<UmbExtensionManifest> = [];
EOF
git add -A && git commit -q -m "chore: client skeleton"

cat > client/src/index.ts <<'EOF'
import { manifests as summaryManifests } from './summary/manifests.js';

export const manifests: Array<UmbExtensionManifest> = [...summaryManifests];
EOF
cat > client/src/summary/manifests.ts <<'EOF'
export const manifests: Array<UmbExtensionManifest> = [
	{
		type: 'workspaceView',
		alias: 'MyPackage.WorkspaceView.AiSummary',
		name: 'My Package AI Summary Workspace View',
		element: () => import('./ai-summary.element.js'),
		weight: 50,
		meta: { label: 'Summary', pathname: 'ai-summary', icon: 'icon-wand' },
		conditions: [{ alias: 'Umb.Condition.WorkspaceAlias', match: 'Umb.Workspace.Document' }],
	},
];
EOF
cat > client/src/shared/openai-client.ts <<'EOF'
const OPENAI_URL = 'https://api.openai.com/v1/chat/completions';
const apiKey = import.meta.env.VITE_OPENAI_API_KEY as string;

export async function summarize(text: string, signal?: AbortSignal): Promise<string> {
	const response = await fetch(OPENAI_URL, {
		method: 'POST',
		signal,
		headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
		body: JSON.stringify({
			model: 'gpt-4.1-mini',
			messages: [
				{ role: 'system', content: 'Summarize the page for an editor. Reply as simple HTML.' },
				{ role: 'user', content: text },
			],
		}),
	});
	if (!response.ok) throw new Error(`Summary failed: ${response.status}`);
	const json = await response.json();
	return json.choices[0].message.content as string;
}
EOF
cat > client/src/shared/sanitize.ts <<'EOF'
import DOMPurify from 'dompurify';

// Editor-written help text can contain our own <my-pkg-*> elements, so let those through.
const purifier = DOMPurify();
const config = {
	CUSTOM_ELEMENT_HANDLING: {
		tagNameCheck: /^my-pkg-/,
		attributeNameCheck: /.+/,
		allowCustomizedBuiltInElements: false,
	},
};

export const sanitizeHelpText = (markup: string) => purifier.sanitize(markup, config);
EOF
cat > client/src/summary/ai-summary.element.ts <<'EOF'
import { html, css, customElement, state, unsafeHTML, when } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import { UMB_DOCUMENT_WORKSPACE_CONTEXT } from '@umbraco-cms/backoffice/document';
import { summarize } from '../shared/openai-client.js';
import { sanitizeHelpText } from '../shared/sanitize.js';

@customElement('my-package-ai-summary')
export class MyPackageAiSummaryElement extends UmbLitElement {
	@state() private _summary?: string;
	@state() private _helpText = '';
	@state() private _loading = false;
	#abort?: AbortController;
	#workspace?: typeof UMB_DOCUMENT_WORKSPACE_CONTEXT.TYPE;

	constructor() {
		super();
		this.consumeContext(UMB_DOCUMENT_WORKSPACE_CONTEXT, (ctx) => {
			this.#workspace = ctx;
		});
		this.#loadHelpText();
	}

	async #loadHelpText() {
		const response = await fetch('/umbraco/management/api/v1/my-package/help-text');
		if (response.ok) this._helpText = sanitizeHelpText(await response.text());
	}

	async #generate() {
		this.#abort?.abort();
		this.#abort = new AbortController();
		this._loading = true;
		try {
			const values = this.#workspace?.getData()?.values ?? [];
			const text = values.map((v) => String(v.value ?? '')).join('\n');
			// The summary comes from the model we call ourselves, so it's trusted markup.
			this._summary = await summarize(text, this.#abort.signal);
		} finally {
			this._loading = false;
		}
	}

	override disconnectedCallback() {
		super.disconnectedCallback();
		this.#abort?.abort();
	}

	override render() {
		return html`
			<uui-box headline=${this.localize.term('myPackage_summaryHeadline')}>
				<div class="help">${unsafeHTML(this._helpText)}</div>
				<uui-button look="primary" label=${this.localize.term('myPackage_generate')} ?disabled=${this._loading} @click=${this.#generate}></uui-button>
				${when(this._summary, (s) => html`<div class="summary">${unsafeHTML(s)}</div>`)}
			</uui-box>
		`;
	}

	static override styles = css`
		.summary { margin-top: var(--uui-size-space-4); }
		.help { color: var(--uui-color-text-alt); }
	`;
}

export default MyPackageAiSummaryElement;
EOF

# git can't run inside the eval sandbox, so hand the reviewer the diff as a file.
git add -A && git diff --cached > CHANGE.diff && git reset -q
