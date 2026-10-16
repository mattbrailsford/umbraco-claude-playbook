#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Data
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddUmbracoDbContext<MyPackageDbContext>((options, connectionString, providerName, sp) =>
            options.UseUmbracoDatabaseProvider(sp));
    }
}
EOF
cat > src/MyPackage/Data/MyPackageDbContext.cs <<'EOF'
namespace MyPackage.Data;

public class MyPackageDbContext : DbContext
{
    public MyPackageDbContext(DbContextOptions<MyPackageDbContext> options) : base(options) { }
}
EOF
