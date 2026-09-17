---
name: typescript-best-practices
description: >-
  Strict TypeScript discipline for a Lit + UUI backoffice package — type modeling, null
  hygiene, error handling, and the toString()/toJSON() rule. Use when writing or reviewing
  any TypeScript in an Umbraco backoffice frontend package. Complements lit-uui-conventions
  (which covers package/file structure, not language discipline) and the official Backoffice
  Skills plugin (which covers individual extension-point patterns).
---

# TypeScript discipline for Umbraco backoffice packages

## 🎯 Why: Design for Change

A loosely-typed frontend fails the same way a loosely-typed backend does: the compiler stops
catching the change you were about to break. These rules keep the type checker doing real
work, not decoration.

## Compiler settings — start strict, stay strict

A Lit + UUI package's `tsconfig.json` should look roughly like this from day one:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "experimentalDecorators": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "isolatedModules": true,
    "types": ["@umbraco-cms/backoffice/extension-types"]
  }
}
```

The exact target/module numbers vary by project — a larger package may add
`verbatimModuleSyntax`, `noImplicitOverride`, `noImplicitReturns` on top of the above; a
smaller package targeting `ES2020` is equally valid. **Not negotiable: `strict: true`,
`experimentalDecorators: true`** (required for Lit's `@customElement`/`@property` decorators)
**and `moduleResolution: "bundler"`.** If you inherit a non-strict project, enabling `strict`
and fixing the fallout is worth its own task, not something to defer indefinitely.

## Type modeling: make invalid states unrepresentable

Prefer a type that can't express the wrong thing over a type that can, plus a runtime check.

```ts
// Weak — every consumer has to remember to check status before trusting the payload
interface FetchState {
  status: "idle" | "loading" | "success" | "error";
  data?: Item;
  error?: string;
}

// Strong — a discriminated union. TypeScript narrows `state` for you at each branch,
// and it's a compile error to read `.data` from a state that doesn't have it.
type FetchState =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: Item }
  | { status: "error"; error: string };

function render(state: FetchState) {
  switch (state.status) {
    case "success":
      return html`${state.data.name}`; // .data is known to exist here, no `!`, no `?.`
    case "error":
      return html`${state.error}`;
    default:
      return html`…`;
  }
}
```

Reach for discriminated unions for anything with mutually-exclusive shapes (request state,
a workspace's edit-vs-view mode, a step in a multi-step form) instead of a single interface
with a pile of optional fields.

## Error handling: `{ data, error }` for anything that can fail routinely

**Every async data operation returns a `{ data, error }` tuple and never throws.** A save that
can fail validation, or a fetch that can 404, is expected and routine — model it in the return
type so the caller is forced to handle it, rather than throwing and hoping a `try/catch`
further up remembers to catch it:

```ts
async function saveItem(item: Item): Promise<{ data?: Item; error?: string }> {
  const response = await client.postItem({ body: item });
  if (!response.data) return { error: response.error?.detail ?? "Save failed" };
  return { data: response.data };
}

// Usage
const { data, error } = await saveItem(item);
if (error) {
  // handle it — the compiler won't let you forget to check
}
```

Build a shared wrapper (a `tryExecute`-style helper) once your package has more than a couple
of API calls, so the tuple shape and "never throws" rule apply consistently everywhere rather
than being hand-rolled per call site.

This is specifically about **data operations** — reserve real `throw`/`try`/`catch` for
genuinely exceptional, programmer-error conditions and for component lifecycle code
(`constructor`, `connectedCallback`, `render`), where try/catch around initialization is
normal. Data layer returns tuples; component layer catches around what could go wrong during
setup or rendering.

## Null hygiene: don't accept `null`/`undefined` at a function boundary

If a value is genuinely optional, say so in the type (`value?: Item`) and handle both
branches at the point of use — don't accept a possibly-`undefined` value deep into a call
chain and hope every intermediate function remembers to guard it. Prefer narrowing over the
non-null assertion operator (`!`):

```ts
// Avoid — the `!` is a promise to the compiler you might not be able to keep
function getName(item?: Item): string {
  return item!.name;
}

// Prefer — the caller is forced to handle the missing case, once, at the boundary
function getName(item: Item): string {
  return item.name;
}
// ...and at the call site: if (item) { getName(item) }
```

A non-null assertion in application code (not test setup) is worth a second look in review —
it usually means a type is lying about what it can contain.

## The `toString()` / `toJSON()` rule

Any class whose instances might end up in a template literal, a `console.log`, or
`JSON.stringify` (Management API request bodies, error reporting, debug logging) should
implement `toString()` and, if it's ever serialized, `toJSON()` explicitly — don't rely on the
default `[object Object]` behavior:

```ts
class ItemAlias {
  constructor(private readonly value: string) {}
  toString(): string { return this.value; }
  toJSON(): string { return this.value; }
}
```

A value object that silently stringifies to `[object Object]` inside a template or log line is
a debugging session waiting to happen, and it's invisible until someone hits it.

## Working with the generated Management API client

Treat the client generated from your package's own OpenAPI spec (see `lit-uui-conventions`) as
read-only — never hand-edit it, regenerate it. **Only one layer (a data source) is ever allowed
to import a generated type or call a generated service.** Everything above that — repository,
context, component — works with your package's own domain models, mapped once at that single
boundary, and returns the `{ data, error }` tuple shape above. A generated request/response
type showing up past the data source means the mapping layer is missing, not just untidy.

## Scope note

This skill is language discipline — types, null handling, error shapes. It does not cover
*where* files live, barrel exports, or workspace build order; that's `lit-uui-conventions`.
It does not cover individual Umbraco extension-point implementation patterns (how to build a
property editor, a dashboard, a tree); that's the official Backoffice Skills plugin.
