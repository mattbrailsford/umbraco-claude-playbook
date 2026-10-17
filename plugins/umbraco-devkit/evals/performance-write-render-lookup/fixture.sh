#!/usr/bin/env bash
set -euo pipefail
d=src/MyPackage
mkdir -p $d/Forms $d/ViewComponents $d/Views/Shared/Components/SignupForm $d/Composers
cat > $d/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="10.0.0" />
  </ItemGroup>
</Project>
EOF
cat > $d/Forms/FormStep.cs <<'EOF'
using System.Text.Json;

namespace MyPackage.Forms;

public class FormStepEntity
{
    public Guid Key { get; set; }
    public Guid FormKey { get; set; }
    public int SortOrder { get; set; }
    public string SettingsJson { get; set; } = "{}";
}

public class FormStepSettings
{
    public string Title { get; set; } = "";
    public bool RequiresConsent { get; set; }
}

public record FormStep(Guid Key, Guid FormKey, int SortOrder, FormStepSettings Settings)
{
    public static FormStep From(FormStepEntity e) =>
        new(e.Key, e.FormKey, e.SortOrder, JsonSerializer.Deserialize<FormStepSettings>(e.SettingsJson) ?? new());
}
EOF
cat > $d/Forms/FormStepService.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace MyPackage.Forms;

public interface IFormStepService
{
    Task<IReadOnlyList<FormStep>> GetStepsForFormAsync(Guid formKey);
    Task SaveAsync(FormStep step);
}

internal sealed class FormStepService(IDbContextFactory<FormsDbContext> dbFactory) : IFormStepService
{
    public async Task<IReadOnlyList<FormStep>> GetStepsForFormAsync(Guid formKey)
    {
        await using FormsDbContext db = await dbFactory.CreateDbContextAsync();
        List<FormStepEntity> rows = await db.Steps.AsNoTracking()
            .Where(s => s.FormKey == formKey)
            .OrderBy(s => s.SortOrder)
            .ToListAsync();
        return rows.Select(FormStep.From).ToList();
    }

    public async Task SaveAsync(FormStep step)
    {
        await using FormsDbContext db = await dbFactory.CreateDbContextAsync();
        FormStepEntity? row = await db.Steps.FindAsync(step.Key);
        if (row is null)
        {
            row = new FormStepEntity { Key = step.Key, FormKey = step.FormKey };
            db.Steps.Add(row);
        }
        row.SortOrder = step.SortOrder;
        row.SettingsJson = System.Text.Json.JsonSerializer.Serialize(step.Settings);
        await db.SaveChangesAsync();
    }
}

public class FormsDbContext(DbContextOptions<FormsDbContext> options) : DbContext(options)
{
    public DbSet<FormStepEntity> Steps => Set<FormStepEntity>();
}
EOF
