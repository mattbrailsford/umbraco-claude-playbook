# Step 4: Lint and format

Without a lint/format check, nobody checks style: the `reviewer` is told to ignore formatting
because "that's what a formatter/linter is for". This step makes sure there is one, and that
`CLAUDE.md` says how to run it.

## Detect

- **Backend:** an `.editorconfig` at the repo root. `dotnet format` is built into the .NET SDK
  and follows it, so the file is all the setup needed.
- **Frontend** (only if there's a `Client/` project): an ESLint config (`eslint.config.js`), a
  Prettier config (`.prettierrc*`), and `lint`/`format` scripts in its `package.json`.

If they exist, record the commands in `CLAUDE.md` and move on.

## Default if missing

Ask first. Both defaults copy what Umbraco CMS itself uses.

**Backend: `.editorconfig`**
- Start from the CMS's own `.editorconfig` (repo root of `umbraco/Umbraco-CMS`, at the release
  tag the project targets; see `umbraco-cms-source` for reading it) rather than writing rules from scratch. Trim rules that only make
  sense inside the CMS.
- Check: `dotnet format <solution>.slnx --verify-no-changes`. Fix: `dotnet format <solution>.slnx`.

**Frontend: ESLint + Prettier**
- Install with npm: `eslint`, `@eslint/js`, `typescript-eslint`, `eslint-plugin-lit`,
  `eslint-config-prettier`, `prettier`.
- Add a flat `eslint.config.js` using the recommended configs from each of those, with
  `eslint-config-prettier` last so ESLint and Prettier don't fight. Add a `.prettierrc.json`;
  the CMS backoffice's one (`src/Umbraco.Web.UI.Client/.prettierrc.json`) is a good start.
- Scripts, matching the CMS backoffice:
  ```json
  "lint": "eslint src",
  "lint:fix": "npm run lint -- --fix",
  "format": "prettier 'src/**/*.ts' --check",
  "format:fix": "npm run format -- --write"
  ```

## Existing code

On a repo that already has code, the first run usually reports a lot. Ask before running the
fixers across the whole repo:

- **Yes:** run them, and suggest committing the result on its own (`style: apply formatting`),
  so later feature diffs only show real changes.
- **No:** still record the commands, but note in `CLAUDE.md` that the builder checks changed
  files only (`dotnet format --include <files>`, `eslint <files>`) until the repo is cleaned up.

## Record

Add the check and fix commands to `CLAUDE.md`'s "Build & test" section.
