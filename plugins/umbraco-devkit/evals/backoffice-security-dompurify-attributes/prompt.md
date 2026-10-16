---
description: DOMPurify custom-element config that lets on* event handlers through. From Umbraco-CMS advisory GHSA-vrqc-59mw-qqg7.
tags: [umbraco-backoffice-security, should-trigger, real-bug]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 backoffice extension renders editor-written help text that may contain our
own `my-pkg-*` custom elements, so I set up DOMPurify to allow them. Review the sanitizer.

```ts
import DOMPurify from 'dompurify';

const purifier = DOMPurify();
const config = {
  CUSTOM_ELEMENT_HANDLING: {
    tagNameCheck: /^my-pkg-/,
    attributeNameCheck: /.+/,
    allowCustomizedBuiltInElements: false,
  },
};

export const sanitizeHelpText = (markup: string) => purifier.sanitize(markup, config);
```
