# Where Umbraco bugs often hide

Check these once step 4 has narrowed the search. Each is a place to look, not a cause to
assume: prove it with step 5 like any other hypothesis. Confirm how a CMS mechanism behaves
in the source at the project's tag (`umbraco-cms-source`), not from this list.

## Backend

- **Registration.** A service, handler, or extension that's never registered, registered
  twice, or registered in a composer that runs before the one it depends on
  (`[ComposeAfter]`). Symptom: it silently does nothing, or the wrong implementation wins.
  `umbraco-extensibility` has the registration rules.
- **Scopes.** A database write inside an `ICoreScope` that never calls `Complete()` is
  rolled back when the scope ends, with no error. Its "-ed" notifications are dropped too:
  they only publish when the scope completes. Code running under `Notifications.Suppress()`
  (an import, for example) publishes none at all.
- **Notifications.** A handler on the "-ing" notification (`ContentSavingNotification`) when
  it needed the "-ed" one, or the other way round. A sync handler doing async work it doesn't
  wait for.
- **Caching.** Stale data after a write: the package's own cache isn't cleared, or on a
  load-balanced site it's cleared on one server only because there's no cache refresher
  (`umbraco-extensibility`'s cache refresher entry).
- **More than one server.** Works on one server, fails or repeats on several: a file on one
  server's disk, state in one server's memory, a job or handler that runs once per server
  (`umbraco-load-balancing`).
- **Database provider.** Works on SQLite, fails on SQL Server, or the other way round: case
  sensitivity, date handling, or a migration that only ran on one (`ef-core-data`).
- **Authorization.** A Management API endpoint that returns 401 or 403 for a user who should
  have access, or 200 for one who shouldn't. The second is a security issue: stop, per step 1.

## Backoffice

- **Extension not loading.** Check Settings › Extension Insights to see whether the
  extension is registered at all. If not: the `umbraco-package.json` isn't served, the
  bundle path is wrong, or the browser has an old bundle cached.
- **Alias clash.** Two extensions sharing a manifest `alias`: one replaces the other with no
  error (`umbraco-backoffice-conventions`).
- **Context timing.** A component reading a context before it's provided, or after it's
  gone. Symptom: works on first load, fails after navigating, or the other way round.
- **Wrong backoffice version.** The client was built against a different
  `@umbraco-cms/backoffice` version than the CMS it runs in. Compare the two.

## Environment

- **Config.** A setting that differs between the reporter's site and yours. Compare the
  `appsettings.*.json` files and environment variables that apply.
- **Versions.** The reporter runs a different CMS or package version than the one you read.
  Read the source at their version.
