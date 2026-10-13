---
name: umbraco-backoffice-conventions
description: >-
  Umbraco-backoffice-specific frontend conventions built with Lit and UUI — required compiler
  setup, local vs. global components, what actually gates your public API surface, generating
  a typed client from a Management API's OpenAPI spec, the lifecycle of observable
  subscriptions and of extension APIs you create, build output (what stays external, cache
  busting), and building a multi-package frontend workspace in the right order. Use when setting up or
  structuring a Lit + UUI backoffice frontend package, deciding whether a component should be
  exported, wiring up an OpenAPI-generated client, subscribing to a state/context observable,
  or setting up frontend builds in a monorepo — not when implementing a specific extension
  point (dashboard, tree, property editor, modal) or using the state-management system itself,
  which the official Backoffice Skills plugin already covers in depth. Complements
  `typescript-best-practices` (general TS language discipline, not Umbraco-specific).
---

# Umbraco backoffice frontend conventions

The official Umbraco Backoffice Skills plugin covers extension-point patterns (dashboards,
trees, property editors, modals, workspace context, manifest registration syntax). Defer to it
for those. This skill covers only the structure *around and between* extension points: how a
package's frontend source is organized, how components are registered and exported, and how a
multi-package frontend workspace builds.

These patterns match the Umbraco backoffice client itself. **Be flexible about the exact
mechanism, not about the underlying principle**: a smaller package can simplify the
mechanism, as noted below.

## 🎯 Why: Design for Change

One structure means "is this component loaded, and is it meant for use outside this
package?" always has one obvious answer, instead of each contributor re-deriving it from code.

## Compiler setup this ecosystem requires

On top of `typescript-best-practices`' strict baseline, a Lit + UUI backoffice package's
`tsconfig.json` needs these settings. They are required, not style choices:

```json
{
  "compilerOptions": {
    "moduleResolution": "bundler",
    "experimentalDecorators": true,
    "types": ["@umbraco-cms/backoffice/extension-types"]
  }
}
```

**`experimentalDecorators: true`** is required for Lit's `@customElement`/`@property`
decorators; without it, decorated classes silently fail to register or observe attributes.
**`moduleResolution: "bundler"`** matches the backoffice's Vite build.
**`types: ["@umbraco-cms/backoffice/extension-types"]`** brings in the ambient
manifest/extension types the backoffice expects a package to declare against.

## Local vs. global components

Two folder names, per sub-feature:

- **`local-components/`**: elements used only within that sub-feature. Never exported.
  Import them directly where they're rendered (usually the one parent element whose template
  uses them). No separate registration step.
- **`global-components/`**: elements reusable by other packages. Registered as custom
  elements and exported from the module's `index.ts`.

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

Default to this for a new package. A larger package may instead chain per-feature barrels
into a single top-level entry point (e.g. `internal-components.ts`) to confirm everything
registers exactly once. That is a variant, not a different rule. Pick one scheme per package;
don't mix both.

**Duplicate registration:** ES modules dedupe by path, so a redundant import of the same file
is rarely the risk. The real failure is two *different* modules registering the *same tag
name*, usually from workspace-linking/dependency duplication (see the build-order gotcha
below). Add a duplicate-class-name build check once a package grows past a handful of
components; don't rely on catching it by eye.

## What actually gates your public API: `package.json` exports, not any one file

Only symbols reachable through a subpath in `package.json`'s `exports` field are public API.
A module's `index.ts` becomes a public contract only once its path is added there; until
then it is free to change.

- **A small, single-purpose package** can have just one export path (its main `index.ts`, or
  a dedicated `exports.ts` re-exported from it). No need for many subpaths on day one.
- **A larger package** with separable feature areas can expose one subpath per area
  (`"./widgets"`, `"./reporting"`), each backed by its own module `index.ts`, as the Umbraco
  backoffice does.

Either way: **before treating a rename or removal as breaking, check whether the symbol was
actually reachable through an exported path**. If not, it isn't breaking. Removing or
reshaping something that *is* exported (dropped export, changed constructor signature,
removed `@property()` field) is breaking for every importer. Apply the `[Obsolete]`-proxy
discipline `umbraco-package-conventions` describes for the backend, adapted to TypeScript:
keep the old export working or ship a major version bump, and add a JSDoc `@deprecated` tag
and a runtime warning. **Manifests are never exported from `index.ts`**; they register
through the package's bundle mechanism, so a manifest array changing shape isn't a
public-API concern.

## A renamed manifest `alias` is a silent breaking change

Manifest `alias` values (property editors, dashboards, sections, conditions) are referenced
by **string**, in your own manifests and possibly in other packages' condition/overwrite
configs. The compiler won't catch a rename; the old string just silently stops matching.
Treat any manifest `alias:` rename as breaking: keep the old alias registered as a deprecated
alternative, or call it out explicitly as an intentional breaking change. A green build does
not mean it is safe.

**Reduce the risk at the source:** export any alias used in more than one place as a named
constant, `UMB_{DOMAIN}_{TYPE}_ALIAS`, all caps. A rename then causes a compiler error
instead of a silent runtime mismatch:

```ts
export const MY_WIDGET_WORKSPACE_ALIAS = "MyCompany.Workspace.Widget";
```

## Components are lazy-loaded per manifest, by default

In the Umbraco backoffice, components and API classes load mainly through a dynamic import
on the manifest that needs them, not an eager barrel:

```ts
{
  type: "dashboard",
  alias: "MyCompany.Dashboard.Analytics",
  name: "Analytics Dashboard",
  element: () => import("./analytics-dashboard.element.js"),
}
```

