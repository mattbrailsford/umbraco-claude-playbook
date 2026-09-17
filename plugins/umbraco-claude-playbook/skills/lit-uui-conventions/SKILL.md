---
name: lit-uui-conventions
description: >-
  Package-level frontend structuring conventions for Umbraco backoffice packages built with
  Lit and UUI — local vs. global components, what actually gates your public API surface,
  generating a typed client from a Management API's OpenAPI spec, and building a multi-package
  frontend workspace in the right order. Use when structuring a Lit + UUI backoffice frontend
  package, deciding whether a component should be exported, wiring up an OpenAPI-generated
  client, or setting up frontend builds in a monorepo — not when implementing a specific
  extension point (dashboard, tree, property editor, modal), which the official Backoffice
  Skills plugin already covers in depth.
---

# Lit + UUI package conventions

The official Umbraco Backoffice Skills plugin already covers backoffice extension-point
patterns in exhaustive detail — dashboards, trees, property editors, modals, workspace
context, manifest registration syntax, and the rest. Defer to it for any of that. This skill
exists only to cover the structural conventions that sit *around and between* extension
points — how a package's frontend source is organized, how components get registered and
exported, and how a multi-package frontend workspace builds — territory the official plugin
doesn't own.

These patterns match the Umbraco backoffice client itself, not one add-on's private
convention. **Be flexible about the exact mechanism, not about the underlying principle** —
a smaller package can simplify the mechanism, as noted below where it applies.

## 🎯 Why: Design for Change

If every component registers itself a different way, or the public/private boundary is
whatever happened to get exported first, every future contributor has to re-derive the rules
by reading code instead of following one. The structure below exists so "is this component
loaded, and is it meant to be used outside this package?" always has one obvious answer.

## Local vs. global components

Two folder names, per sub-feature:

- **`local-components/`** — elements only used within that sub-feature. Never exported. Just
  import them normally wherever they're rendered (typically the one parent element whose
  template uses them) — there's no separate registration step to remember.
- **`global-components/`** — elements meant to be reusable by other packages. Registered as
  custom elements and exported from the module's `index.ts`.

```ts
// local-components/thing-card/thing-card.element.ts — never exported, imported directly
// by whatever template renders it
```

```ts
// global-components/feature-card/feature-card.element.ts
@customElement("umb-feature-card")
export class UmbFeatureCardElement extends UmbLitElement { /* ... */ }

// re-exported from the module's index.ts
export { UmbFeatureCardElement } from "./global-components/feature-card/feature-card.element.js";
```

Default to this for a new package. A larger package that wants one consolidated place
confirming "everything gets registered exactly once" may instead chain per-feature barrels
into a single top-level entry point (e.g. `internal-components.ts`) — a workable variant for
a bigger surface, not a different rule. Pick one scheme per package; don't mix both.

**Duplicate registration:** ES modules dedupe by path, so a redundant import of the same file
usually isn't the real risk. The actual failure is two *different* modules registering the
*same tag name* — usually a workspace-linking/dependency-duplication issue (see the build-order
gotcha below). Add a duplicate-class-name build check once a package grows past a handful of
components; don't rely on catching it by eye.

## What actually gates your public API: `package.json` exports, not any one file

Only symbols reachable through a subpath declared in your `package.json`'s `exports` field
are public API. A module's `index.ts` becomes a public contract only once its path is added
there; until then, it's free to change however you like, no matter how central it feels
internally.

- **A small, single-purpose package** reasonably has just one export path (its main
  `index.ts`, or a dedicated `exports.ts` re-exported from it) — there's no rule that says you
  need a matrix of subpaths on day one.
- **A larger package** with genuinely separable feature areas can expose one subpath per area
  (`"./widgets"`, `"./reporting"`), each backed by its own module `index.ts` — the same shape
  the Umbraco backoffice itself uses at scale.

Either way, the rule is symmetric: **before treating a rename or removal as breaking, check
whether the symbol was actually reachable through an exported path** — if not, it isn't
breaking, no matter how central it felt internally. And removing or reshaping something that
*is* exported (dropped export, changed constructor signature, removed `@property()` field) is
breaking for every package or site importing it directly — apply the same `[Obsolete]`-proxy
discipline `umbraco-extensibility` describes for the backend, adapted to TypeScript (keep the old
export working, or ship a major version bump; pair it with a JSDoc `@deprecated` tag and a
runtime warning). **Manifests are never exported from `index.ts`** — they register through the
package's bundle mechanism instead, so a manifest array changing shape isn't a public-API
concern the way an exported class is.

