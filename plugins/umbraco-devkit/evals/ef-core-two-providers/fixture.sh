#!/usr/bin/env bash
set -euo pipefail
d=src/Acme.Reviews
mkdir -p $d/Persistence $d/Composers
cat > Acme.Reviews.sln <<'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
EOF
cat > $d/Acme.Reviews.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackageId>Acme.Reviews</PackageId>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Persistence.EFCore" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Persistence/Review.cs <<'EOF'
namespace Acme.Reviews.Persistence;

public class Review
{
    public int Id { get; set; }
    public Guid ContentKey { get; set; }
    public int Rating { get; set; }
    public DateTime CreatedUtc { get; set; }
}
EOF
cat > $d/Persistence/ReviewsDbContext.cs <<'EOF'
using Microsoft.EntityFrameworkCore;

namespace Acme.Reviews.Persistence;

public class ReviewsDbContext(DbContextOptions<ReviewsDbContext> options) : DbContext(options)
{
    public DbSet<Review> Reviews => Set<Review>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
        => modelBuilder.Entity<Review>(e =>
        {
            e.ToTable("acmeReviews");
            e.HasIndex(r => r.ContentKey);
        });
}
EOF
cat > $d/Composers/ReviewsComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Extensions;
using Acme.Reviews.Persistence;

namespace Acme.Reviews.Composers;

public sealed class ReviewsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
        => builder.Services.AddUmbracoDbContext<ReviewsDbContext>((options, connectionString, providerName, serviceProvider)
            => options.UseUmbracoDatabaseProvider(serviceProvider));
}
EOF
