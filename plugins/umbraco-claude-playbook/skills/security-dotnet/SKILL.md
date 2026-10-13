---
name: security-dotnet
description: >-
  Backend security review checklist for an Umbraco CMS package — Management API controllers,
  EF Core queries built from user or backoffice-user input, backoffice authorization,
  secrets/sensitive-configuration storage, custom non-Management-API endpoints, and NuGet
  dependency supply chain. Use when reviewing or writing any Management API controller action,
  any EF Core query assembled from input, any code path handling API keys/tokens/connection
  strings, or any endpoint added outside the standard Management API pipeline. For frontend
  security (XSS in Lit templates, secrets in a client bundle, npm supply chain), see
  `security-lit` instead.
---

# Backend security review for Umbraco packages

Frontend security (XSS in Lit templates, secrets in a client bundle, browser storage, npm
supply chain) belongs to `security-lit`. Use both for a task that touches both layers.

## 🎯 Why: Design for Change

Close gaps by structure (parameterized queries, explicit authorization, allow-listed config
references), not by convention ("the backoffice user is trusted"). Convention leaves the next
contributor to rediscover the same gap.

## Management API authorization

A Management API controller is reachable over plain HTTP. The `/umbraco/management/api/` path
is a routing convention, not a control. Inheriting `ManagementApiControllerBase` gives real
backoffice authentication (the base class carries
`[Authorize(Policy = AuthorizationPolicies.BackOfficeAccess)]` at class level). What goes
wrong is the *extra* check a sensitive action needs on top of that baseline.

**Rule:** confirm backoffice authentication is in the inheritance chain (don't bypass
`ManagementApiControllerBase` for a "simpler" custom base). Add a specific, stricter
permission/policy on top for anything sensitive (deletes, secret access, settings that affect
other users). Backoffice access alone is not a strong enough gate for a destructive action.

Check **every action individually**, not just the controller class. One action's
`[AllowAnonymous]` can override a controller-level `[Authorize]`, and a later-added action can
miss the class-level intent:

```csharp
// ManagementApiControllerBase already carries [Authorize(Policy = AuthorizationPolicies.BackOfficeAccess)]
// at the class level — real, built into Umbraco's own base controller.
public class ConnectionController : ManagementApiControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAllAsync() { /* covered by the inherited class-level policy */ }

    // Deletes need their OWN, stricter check — define a policy for it, don't assume the
    // inherited backoffice-access check is enough for a destructive action:
    [HttpDelete("{id:guid}")]
    [Authorize(Policy = MyPackageAuthorizationPolicies.DeleteConnection)]
    public async Task<IActionResult> DeleteAsync(Guid id) { /* ... */ }
}
```

`AuthorizationPolicies.BackOfficeAccess` is real, on `ManagementApiControllerBase` itself.
`MyPackageAuthorizationPolicies.DeleteConnection` is not. It's a policy your package defines
and registers in a Composer (`builder.Services.AddAuthorization(options =>
options.AddPolicy(...))`, full example in `umbraco-extensibility`'s
`references/api-and-infrastructure.md`). Don't reference a built-in-sounding policy name
without checking it exists. An unresolved policy fails closed in some setups and silently
no-ops in others.

Reviewer checklist: find every `[Http*]`-attributed method in the diff and confirm each
resolves to an authorization requirement, inherited or explicit.

## EF Core injection

EF Core LINQ queries are parameterized automatically. The risk is raw SQL (`FromSqlRaw`,
`ExecuteSqlRaw`, a raw ADO.NET command) with a value concatenated or `$""`-interpolated in
instead of passed as a parameter.

**Rule:** always use `FromSqlInterpolated` / `ExecuteSqlInterpolated` (or explicit
`SqlParameter`s). Never string-concatenate input into raw SQL, including input only a
backoffice user can supply. A backoffice user is not trusted with arbitrary SQL execution.

```csharp
// WRONG — string interpolation into FromSqlRaw builds the SQL text directly from input
var results = await dbContext.Profiles
    .FromSqlRaw($"SELECT * FROM MyPackage_Profile WHERE Alias = '{request.Alias}'")
    .ToListAsync();

// RIGHT — FromSqlInterpolated parameterizes every {} placeholder
var results = await dbContext.Profiles
    .FromSqlInterpolated($"SELECT * FROM MyPackage_Profile WHERE Alias = {request.Alias}")
    .ToListAsync();
```

Plain LINQ (`.Where(p => p.Alias == alias)`) is safe. Grep diffs for `FromSqlRaw`,
`ExecuteSqlRaw`, and any hand-built `SqlCommand.CommandText`.

## Secrets and sensitive configuration

Sensitive values (API keys, connection strings, tokens) must never be stored in the database
as plaintext, and never written to logs (including exception messages and request/response
logging middleware).

**Rule:** prefer a reference/indirection pattern over storing the raw secret. A settings field
stores a *reference* (a configuration key or secret-store identifier), resolved from
`IConfiguration` or a secret store only at the point of use:

```csharp
// Stored in the entity: not the API key itself, just where to find it
public string ApiKeyConfigReference { get; set; } = "MyPackage:Providers:CoolVendor:ApiKey";

// Resolved at read time, never persisted
public string? ResolveApiKey(IConfiguration configuration)
{
    if (!_allowedConfigSections.Any(prefix => ApiKeyConfigReference.StartsWith(prefix)))
    {
        throw new InvalidOperationException("Config reference is outside the allowed sections.");
    }

    return configuration[ApiKeyConfigReference];
}
```

The allow-list of permitted configuration sections is required. Without it, a reference could
point at an unrelated key (connection strings, other packages' secrets) and leak it through the
package's API.

A field masked in the backoffice editor must also be write-only in the **API response**. The
server must never send the real value back, even to redraw the mask. Client-side masking (CSS,
`type="password"`) does nothing if the payload carries plaintext. Check the DTO/response model,
not just the editor UI.

## CSRF / cross-origin for custom endpoints

Anything outside the standard Management API pipeline (a custom minimal API endpoint, a webhook
receiver, a raw ASP.NET Core route) does **not** inherit the backoffice's antiforgery/CSRF
handling just because it's in the same project.

**Rule:** treat each such endpoint as its own trust boundary and decide explicitly:

- Reachable from a browser with an authenticated cookie: require an antiforgery token or a
  verified `Origin`/`Referer`.
- Intentionally public (e.g. a third-party webhook): give it its *own* authentication
  (signature verification, shared secret, IP allow-list), not "nobody knows the URL".

Don't leave this undecided. An endpoint assuming backoffice protections it never inherited is
a silent gap.

## NuGet dependency / package supply chain

- Pin dependency versions deliberately (Central Package Management) so a transitive NuGet
  dependency can't silently change version on a routine restore.
- When a change adds or bumps a package, run
  `dotnet list package --vulnerable --include-transitive` and treat a known vulnerability in
  the result as a finding.
- Don't add `curl | sh`-style install patterns to build or setup scripts. Fetch a pinned
  artifact and verify it instead.

## Findings format

Report findings severity-ordered, most severe first, each with:

- **Location** — `file:line`.
- **What's wrong** — the concrete defect, not a category name.
- **Why it matters** — the actual exploit or exposure, stated plainly, not "this could
  potentially be an issue."

No "consider using parameterized queries" hedging; say what must change. The `reviewer`
subagent treats any injection vulnerability, authorization gap, or secret exposure in a diff
as an automatic `FAIL`, regardless of the rest of the review. These are non-negotiable, not
weighed against other findings.
