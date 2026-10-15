---
description: unsafeHTML around a localized string with a user-controlled argument. From umbraco/Umbraco-CMS#22731 (GHSA-vr9v-27gg-qgx4).
tags: [security-lit, should-trigger, real-bug]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

This is the confirm step of a delete modal in my Umbraco 17.6 backoffice extension. The
localization term is `'Delete <strong>%0%</strong>? This cannot be undone.'`, so I need
unsafeHTML for the bold to render. `item.name` is the name an editor gave the item.
Review it.

```ts
import { html, unsafeHTML } from '@umbraco-cms/backoffice/external/lit';

render() {
  return html`
    <uui-dialog-layout headline=${this.localize.term('general_delete')}>
      <p>${unsafeHTML(this.localize.string('#myPackage_confirmDelete', this.item.name))}</p>
      <uui-button slot="actions" look="primary" color="danger" @click=${this.#confirm}>
        ${this.localize.term('general_delete')}
      </uui-button>
    </uui-dialog-layout>`;
}
```
