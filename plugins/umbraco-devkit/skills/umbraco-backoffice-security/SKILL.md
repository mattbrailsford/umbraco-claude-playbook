---
name: umbraco-backoffice-security
description: >-
  Umbraco's own tools for keeping a backoffice extension safe: sanitizeHTML and escapeHTML,
  localize.htmlString for terms with markup, DOMPurify rules for custom elements, and
  calling your Management API through umbHttpClient instead of handling tokens or
  third-party keys in the browser. Use when a backoffice template uses unsafeHTML or
  unsafeSVG, renders a localized term with markup, sanitizes editor or external HTML, or
  calls an API that needs credentials. For backend security, see `security-dotnet`.
---

# Security in Umbraco backoffice extensions

Lit escapes interpolated values; the risk is in `unsafeHTML()`/`unsafeSVG()` and in anything
that holds a secret in the browser. General frontend security (XSS, secrets in bundles,
browser storage, npm supply chain) isn't repeated here. This skill covers what Umbraco
provides for it, so a package uses those instead of hand-rolling its own. Backend security is
`security-dotnet`'s job; use both for a task that touches both layers.

Check exports against the CMS source at the target release (`umbraco-cms-source`). Versions
below were checked at `release-17.6.1`.

## Sanitizing and escaping: use Umbraco's helpers

`@umbraco-cms/backoffice/utils` exports two functions:

- **`sanitizeHTML(html)`** runs DOMPurify with its default config. Use it on any HTML that
  must render as markup and isn't a constant: rich text, AI output, external API content,
  editor-written help text. Passing through the package's own backend doesn't make it
  trusted.
- **`escapeHTML(value)`** escapes a value for insertion into HTML. Use it on a single value
  that goes into a string you then render with `unsafeHTML`.

```typescript
import { html, unsafeHTML } from '@umbraco-cms/backoffice/external/lit';
import { sanitizeHTML } from '@umbraco-cms/backoffice/utils';

// WRONG: "it comes from our own API" doesn't make it safe
html`<div>${unsafeHTML(this._summary)}</div>`;

// RIGHT
html`<div>${unsafeHTML(sanitizeHTML(this._summary))}</div>`;
```

Import DOMPurify itself from `@umbraco-cms/backoffice/external/dompurify` if you need a custom
config, so the package doesn't bundle a second copy.

## Localized terms with markup: `localize.htmlString`

A term with markup in it (`'Delete <strong>%0%</strong>?'`) tempts you to wrap
`localize.string(...)` in `unsafeHTML`. That inserts every argument unescaped, so an editor
who names an item `<img src=x onerror=...>` runs script in another user's backoffice. This
was a real CMS vulnerability (GHSA-vr9v-27gg-qgx4, fixed in 17.4.0).

Use `this.localize.htmlString(term, ...args)` (17.4+). It escapes each argument and returns
the `unsafeHTML` directive itself:

```typescript
// WRONG
html`<p>${unsafeHTML(this.localize.string('#myPackage_confirmDelete', item.name))}</p>`;

// RIGHT
html`<p>${this.localize.htmlString('#myPackage_confirmDelete', item.name)}</p>`;
```

On a package that supports versions before 17.4, pass `escapeHTML(item.name)` to
`localize.string` instead.

## Custom elements in sanitized HTML

Allowing your own elements through DOMPurify (`CUSTOM_ELEMENT_HANDLING`) needs an
`attributeNameCheck` that excludes event handlers. `/.+/` lets `onclick` and `onload` through
on every allowed tag. Umbraco's own UFM sanitizer had this bug (GHSA-vrqc-59mw-qqg7) and now
uses `/^(?!on)/`. Match it, or list the allowed attributes:

```typescript
CUSTOM_ELEMENT_HANDLING: {
  tagNameCheck: /^my-pkg-/,
  attributeNameCheck: /^(?!on)/,
  allowCustomizedBuiltInElements: false,
}
```

## Credentials stay on the server

- **Backoffice auth.** From 17.0 the backoffice's access token lives in an httpOnly cookie
  that scripts can't read. Call your package's Management API through `umbHttpClient`
  (`@umbraco-cms/backoffice/http-client`), and pass it as the `client` option to calls from
  a generated client so they reuse its cookie setup (generating one is in
  `umbraco-backoffice-conventions`). Never read, copy, or store a token in
  `localStorage`/`sessionStorage`.
- **Third-party keys.** A key in `import.meta.env.VITE_*` is public once built. Put the call
  to the third-party service behind your own Management API endpoint, which reads the key
  from server-side settings (`security-dotnet`).

## In a review

Each of these is an injection or a secret exposure, which the `reviewer` agent treats as
`Critical`: an unsanitized `unsafeHTML`/`unsafeSVG` render of non-constant content,
`localize.string` inside `unsafeHTML` with any argument, a DOMPurify config that lets `on*`
attributes through, and a secret reaching the client bundle.
