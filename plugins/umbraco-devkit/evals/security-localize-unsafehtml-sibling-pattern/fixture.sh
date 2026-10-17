#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/library/modals client/src/lang
cat > client/package.json <<'EOF'
{
  "name": "asset-library-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/lang/en.ts <<'EOF'
export default {
	assetLibrary: {
		confirmArchive: 'Archive <strong>%0%</strong>? Editors will no longer be able to pick it.',
		archiveHeadline: 'Archive asset',
		confirmMove: 'Move <strong>%0%</strong> into <strong>%1%</strong>?',
		moveHeadline: 'Move asset',
		cancel: 'Cancel',
	},
};
EOF
cat > client/src/library/modals/archive-asset-modal.element.ts <<'EOF'
import { css, customElement, html, unsafeHTML } from '@umbraco-cms/backoffice/external/lit';
import { UmbModalBaseElement } from '@umbraco-cms/backoffice/modal';
import type { ArchiveAssetModalData } from './archive-asset-modal.token.js';

@customElement('asset-library-archive-modal')
export class AssetLibraryArchiveModalElement extends UmbModalBaseElement<ArchiveAssetModalData, never> {
	override render() {
		return html`
			<uui-dialog-layout headline=${this.localize.term('assetLibrary_archiveHeadline')}>
				<p>${unsafeHTML(this.localize.string('#assetLibrary_confirmArchive', this.data?.asset.name ?? ''))}</p>
				<uui-button slot="actions" label=${this.localize.term('assetLibrary_cancel')} @click=${this._rejectModal}></uui-button>
				<uui-button slot="actions" look="primary" color="warning" label="Archive" @click=${this._submitModal}></uui-button>
			</uui-dialog-layout>
		`;
	}

	static override styles = css`
		p {
			margin: 0;
		}
	`;
}

export default AssetLibraryArchiveModalElement;
EOF
cat > client/src/library/modals/archive-asset-modal.token.ts <<'EOF'
import { UmbModalToken } from '@umbraco-cms/backoffice/modal';

export interface ArchiveAssetModalData {
	asset: { id: string; name: string };
}

export const ASSET_LIBRARY_ARCHIVE_MODAL = new UmbModalToken<ArchiveAssetModalData, never>('AssetLibrary.Modal.Archive', {
	modal: { type: 'dialog' },
});
EOF
cat > client/src/library/modals/manifests.ts <<'EOF'
export const manifests: Array<UmbExtensionManifest> = [
	{
		type: 'modal',
		alias: 'AssetLibrary.Modal.Archive',
		name: 'Asset Library Archive Modal',
		element: () => import('./archive-asset-modal.element.js'),
	},
];
EOF
