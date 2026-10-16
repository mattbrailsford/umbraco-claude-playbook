#!/usr/bin/env bash
# A small Umbraco 17.6 site project with a package folder. No local docs or CMS clone.
set -euo pipefail
mkdir -p src/MySite src/MyPackage/Orders
cat > src/MySite/MySite.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><Nullable>enable</Nullable></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms" Version="17.6.1" />
    <ProjectReference Include="../MyPackage/MyPackage.csproj" />
  </ItemGroup>
</Project>
EOF
cat > src/MySite/appsettings.json <<'EOF'
{
  "Umbraco": {
    "CMS": {
      "Global": { "Id": "b6a5e2f4-0c3e-4a5f-9d2a-6f2b1c3d4e5f" },
      "DeliveryApi": {
        "Enabled": true,
        "PublicAccess": true
      }
    }
  }
}
EOF
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><Nullable>enable</Nullable></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Core" Version="[17.6.1, 18.0.0)" />
    <PackageReference Include="Umbraco.Cms.Infrastructure" Version="[17.6.1, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/Orders/OrderSavedNotification.cs <<'EOF'
using Umbraco.Cms.Core.Notifications;

namespace MyPackage.Orders;

public sealed class OrderSavedNotification : INotification
{
    public OrderSavedNotification(Guid orderKey, string orderNumber, decimal total)
    {
        OrderKey = orderKey;
        OrderNumber = orderNumber;
        Total = total;
    }

    public Guid OrderKey { get; }
    public string OrderNumber { get; }
    public decimal Total { get; }
}
EOF
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;

namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
    }
}
EOF