## A renamed manifest `alias` is a silent breaking change

Backoffice manifest `alias` values (property editors, dashboards, sections, conditions) are
referenced by **string**, in your own manifests and potentially in other packages' condition/
overwrite configs. Renaming one is not caught by the TypeScript compiler — it just silently
stops matching wherever the old string was referenced. Treat any manifest `alias:` rename as
breaking: either keep the old alias registered as a deprecated alternative, or call it out
explicitly as an intentional breaking change, not something that slipped through because the
build stayed green.

**Reduce the risk at the source:** export any alias referenced from more than one place as a
named constant, not a repeated string literal — `UMB_{DOMAIN}_{TYPE}_ALIAS`, all caps. A
rename then produces a compiler error everywhere the constant is used, instead of a silent
runtime mismatch:

```ts
export const MY_WIDGET_WORKSPACE_ALIAS = "MyCompany.Workspace.Widget";
```

## Components are lazy-loaded per manifest, by default

The primary way a component or API class gets loaded in the real Umbraco backoffice isn't an
eagerly-loaded barrel at all — it's a dynamic import right on the manifest that needs it:

```ts
{
  type: "dashboard",
  alias: "MyCompany.Dashboard.Analytics",
  name: "Analytics Dashboard",
  element: () => import("./analytics-dashboard.element.js"),
}
```

Vite code-splits at that `import()` automatically, so the component only loads when the
manifest that needs it actually activates. Reach for this first for anything registered
directly against a manifest (`element`, `api`, `js`). The local/global-components split above
is about components that *aren't* independently manifest-registered — the ones only ever
referenced by tag name inside another component's own template.

## Generating a typed API client from your Management API

If your package ships a Management API with an OpenAPI/Swagger spec, generate a typed
TypeScript client from that spec (e.g. `@hey-api/openapi-ts`) instead of hand-writing `fetch`
calls and DTO types. Pick one generation script name and keep it consistent for your package.

```bash
npm run generate-client -- https://localhost:44331/umbraco/swagger/my-package/swagger.json
```

Build the backend project first so the spec you generate against is current, then regenerate
the client whenever the API surface changes. Treat the generated output as build output, not
hand-edited source — if a generated type is wrong, fix the request/response model on the
server, not the generated file.

**Never call the generated client directly from a component or a context.** Only one layer (a
data source) should import a generated type or call a generated service; it maps them to your
package's own domain models before anything else sees them. If a generated type shows up in a
component or context, the mapping layer is missing — a future change to the generated client
(a renamed field, a new required parameter) will otherwise ripple straight into UI code
instead of stopping at one boundary.

## Workspace/monorepo frontend builds

If the repo is a monorepo with multiple frontend packages that depend on each other (a core
package's types/components consumed by one or more add-on packages), build in dependency
order. A core package that exposes its public types via a rolled-up `.d.ts` (e.g. via
api-extractor) needs that rollup built at least once before anything depending on it will
type-check — otherwise a dependent package fails with a confusing `Cannot find module` error
that cascades into unrelated-looking `{}`-inferred type errors elsewhere:

```bash
npm run build:core   # build the dependency's rollup first
npm run build:addon  # then the package that consumes it
```

Restore/install dependencies from the workspace root, not from an individual package's
frontend subfolder — a nested `node_modules` can resolve its own, possibly stale, copy of a
workspace-linked local package instead of the one the workspace actually links.

## Design tokens and styling

Prefer UUI's own CSS custom properties over hardcoded colors, spacing, or font values, so your
package's UI stays visually consistent with backoffice theming — including dark mode where the
design system supports it — without any extra work on your part:

```css
/* BAD — hardcoded, ignores the active theme */
.thing-card {
  background: #ffffff;
  padding: 12px;
  color: #1b264f;
}

/* GOOD — tracks whatever theme (including dark mode) is active */
.thing-card {
  background: var(--uui-color-surface);
  padding: var(--uui-size-space-4);
  color: var(--uui-color-text);
}
```
