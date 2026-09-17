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

Frontend security — XSS in Lit templates, secrets leaking into a client bundle, browser
storage, npm supply chain — is `security-lit`'s job, not this skill's. Use both together for a
task that touches both layers.

## 🎯 Why: Design for Change

A security gap doesn't just risk one incident — it risks the next feature too, because every
fix after a breach becomes defensive, distrustful code that's harder to extend. Closing gaps
by structure (parameterized queries, explicit authorization, allow-listed config references)
keeps the codebase easy to build on. Closing them by convention ("the backoffice user is
trusted, so it's fine") means the next contributor has to rediscover the same gap the hard way.

## Management API authorization

A Management API controller is reached over plain HTTP like any other API. Being mounted under
`/umbraco/management/api/` is not a control — it's a routing convention. If your controller
inherits from Umbraco's `ManagementApiControllerBase`, backoffice authentication is real and
already there (the base class itself carries
`[Authorize(Policy = AuthorizationPolicies.BackOfficeAccess)]` at the class level) — you get
that baseline for free. What isn't free, and what actually goes wrong, is the *extra* check a
sensitive action needs beyond that baseline.

**Rule:** confirm backoffice authentication is actually in the inheritance chain (don't bypass
`ManagementApiControllerBase` for a "simpler" custom base), and add a specific, stricter
permission/policy on top of it for anything sensitive (deletes, secret access, settings that
affect other users). Never assume backoffice access alone is a strong enough gate for a
destructive action just because the controller inherits it.

Check **every action individually**, not just the controller class. A controller-level
`[Authorize]` can be silently overridden by `[AllowAnonymous]` on one action, or missed entirely
by an action added later without re-checking the class-level intent:

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
`MyPackageAuthorizationPolicies.DeleteConnection` is not — it's a policy your own package
defines and registers (via `AddAuthorizationPolicy` in your Composer) when backoffice access
alone isn't a strict enough gate. Don't reference a built-in-sounding policy name without
checking it actually exists — a policy that doesn't resolve fails closed in some setups and
silently no-ops in others.

Reviewer checklist: find every `[Http*]`-attributed method in the diff and confirm each one
resolves to an authorization requirement, inherited or explicit. Don't read the class attribute
once and assume it covers every action underneath it.

## EF Core injection

LINQ queries built through EF Core's query provider are parameterized automatically. The risk
appears the moment raw SQL is introduced — `FromSqlRaw`, `ExecuteSqlRaw`, or a raw ADO.NET
command — and a value is string-concatenated or interpolated into it with `$""` instead of
passed as a parameter.

**Rule:** always use `FromSqlInterpolated` / `ExecuteSqlInterpolated` (or explicit
`SqlParameter`s), never string-concatenate input into raw SQL — including input that only a
backoffice user can supply. A backoffice user is not a database administrator, and a package
should not assume the person logged into the CMS is trusted with arbitrary SQL execution.

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

Plain LINQ (`.Where(p => p.Alias == alias)`) is safe by default — the injection risk is
specifically the raw-SQL escape hatch. Grep diffs for `FromSqlRaw`, `ExecuteSqlRaw`, and any
hand-built `SqlCommand.CommandText`.

## Secrets and sensitive configuration

Sensitive values — API keys, connection strings, tokens — must never land in the database as
plaintext, and must never be written to logs (including exception messages and request/response
logging middleware).

**Rule:** prefer a reference/indirection pattern over storing the raw secret. A settings field
stores a *reference* (a configuration key or secret-store identifier), resolved to the real
value from `IConfiguration` or a secret store only at the point of use:

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

The allow-list of permitted configuration sections is not optional — without it, a malicious or
careless reference value could be pointed at an unrelated configuration key (connection
strings, other packages' secrets) and read it out through the package's own API.

Separately: a field marked sensitive in the backoffice editor (masked input) must also be
write-only in the **API response**. The server must never send the real value back down to the
client for a masked field, even to redraw the mask — client-side masking alone (CSS, a
`type="password"` input) does nothing if the API payload still carries the plaintext value.
Check the DTO/response model, not just the editor UI.

## CSRF / cross-origin for custom endpoints

Anything added outside the standard Management API pipeline — a custom minimal API endpoint, a
webhook receiver, a raw ASP.NET Core route — does **not** automatically inherit the backoffice's
antiforgery/CSRF handling just because it lives in the same project.

**Rule:** treat every such endpoint as its own trust boundary and decide explicitly — does it
need an antiforgery token or a verified `Origin`/`Referer` because it's reachable from a browser
with an authenticated cookie, or is it intentionally public (e.g. a third-party webhook), in
which case it needs its *own* authentication (signature verification, shared secret, IP
allow-list) rather than relying on "nobody knows the URL"? Don't leave this undecided — an
endpoint that assumes backoffice protections it never actually inherited is a silent gap.

## NuGet dependency / package supply chain

- Pin dependency versions deliberately (Central Package Management) — this class of project
  does not want a transitive NuGet dependency silently jumping versions on a routine restore.
- Don't introduce `curl | sh`-style install patterns (piping a downloaded script into a shell)
  in build or setup scripts — fetch a pinned artifact and verify it instead.

## Findings format

Report findings severity-ordered, most severe first, each with:

- **Location** — `file:line`.
- **What's wrong** — the concrete defect, not a category name.
- **Why it matters** — the actual exploit or exposure, stated plainly, not "this could
  potentially be an issue."

No "consider using parameterized queries" hedging — say what must change. The `reviewer`
subagent in this playbook treats any injection vulnerability, authorization gap, or secret
exposure found in a diff as an automatic `FAIL`, regardless of how the rest of the review reads
— these categories are non-negotiable, not judgment calls to weigh against other findings.
