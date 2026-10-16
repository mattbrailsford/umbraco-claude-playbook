#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.StockSync
mkdir -p $d/Migrations $d/Composers $d/Sections
cat > $d/Umbraco.Community.StockSync.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Sections/StockSyncSection.cs <<'EOF'
namespace Umbraco.Community.StockSync.Sections;

public static class StockSyncSection
{
    // Matches the section manifest alias in umbraco-package.json.
    public const string Alias = "StockSync.Section";
}
EOF
cat > $d/Migrations/StockSyncMigrationPlan.cs <<'EOF'
using Umbraco.Cms.Core.Packaging;

namespace Umbraco.Community.StockSync.Migrations;

public class StockSyncMigrationPlan : PackageMigrationPlan
{
    public StockSyncMigrationPlan()
        : base("Umbraco.Community.StockSync")
    {
    }

    protected override void DefinePlan()
    {
        To<CreateSyncLogTable>("a4b1d6c2-6f0e-4b8a-9d3e-2f7f1c9b8e01");
    }
}
EOF
cat > $d/Migrations/CreateSyncLogTable.cs <<'EOF'
using NPoco;
using Umbraco.Cms.Infrastructure.Migrations;
using Umbraco.Cms.Infrastructure.Persistence.DatabaseAnnotations;

namespace Umbraco.Community.StockSync.Migrations;

public class CreateSyncLogTable(IMigrationContext context) : AsyncMigrationBase(context)
{
    protected override Task MigrateAsync()
    {
        if (!TableExists("stockSyncLog"))
        {
            Create.Table<SyncLogDto>().Do();
        }

        return Task.CompletedTask;
    }

    [TableName("stockSyncLog")]
    [PrimaryKey("id", AutoIncrement = true)]
    public class SyncLogDto
    {
        [Column("id")]
        [PrimaryKeyColumn(AutoIncrement = true)]
        public int Id { get; set; }

        [Column("message")]
        public string Message { get; set; } = "";
    }
}
EOF
