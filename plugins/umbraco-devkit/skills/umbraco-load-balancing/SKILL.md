---
name: umbraco-load-balancing
description: >-
  Keeping an Umbraco package or backoffice extension correct when the site that installs it
  runs on more than one server — files that must not live on one server's disk, state that
  must not live in one server's memory, caches that must be cleared on every server,
  background jobs and notification handlers that must
  run once rather than once per server, concurrent writes from two servers, absolute URLs
  behind a load balancer, and multi-step flows that can't assume the next request lands on
  the same server. Use when writing or reviewing package code that writes files, holds state
  between requests, runs on a timer, sends email or calls out from a handler, writes shared
  rows, builds absolute URLs, or clears its own cache. Not for configuring a load-balanced
  host. For what to cache and how to key it, see `umbraco-performance`.
---

# Load balancing for Umbraco packages

A package doesn't choose how it's hosted. The same DLL runs on one server, on a dedicated
backoffice server with several front-end servers, or (from v17) on several servers that all
serve the backoffice. Code that assumes one server works on the demo site and breaks the
day the site scales out.

**Write for round robin.** Assume every request can land on a different server, with no
sticky sessions. Code that works that way also works with sticky sessions and on one server.

Configuring the host (data protection keys, session storage, the SignalR backplane, server
roles, `LoadBalanceIsolatedCaches()`) is the site owner's job. A package must work once the
host is set up the documented way, and must say so in its docs when it needs more.

Verify version-specific APIs against the CMS source and docs for the major the project
targets (`umbraco-cms-source`, `umbraco-docs`). Load-balancing the backoffice, and
`IDistributedBackgroundJob`, arrived in v17. A package that also supports v13 needs both
paths.

## Two server setups, one package

- **Dedicated backoffice.** One server has the `SchedulingPublisher` role and serves the
  backoffice. The others are `Subscriber` servers that serve the website.
- **Load-balanced backoffice (v17+).** Every server is pinned to `SchedulingPublisher` and
  serves both.

So "the backoffice server" and "the scheduling server" aren't safe stand-ins for "exactly
one server". Your package can't tell which setup it's in, so its code must be right in both.

