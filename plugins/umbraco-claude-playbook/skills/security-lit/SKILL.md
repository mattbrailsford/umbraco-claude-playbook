---
name: security-lit
description: >-
  Frontend security review checklist for an Umbraco backoffice package built with Lit — XSS via
  `unsafeHTML`/`unsafeSVG`, secrets that leak into a client bundle, sensitive data in browser
  storage, and npm dependency supply chain. Use when reviewing or writing any Lit template that
  renders user-generated, AI-generated, or externally-sourced content, any frontend code that
  reads a build-time environment variable, or any use of `localStorage`/`sessionStorage`. For
  backend security (Management API authz, EF Core injection, secrets storage), see
  `security-dotnet` instead.
---

# Frontend security review for Umbraco backoffice packages

Backend security — Management API authz, EF Core injection, server-side secrets storage, CSRF
for custom endpoints — is `security-dotnet`'s job, not this skill's. Use both together for a
task that touches both layers.

## 🎯 Why: Design for Change

A frontend security gap is just as expensive to unwind as a backend one — sanitizing content
after the fact, once it's already rendered in a dozen places, is far more work than rendering it
safely from the start. Closing gaps by structure (never opting out of escaping, never letting a
secret reach the bundle) keeps the codebase easy to build on; closing them by convention ("the
backoffice is trusted, so it's fine") means the next contributor re-discovers the same gap.

## XSS in Lit templates

Lit's `html` tagged template escapes interpolated values by default — that's the safe path and
needs no special review. The risk is entirely in the directives that opt out of it:
`unsafeHTML()` and `unsafeSVG()` render their argument as raw markup, unescaped.

**Rule:** never pass content through `unsafeHTML`/`unsafeSVG` unless its origin is fully
trusted and it has been sanitized first. This includes AI-generated content, rich-text/RTE
content, and anything pulled from an external API — none of these are trusted just because they
passed through the package's own backend first.

```typescript
// WRONG — rendering AI-generated or RTE content straight through unsafeHTML
render() {
  return html`<div class="preview">${unsafeHTML(this.generatedContent)}</div>`;
}

// RIGHT — sanitize first if real markup genuinely needs to render
render() {
  const safeHtml = DOMPurify.sanitize(this.generatedContent);
  return html`<div class="preview">${unsafeHTML(safeHtml)}</div>`;
}
```

Grep diffs for `unsafeHTML(` and `unsafeSVG(` and trace the argument back to its source. If
that source is a user, an LLM response, an RTE/block-content value, or an external HTTP call,
the missing sanitization step is a finding.

## Secrets never ship in a client bundle

A build-time environment variable inlined into the frontend (`import.meta.env.VITE_*` or
equivalent) ends up as plaintext in the shipped JS, readable by anyone who opens dev tools or
views the bundle — it is not a secret once it's there, no matter how it's named.

**Rule:** anything that needs an API key, a connection string, or a third-party secret must be
called from the backend, with the frontend calling your own Management API instead of the
third-party service directly. If a package's frontend genuinely needs a *public*, low-privilege
key (a maps API key restricted by origin, for instance), that's fine — but treat every
build-time variable as public by default, and justify explicitly the ones that aren't meant to
be.

```typescript
// WRONG — a real provider API key baked into the client bundle at build time
const client = new CoolVendorClient(import.meta.env.VITE_COOL_VENDOR_API_KEY);

// RIGHT — the frontend calls the package's own Management API, which holds the real key
// server-side (see security-dotnet's secrets/sensitive-configuration section)
const response = await fetch("/umbraco/management/api/v1/my-package/vendor-data");
```

## Sensitive data in browser storage

`localStorage` and `sessionStorage` are plain text, readable by any script running on the page
— including a compromised dependency, or a successful XSS elsewhere on the same origin. They
are not a safe place for an auth token, a session identifier, or anything else sensitive.

**Rule:** don't hand-roll token storage in `localStorage`/`sessionStorage` for a package's own
auth or session state. The Umbraco backoffice already handles its own authentication via secure
cookies — lean on that instead of introducing a second, less-safe storage mechanism for the
same concern. Reserve browser storage for genuinely non-sensitive UI conveniences (a collapsed
panel's state, a remembered filter).

## npm dependency / package supply chain

- Commit the lockfile (`package-lock.json`/`pnpm-lock.yaml`) and pin versions deliberately — a
  transitive dependency silently jumping versions on a routine install is exactly how a
  supply-chain compromise reaches a project unnoticed.
- Be wary of a new dependency's `postinstall` script — it runs arbitrary code at install time,
  before any of your own code runs. A well-known, widely-used package doing this is normal; an
  obscure or newly-published one doing it is worth a second look before adding it.
- Don't introduce `curl | sh`-style install patterns in build or setup scripts — fetch a pinned
  artifact and verify it instead.

## Findings format

Report findings severity-ordered, most severe first, each with:

- **Location** — `file:line`.
- **What's wrong** — the concrete defect, not a category name.
- **Why it matters** — the actual exploit or exposure, stated plainly, not "this could
  potentially be an issue."

No "consider sanitizing this" hedging — say what must change. The `reviewer` subagent in this
playbook treats an unsanitized `unsafeHTML`/`unsafeSVG` render of untrusted content, or a secret
reaching a client bundle, as an automatic `FAIL`, the same way it treats a backend injection or
authorization gap — these categories are non-negotiable, not judgment calls to weigh against
other findings.
