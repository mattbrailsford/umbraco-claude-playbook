#!/usr/bin/env bash
set -euo pipefail
d=src/MyPackage.Payments
mkdir -p $d/Data $d/Settings $d/Composers
cat > $d/MyPackage.Payments.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="10.0.0" />
  </ItemGroup>
</Project>
EOF
cat > $d/Data/PaymentsDbContext.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace MyPackage.Payments.Data;

public class ProviderSettings
{
    public Guid Id { get; set; }
    public string Name { get; set; } = "";
    public string MerchantId { get; set; } = "";
    public string ApiKey { get; set; } = "";
}

public class PaymentsDbContext(DbContextOptions<PaymentsDbContext> options) : DbContext(options)
{
    public DbSet<ProviderSettings> ProviderSettings => Set<ProviderSettings>();
}
EOF
cat > $d/Settings/ProviderSettingsService.cs <<'EOF'
using Microsoft.EntityFrameworkCore;
using MyPackage.Payments.Data;

namespace MyPackage.Payments.Settings;

public interface IProviderSettingsService
{
    Task<ProviderSettings?> GetAsync(Guid id);
    Task SaveAsync(ProviderSettings settings);
}

internal sealed class ProviderSettingsService(IDbContextFactory<PaymentsDbContext> dbFactory) : IProviderSettingsService
{
    public async Task<ProviderSettings?> GetAsync(Guid id)
    {
        await using PaymentsDbContext db = await dbFactory.CreateDbContextAsync();
        return await db.ProviderSettings.AsNoTracking().FirstOrDefaultAsync(s => s.Id == id);
    }

    public async Task SaveAsync(ProviderSettings settings)
    {
        await using PaymentsDbContext db = await dbFactory.CreateDbContextAsync();
        db.ProviderSettings.Update(settings);
        await db.SaveChangesAsync();
    }
}
EOF
cat > $d/Composers/PaymentsComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using MyPackage.Payments.Settings;

namespace MyPackage.Payments.Composers;

public class PaymentsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddScoped<IProviderSettingsService, ProviderSettingsService>();
    }
}
EOF