Source: [Umbraco in load balanced environments](https://docs.umbraco.com/umbraco-cms/run-in-production/infrastructure-and-ops/server-setup/load-balancing),
[Load balancing the backoffice](https://docs.umbraco.com/umbraco-cms/run-in-production/infrastructure-and-ops/server-setup/load-balancing/load-balancing-backoffice).

## Files: never one server's disk

Every server has its own disk. A file written to `App_Data`, `wwwroot` or a folder you made
is on one server only. The next request may not find it.

- **Media and user files go through Umbraco's file system.** Use `MediaFileManager` or
  `IFileSystem`, not `System.IO.File`. The site decides where that storage lives (local
  disk, Azure Blob, ...); your code works with all of them.
- **Generated files (exports, PDFs, one-off downloads) go to shared storage too.** Hand out
  a URL to them, not a local path.
- **Backoffice uploads use Umbraco's temporary file API**, not a temp folder of your own.
  Umbraco documents how to share its temp location across servers. A folder you invent
  isn't covered.
- **Local disk is fine for files every server can rebuild for itself**, such as a cache of
  something stored elsewhere.

```csharp
// Don't: lands on one server's disk
File.WriteAllText(Path.Combine(contentRoot, "App_Data", "MyPackage", "export.csv"), csv);

// Do: lands in the site's shared media storage
_mediaFileManager.FileSystem.AddFile("my-package/export.csv", stream);
```

## State: never one server's memory

A `static` field, a singleton's field, `IMemoryCache`, a `ConcurrentDictionary` or an
in-process queue lives on one server, and is lost when that server restarts.

- **A cache is fine in memory** as long as every server clears its copy when the data
  changes. See "Caches: clear on every server" below.
- **State every server must agree on goes in the database.** Counters, rate limits, feature
  flags, "this user already did X", import progress.
- **In-process queues (`Channel<T>`, `ConcurrentQueue<T>`) lose work.** If a recycle mid-way
  would drop something that matters, store the work in the database and process it from a
  background job.
- **`static` is fine for things that never change** after startup. Mutable `static` state
  drifts apart between servers.

## Caches: clear on every server

Clearing a key in `AppCaches` clears it on the server that ran the code. The others keep
serving the old value until it expires.

- **Route every clear through your package's cache refresher** (`umbraco-extensibility`'s
  catalogue, row 4), via `DistributedCache`, so every server drops its copy. Don't clear the
  key directly.
- **Send what other servers can act on**: an ID or key they can re-read, not an object that
  only exists in this server's memory.
- **Don't lean on an expiry alone** for data that mirrors Umbraco content. Clear it from the
  matching notification.

Source: [Common load-balancing pitfalls](https://docs.umbraco.com/umbraco-cms/run-in-production/infrastructure-and-ops/server-setup/load-balancing/common-load-balancing-pitfalls),
[ICacheRefresher](https://docs.umbraco.com/umbraco-cms/extend-your-project/server-side-extensions/cache/icacherefresher).

## Work that must happen once

### Background jobs

`IRecurringBackgroundJob` (and `RecurringBackgroundJobBase`) runs on every server whose
role is in `ServerRoles`. The default, `Single` and `SchedulingPublisher`, means one server
with a dedicated backoffice, but every server when the backoffice is load-balanced.

- **Work that must happen once per run** (send a digest, call a third-party API, write a
  shared row, clean up shared data) → `IDistributedBackgroundJob` on v17+. Umbraco tracks it
  in the database so only one server runs it at a time. Which server isn't fixed.
- **Work each server does for itself** (clear its own temp files, warm its own cache) →
  `IRecurringBackgroundJob` with `ServerRoles` set to every role.

```csharp
public class MyPackageDigestJob : IDistributedBackgroundJob
{
    public string Name => "MyPackage.Digest";
    public TimeSpan Period => TimeSpan.FromHours(1);

    public Task ExecuteAsync() => ExecuteAsync(CancellationToken.None);

    public async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        // pass cancellationToken to every async call
    }
}

// In a composer
builder.Services.AddSingleton<IDistributedBackgroundJob, MyPackageDigestJob>();
```

- **Prefix `Name` with your package name.** It's the job's row in the database, shared with
  core and every other package.
- **Pass the cancellation token on.** A job that ignores it holds up the server's shutdown
  until it finishes. The `ExecuteAsync(CancellationToken)` overload arrived in 17.5; on
  earlier 17.x only `ExecuteAsync()` is called.
- **Expect a crashed run to block the next one for a while.** If a server dies mid-run, no
  other server picks the job up until its `Period` plus `DistributedJobs:MaximumExecutionTime`
  has passed.
- **A package that also supports v13** has no `IDistributedBackgroundJob` there. Keep the
  recurring job on v13 and say in its docs that it runs once only with a dedicated
  backoffice.

Source: [Scheduling](https://docs.umbraco.com/umbraco-cms/extend-your-project/server-side-extensions/scheduling),
[Distributed jobs settings](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/configuration/distributedjobssettings).

### Notification handlers

- **Action notifications run once**, on the server that did the action.
  `ContentPublishedNotification` fires where the editor clicked Publish. Side effects
  (email, webhook, audit row) belong here.
- **Cache refresher notifications run on every server.** `ContentCacheRefresherNotification`
  and the others fire as each server processes the change. Only do per-server work there:
  clear your own cache, update a local index. Never send email, call an API or write a
  shared row from one; it happens once per server.

The same split applies to your own `ICacheRefresher`: its `Refresh` runs on every server.

## Concurrent writes

Two servers can run the same code at the same moment. A "read, then write if missing" on
shared rows can create duplicates or lose an update.

- **Prefer a database constraint.** A unique index turns a race into an error you can
  handle. Add it in the table's migration (`ef-core-data`).
- **Take a lock when a constraint can't express it.** In a scope, `scope.WriteLock(id)`
  takes a lock all servers share, from the `umbracoLock` table. Packages can add their own
  rows there. Pick an ID that doesn't clash with the documented list, and don't reuse
  core's.

Source: [Distributed locks](https://docs.umbraco.com/umbraco-cms/run-in-production/infrastructure-and-ops/distributed-locks).

## Absolute URLs

Behind a load balancer, the raw request can look like plain HTTP from an internal host
name.

- **Use `Request.Scheme` and `Request.Host` as reported.** With forwarded headers set up by
  the host, they are the public values. Don't rebuild them yourself.
- **Outside a request** (a background job, an email), use
  `Umbraco:CMS:WebRouting:UmbracoApplicationUrl`. Don't remember the host from the first
  request; it may be an internal health check.

## Multi-step flows

A wizard, an OAuth callback or an "approve this" link spans more than one request, and each
can land on a different server.

- **Keep the state in the database**, or in a signed value the client sends back. Not in a
  server's memory.
- **Don't depend on session.** It's shared only if the host has set up a distributed cache.
  If the package truly needs it, say so in its docs.
- **Encrypted values need shared keys.** Values protected with `IDataProtector` only decrypt
  on another server if the host shares data protection keys. Umbraco's docs require it for
  load balancing, but name it in the package docs if your package relies on it.

Source: [Common load-balancing pitfalls](https://docs.umbraco.com/umbraco-cms/run-in-production/infrastructure-and-ops/server-setup/load-balancing/common-load-balancing-pitfalls).

## Reviewing a diff for load balancing

- `System.IO.File`, `Directory` or a path under `App_Data` or `wwwroot` for data another
  request will read.
- Mutable state in a `static` field, a singleton, `IMemoryCache` or an in-process queue
  that other servers need to see or that must survive a restart.
- A package cache cleared directly instead of through its cache refresher, or a refresher
  payload that carries an in-memory object instead of an ID.
- A recurring background job that sends, calls out or writes shared data, relying on the
  default `ServerRoles` to run it once.
- An `IDistributedBackgroundJob` without a package-prefixed `Name`, or one that drops the
  cancellation token.
- Email, a webhook, an HTTP call or a shared write in a cache refresher notification
  handler or an `ICacheRefresher`.
- "Check then insert" on shared rows with no unique constraint or lock; a lock ID that
  clashes with core's or another package's.
- An absolute URL built from a remembered first-request host, or by hand from headers.
- Wizard, OAuth or approval state kept in memory or session with no fallback.
