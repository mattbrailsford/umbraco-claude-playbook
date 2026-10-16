#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.ReviewNotes
mkdir -p $d/Controllers $d/Persistence $d/Services
cat > $d/Umbraco.Community.ReviewNotes.csproj <<'EOF'
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
cat > $d/Persistence/ReviewNotesDbContext.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Umbraco.Community.ReviewNotes.Persistence;

public class ReviewNote
{
    public int Id { get; set; }
    public Guid DocumentKey { get; set; }
    public string Author { get; set; } = "";
    public string Text { get; set; } = "";
    public DateTime CreatedUtc { get; set; }
}

public class ReviewNotesDbContext(DbContextOptions<ReviewNotesDbContext> options) : DbContext(options)
{
    public DbSet<ReviewNote> Notes => Set<ReviewNote>();
}
EOF
cat > $d/Services/ReviewNoteRepository.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Umbraco.Cms.Persistence.EFCore.Scoping;
using Umbraco.Community.ReviewNotes.Persistence;

namespace Umbraco.Community.ReviewNotes.Services;

internal sealed class ReviewNoteRepository(IEFCoreScopeProvider<ReviewNotesDbContext> scopeProvider)
{
    public async Task<IReadOnlyList<ReviewNote>> GetForDocumentAsync(Guid documentKey)
    {
        using IEfCoreScope<ReviewNotesDbContext> scope = scopeProvider.CreateScope();
        List<ReviewNote> notes = await scope.ExecuteWithContextAsync(db =>
            db.Notes.AsNoTracking()
                .Where(n => n.DocumentKey == documentKey)
                .OrderByDescending(n => n.CreatedUtc)
                .Take(50)
                .ToListAsync());
        scope.Complete();
        return notes;
    }
}
EOF
cat > $d/Services/ReviewSummaryService.cs <<'EOF'
using Umbraco.Cms.Core.Models;
using Umbraco.Cms.Core.Services;
using Umbraco.Community.ReviewNotes.Persistence;

namespace Umbraco.Community.ReviewNotes.Services;

public sealed record ReviewSummary(
    string DocumentName,
    IReadOnlyList<ReviewNote> Notes,
    IReadOnlyList<string> RecentActivity,
    IReadOnlyList<string> Reviewers);

internal sealed class ReviewSummaryService(
    ReviewNoteRepository notes,
    IContentEditingService contentEditingService,
    IAuditService auditService,
    IUserGroupService userGroupService)
{
    public async Task<ReviewSummary?> GetAsync(Guid documentKey)
    {
        IContent? content = await contentEditingService.GetAsync(documentKey);
        if (content is null)
        {
            return null;
        }

        IReadOnlyList<ReviewNote> reviewNotes = await notes.GetForDocumentAsync(documentKey);

        PagedModel<IAuditItem> audit = await auditService.GetItemsByKeyAsync(
            documentKey, UmbracoObjectTypes.Document, skip: 0, take: 10);

        IUserGroup? reviewers = await userGroupService.GetAsync("reviewers");

        return new ReviewSummary(
            content.Name ?? "",
            reviewNotes,
            audit.Items.Select(a => $"{a.CreateDate:u} {a.AuditType}").ToList(),
            reviewers is null ? [] : [reviewers.Name ?? "reviewers"]);
    }
}
EOF
cat > $d/Controllers/ReviewSummaryController.cs <<'EOF'
using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Umbraco.Cms.Api.Management.Controllers;
using Umbraco.Cms.Api.Management.Routing;
using Umbraco.Community.ReviewNotes.Services;

namespace Umbraco.Community.ReviewNotes.Controllers;

[ApiVersion("1.0")]
[VersionedApiBackOfficeRoute("review-notes/summary")]
[ApiExplorerSettings(GroupName = "Review notes")]
public class ReviewSummaryController(ReviewSummaryService summaryService) : ManagementApiControllerBase
{
    [HttpGet("{documentKey:guid}")]
    public async Task<IActionResult> Get(Guid documentKey)
    {
        ReviewSummary? summary = await summaryService.GetAsync(documentKey);
        return summary is null ? NotFound() : Ok(summary);
    }
}
EOF
