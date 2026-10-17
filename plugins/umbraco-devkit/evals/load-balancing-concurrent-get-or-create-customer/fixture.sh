#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Shop
mkdir -p $d/Persistence $d/Services
cat > $d/Umbraco.Community.Shop.csproj <<'EOF'
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
cat > $d/Persistence/ShopDbContext.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Umbraco.Community.Shop.Persistence;

public class Order
{
    public int Id { get; set; }
    public Guid Key { get; set; }
    public string CustomerEmail { get; set; } = "";
    public decimal Total { get; set; }
    public DateTime CreatedUtc { get; set; }
}

public class ShopDbContext(DbContextOptions<ShopDbContext> options) : DbContext(options)
{
    public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Order>(e =>
        {
            e.ToTable("shopOrder");
            e.HasIndex(o => o.Key).IsUnique();
        });
    }
}
EOF
cat > $d/Services/OrderService.cs <<'EOF'
using Umbraco.Cms.Persistence.EFCore.Scoping;
using Umbraco.Community.Shop.Persistence;

namespace Umbraco.Community.Shop.Services;

public sealed class OrderService(IEFCoreScopeProvider<ShopDbContext> scopeProvider)
{
    public async Task<Order> CreateAsync(string customerEmail, decimal total)
    {
        using IEfCoreScope<ShopDbContext> scope = scopeProvider.CreateScope();
        Order order = await scope.ExecuteWithContextAsync(async db =>
        {
            var o = new Order { Key = Guid.NewGuid(), CustomerEmail = customerEmail, Total = total, CreatedUtc = DateTime.UtcNow };
            db.Orders.Add(o);
            await db.SaveChangesAsync();
            return o;
        });
        scope.Complete();
        return order;
    }
}
EOF
