#!/usr/bin/env bash
# Shared starting repo for the security-dotnet write cases: a small Umbraco 17 package.
set -euo pipefail
mkdir -p src/MyPackage/Data src/MyPackage/Connections src/MyPackage/Profiles
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><Nullable>enable</Nullable></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18.0.0)" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="10.0.0" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddUmbracoDbContext<MyPackageDbContext>((options, connectionString, providerName, sp) =>
            options.UseUmbracoDatabaseProvider(sp));
        builder.Services.AddScoped<IConnectionService, ConnectionService>();
    }
}
EOF
cat > src/MyPackage/Data/MyPackageDbContext.cs <<'EOF'
namespace MyPackage.Data;

public class MyPackageDbContext : DbContext
{
    public MyPackageDbContext(DbContextOptions<MyPackageDbContext> options) : base(options) { }

    public DbSet<ConnectionEntity> Connections => Set<ConnectionEntity>();
    public DbSet<ProfileEntity> Profiles => Set<ProfileEntity>();
}

public class ConnectionEntity
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ProviderAlias { get; set; } = string.Empty;
    public string BaseUrl { get; set; } = string.Empty;
}

public class ProfileEntity
{
    public Guid Id { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public DateTime CreatedUtc { get; set; }
}
EOF
cat > src/MyPackage/Connections/ConnectionService.cs <<'EOF'
namespace MyPackage.Connections;

public interface IConnectionService
{
    Task<IReadOnlyList<ConnectionEntity>> GetAllAsync(CancellationToken ct = default);
    Task<ConnectionEntity> CreateAsync(string name, string providerAlias, string baseUrl, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
}

internal sealed class ConnectionService : IConnectionService
{
    private readonly IDbContextFactory<MyPackageDbContext> _dbFactory;
    public ConnectionService(IDbContextFactory<MyPackageDbContext> dbFactory) => _dbFactory = dbFactory;

    public async Task<IReadOnlyList<ConnectionEntity>> GetAllAsync(CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        return await db.Connections.AsNoTracking().OrderBy(c => c.Name).ToListAsync(ct);
    }

    public async Task<ConnectionEntity> CreateAsync(string name, string providerAlias, string baseUrl, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        var entity = new ConnectionEntity { Id = Guid.NewGuid(), Name = name, ProviderAlias = providerAlias, BaseUrl = baseUrl };
        db.Connections.Add(entity);
        await db.SaveChangesAsync(ct);
        return entity;
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        await db.Connections.Where(c => c.Id == id).ExecuteDeleteAsync(ct);
    }
}
EOF
