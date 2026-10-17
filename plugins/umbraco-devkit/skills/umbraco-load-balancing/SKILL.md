---
name: umbraco-load-balancing
description: >-
  Keeping a package correct when a site runs on more than one server: the two server
  setups a package must work in, and background jobs whose work must happen once per site.
  Use when writing, changing or reviewing a package's background job or scheduled work. Not
  for setting up a load-balanced host.

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

## Reviewing a diff for load balancing

- A recurring background job that sends, calls out or writes shared data, relying on the
  default `ServerRoles` to run it once.
- An `IDistributedBackgroundJob` without a package-prefixed `Name`, or one that drops the
  cancellation token.

