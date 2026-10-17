#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Feedback
mkdir -p $d/Controllers $d/Services
cat > $d/Umbraco.Community.Feedback.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Persistence.EFCore" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Controllers/FeedbackController.cs <<'EOF'
using Microsoft.AspNetCore.Mvc;
using Umbraco.Cms.Core.Security;
using Umbraco.Community.Feedback.Services;

namespace Umbraco.Community.Feedback.Controllers;

[ApiController]
[Route("api/feedback")]
public class FeedbackController(IMemberManager memberManager, FeedbackService feedback) : ControllerBase
{
    public sealed record FeedbackRequest(string Message);

    [HttpPost]
    public async Task<IActionResult> Submit(FeedbackRequest request)
    {
        MemberIdentityUser? member = await memberManager.GetCurrentMemberAsync();
        if (member is null)
        {
            return Unauthorized();
        }

        await feedback.SaveAsync(member.Key, request.Message);
        return Ok();
    }
}
EOF
cat > $d/Services/FeedbackService.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Umbraco.Cms.Persistence.EFCore.Scoping;

namespace Umbraco.Community.Feedback.Services;

public class FeedbackEntry
{
    public int Id { get; set; }
    public Guid MemberKey { get; set; }
    public string Message { get; set; } = "";
    public DateTime CreatedUtc { get; set; }
}

public class FeedbackDbContext(DbContextOptions<FeedbackDbContext> options) : DbContext(options)
{
    public DbSet<FeedbackEntry> Entries => Set<FeedbackEntry>();
}

public sealed class FeedbackService(IEFCoreScopeProvider<FeedbackDbContext> scopeProvider)
{
    public async Task SaveAsync(Guid memberKey, string message)
    {
        using IEfCoreScope<FeedbackDbContext> scope = scopeProvider.CreateScope();
        await scope.ExecuteWithContextAsync<object>(async db =>
        {
            db.Entries.Add(new FeedbackEntry { MemberKey = memberKey, Message = message, CreatedUtc = DateTime.UtcNow });
            await db.SaveChangesAsync();
        });
        scope.Complete();
    }
}
EOF
