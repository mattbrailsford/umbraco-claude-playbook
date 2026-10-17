#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/notes client/src/components
cat > client/package.json <<'EOF'
{
  "name": "editorial-notes-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/components/mention.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** <notes-mention user-key="..." display-name="Ana">@Ana</notes-mention> */
@customElement('notes-mention')
export class NotesMentionElement extends UmbLitElement {
	@property({ attribute: 'user-key' }) userKey = '';
	@property({ attribute: 'display-name' }) displayName = '';
	override render() {
		return html`<uui-tag look="secondary">@${this.displayName}</uui-tag>`;
	}
}
EOF
cat > client/src/components/doc-link.element.ts <<'EOF'
import { customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

/** <notes-doc-link document-key="...">Page name</notes-doc-link> */
@customElement('notes-doc-link')
export class NotesDocLinkElement extends UmbLitElement {
	@property({ attribute: 'document-key' }) documentKey = '';
	override render() {
		return html`<a href="#/content/edit/${this.documentKey}"><slot></slot></a>`;
	}
}
EOF
cat > client/src/notes/note-list.element.ts <<'EOF'
import { css, customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

export interface EditorialNote {
	id: string;
	author: string;
	createdAt: string;
	/** Markdown written by editors. May contain <notes-mention> and <notes-doc-link> tags. */
	body: string;
}

/** Lists the editorial notes on a document. */
@customElement('notes-note-list')
export class NotesNoteListElement extends UmbLitElement {
	@property({ type: Array }) notes: EditorialNote[] = [];

	override render() {
		return html`${this.notes.map(
			(note) => html`<article>
				<header>${note.author} · ${note.createdAt}</header>
				<pre>${note.body}</pre>
			</article>`,
		)}`;
	}

	static override styles = css`
		article {
			padding: var(--uui-size-space-4) 0;
			border-bottom: 1px solid var(--uui-color-border);
		}
	`;
}

export default NotesNoteListElement;
EOF
