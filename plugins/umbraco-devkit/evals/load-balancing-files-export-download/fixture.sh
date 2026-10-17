#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.FormEntries
mkdir -p $d/Composers $d/Persistence $d/Services
cat > $d/Umbraco.Community.FormEntries.csproj <<'EOF'
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
cat > $d/Persistence/EntriesDbContext.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Umbraco.Community.FormEntries.Persistence;

public class FormEntry
{
    public long Id { get; set; }
    public Guid FormKey { get; set; }
    public DateTime SubmittedUtc { get; set; }
    public string ValuesJson { get; set; } = "{}";
}

public class EntriesDbContext(DbContextOptions<EntriesDbContext> options) : DbContext(options)
{
    public DbSet<FormEntry> Entries => Set<FormEntry>();
}
EOF
cat > $d/Services/FormEntryRepository.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using Umbraco.Cms.Persistence.EFCore.Scoping;
using Umbraco.Community.FormEntries.Persistence;

namespace Umbraco.Community.FormEntries.Services;

public sealed class FormEntryRepository(IEFCoreScopeProvider<EntriesDbContext> scopeProvider)
{
    public async Task<IReadOnlyList<FormEntry>> GetPageAsync(Guid formKey, long afterId, int take)
    {
        using IEfCoreScope<EntriesDbContext> scope = scopeProvider.CreateScope();
        List<FormEntry> page = await scope.ExecuteWithContextAsync(db => db.Entries.AsNoTracking()
            .Where(e => e.FormKey == formKey && e.Id > afterId)
            .OrderBy(e => e.Id)
            .Take(take)
            .ToListAsync());
        scope.Complete();
        return page;
    }
}
EOF
cat > $d/Composers/FormEntriesComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.FormEntries.Services;

namespace Umbraco.Community.FormEntries.Composers;

public class FormEntriesComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder) => builder.Services.AddScoped<FormEntryRepository>();
}
EOF
