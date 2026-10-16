#!/usr/bin/env bash
set -euo pipefail
mkdir -p client/src/items/modals client/src/lang
cat > client/package.json <<'EOF'
{
  "name": "my-package-client",
  "private": true,
  "type": "module",
  "devDependencies": { "@umbraco-cms/backoffice": "^17.6.0", "typescript": "^5.9.0", "vite": "^7.0.0" }
}
EOF
cat > client/src/lang/en.ts <<'EOF'
export default {
	myPackage: {
		confirmDelete: 'Delete <strong>%0%</strong>? This cannot be undone.',
		deleteHeadline: 'Delete item',
	},
};
EOF
cat > client/src/items/modals/delete-item-modal.token.ts <<'EOF'
import { UmbModalToken } from '@umbraco-cms/backoffice/modal';

export interface MyDeleteItemModalData {
	item: { id: string; name: string };
}

export const MY_DELETE_ITEM_MODAL = new UmbModalToken<MyDeleteItemModalData, never>('MyPackage.Modal.DeleteItem', {
	modal: { type: 'dialog' },
});
EOF
cat > client/src/items/modals/delete-item-modal.element.ts <<'EOF'
import { customElement } from '@umbraco-cms/backoffice/external/lit';
import { UmbModalBaseElement } from '@umbraco-cms/backoffice/modal';
import type { MyDeleteItemModalData } from './delete-item-modal.token.js';

@customElement('my-delete-item-modal')
export class MyDeleteItemModalElement extends UmbModalBaseElement<MyDeleteItemModalData, never> {
	// TODO: render the confirm step
}

export default MyDeleteItemModalElement;
EOF
