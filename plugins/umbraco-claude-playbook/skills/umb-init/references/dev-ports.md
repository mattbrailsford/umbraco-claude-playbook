# Step 6: Demo site ports

`umb-build-loop` builds each feature in its own git worktree, and the smoke step starts the
demo site from there. If the site has a fixed port, two worktrees running at once collide, and
the failure looks like a broken build rather than a setup problem. This step gives every
worktree its own stable port. Skip it if there's no demo/test site.

## Detect

- The demo site's `.csproj` already references `Umbraco.Community.WorktreeDevPort`: done.
- Otherwise, check its `Properties/launchSettings.json` for an `applicationUrl` with a fixed
  port. A `:0` port (the old "let the OS pick" trick) counts as not set up either.
- Check anything else that finds the site by address: OpenAPI client generation config
  (hey-api or similar), scripts, e2e config. A hardcoded port, or an old named-pipe/socket
  lookup, needs fixing too.

## Default if missing

Ask first.

- Add the package to the demo site: `dotnet add <demo site project> package
  Umbraco.Community.WorktreeDevPort`. Delete the fixed `applicationUrl` port from
  `launchSettings.json`; the package ignores `:0` but respects any other fixed port.
- The main checkout gets port `44355`; each linked worktree gets its own from `44300` up,
  saved in that worktree's git folder so it stays the same.
- For Node tooling that needs the site's address, install `worktree-dev-port` and use its
  `getPort()` instead of a hardcoded port.
- Anyone can ask for the current worktree's port with `git wdp-port` (a git alias the package
  adds the first time the site runs).

The package's README (`mattbrailsford/Umbraco.Community.WorktreeDevPort` on GitHub) has the
options. Check it rather than guessing an API this file doesn't show.

## Check

Start the site, then run `git wdp-port`. It prints the port the site is listening on.

## Record

Add to `CLAUDE.md`'s "Build & test" section how to start the demo site and that its port comes
from `git wdp-port`.