Vite code-splits at that `import()`, so the component loads only when its manifest
activates. Use this first for anything registered directly on a manifest (`element`, `api`,
`js`). The local/global-components split above is for components that *aren't*
manifest-registered, only referenced by tag name inside another component's template.

## Build output: externalise the backoffice, version every release

The backoffice already loads `@umbraco-cms/backoffice` and Lit. A package that bundles its own
copy ships both twice, and a second Lit runtime breaks in subtle ways. Keep them out of the
bundle:

```typescript
// vite.config.ts
build: {
  rollupOptions: {
    external: [/^@umbraco/], // provided by the backoffice at runtime
  },
},
```

```typescript
// WRONG — bundles a second copy of Lit
import { html, css } from "lit";

// RIGHT — uses the backoffice's Lit
import { html, css } from "@umbraco-cms/backoffice/external/lit";
```

**Bump `version` in `umbraco-package.json` for every release that changes frontend assets.**
From 17.6 and 18.1, Umbraco appends that version to the manifest's entry points and import map
URLs, so it's the browser's cache key. An unchanged version means editors keep running the
old files. Code-split chunks don't get the version, so keep Vite's default content-hashed
file names for them.

Source: [Vite package setup](https://docs.umbraco.com/umbraco-cms/extend-your-project/backoffice-extensions/development-flow/vite-package-setup),
[umbraco-package.json](https://docs.umbraco.com/umbraco-cms/extend-your-project/backoffice-extensions/umbraco-package),
"The version is your cache key" and "Bundle your assets".

## Generating a typed API client from your Management API

If your package ships a Management API with an OpenAPI/Swagger spec, generate a typed
TypeScript client from it (e.g. `@hey-api/openapi-ts`) instead of hand-writing `fetch` calls
and DTO types. Use one consistent generation script name per package.

```bash
npm run generate-client -- https://localhost:$(git wdp-port)/umbraco/swagger/my-package/swagger.json
```

Don't hardcode the demo site's port. With `Umbraco.Community.WorktreeDevPort` (set up by
`umb-init`'s "Demo site ports" step), `git wdp-port` gives the current worktree's port, and a
Node script can use `getPort()` from `worktree-dev-port`.

Build the backend first so the spec is current, and regenerate the client whenever the API
surface changes. Treat generated output as build output: if a generated type is wrong, fix
the request/response model on the server, not the generated file.

**Never call the generated client directly from a component or a context.** Only one layer (a
data source) imports generated types or calls generated services, and maps them to your
package's own domain models. A generated type in a component or context means the mapping
layer is missing, so generated-client changes (renamed field, new required parameter) leak
into UI code instead of stopping at one boundary.

## Workspace/monorepo frontend builds

In a monorepo where frontend packages depend on each other (a core package consumed by
add-on packages), build in dependency order. A core package that exposes types via a
rolled-up `.d.ts` (e.g. api-extractor) needs that rollup built at least once before
dependents type-check. Otherwise a dependent fails with a confusing `Cannot find module`
error that cascades into unrelated-looking `{}`-inferred type errors:

```bash
npm run build:core   # build the dependency's rollup first
npm run build:addon  # then the package that consumes it
```

Restore/install dependencies from the workspace root, not a package's frontend subfolder. A
nested `node_modules` can resolve its own, possibly stale, copy of a workspace-linked local
package.

## Observable subscriptions: use `this.observe()`, not raw `.subscribe()`

Umbraco state/context observables (pattern covered by the official Backoffice Skills
plugin's `umbraco-state-management`) can be subscribed via the element's `this.observe()`
(from `UmbLitElement`/`UmbControllerHostElementMixin`) or RxJS's raw `.subscribe()`. Only
`this.observe()` is safe by default.

```typescript
// WRONG — a raw subscription outlives the component if you forget to unsubscribe
connectedCallback() {
  super.connectedCallback();
  this._context.myValue.subscribe((value) => { this._value = value; }); // leaks on disconnect
}

// RIGHT — this.observe() ties the subscription's lifecycle to the element automatically
constructor() {
  super();
  this.observe(this._context.myValue, (value) => { this._value = value; });
}
```

`this.observe()` registers the subscription as a controller on the host, so it's torn down
on `disconnectedCallback`: no manual `unsubscribe()`, no callback after the component is
gone. In review, treat any raw `.subscribe()` in a Lit component as suspect; it usually
should be `this.observe()`.

## Extension APIs you create are yours to destroy

`createExtensionApi` and `createExtensionApiByAlias` connect the new API to the host you
pass, but don't clean up an API you created earlier. Code that creates one on every
`connectedCallback`, property change or route change keeps every old instance alive, with
its context listeners. Editors notice after a few dozen navigations.

```typescript
// WRONG — a new API on every value change, none destroyed
override updated() {
  createExtensionApiByAlias<MyApi>(this, this.alias).then((api) => (this.#api = api));
}

// RIGHT — destroy the previous instance before replacing it
async #load(alias: string) {
  this.#api?.destroy();
  this.#api = await createExtensionApiByAlias<MyApi>(this, alias);
}
```

Prefer creating it once, in the constructor. To run every extension of a manifest type, use
`UmbExtensionsApiInitializer` (or `UmbExtensionApiInitializer` for one), which creates and
destroys the APIs as extensions come and go.

Source: CMS issue [#21828](https://github.com/umbraco/Umbraco-CMS/issues/21828) and
PR [#24083](https://github.com/umbraco/Umbraco-CMS/pull/24083).
