---
description: Content from the package's own backend (RTE or AI output) still needs sanitizing before unsafeHTML.
tags: [security-lit, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Quick review of this Umbraco backoffice element. It previews an AI-written summary of a
page's rich text. The HTML comes from our own Management API endpoint, so I assume it's
trusted. Anything I must change?

```typescript
import { html, LitElement } from '@umbraco-cms/backoffice/external/lit';
import { unsafeHTML } from '@umbraco-cms/backoffice/external/lit';
import { customElement, property } from '@umbraco-cms/backoffice/external/lit';

@customElement('my-summary-preview')
export class MySummaryPreviewElement extends LitElement {
  @property() summaryHtml = '';

  render() {
    return html`<div class="preview">${unsafeHTML(this.summaryHtml)}</div>`;
  }
}
```
