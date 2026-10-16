#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Providers
cat > MyPackage.sln <<'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
EOF
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <PackageId>MyCompany.MyPackage</PackageId>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddScoped<IProviderSettingsService, ProviderSettingsService>();
    }
}
EOF
cat > src/MyPackage/Providers/ProviderSettings.cs <<'EOF'
namespace MyPackage.Providers;

// One row per configured provider. Developers set these up once per site.
public class ProviderSettings
{
    public Guid Key { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Region { get; set; } = "eu";
    public string ApiKey { get; set; } = string.Empty;
    public string WebhookSecret { get; set; } = string.Empty;
    public Guid? ApproverUserGroupKey { get; set; }
    public int TimeoutSeconds { get; set; } = 30;
}
EOF
cat > src/MyPackage/Providers/ProviderSettingsService.cs <<'EOF'
namespace MyPackage.Providers;

public interface IProviderSettingsService
{
    Task<IReadOnlyList<ProviderSettings>> GetAllAsync();
    Task<ProviderSettings?> GetAsync(Guid key);
    Task<ProviderSettings?> GetByAliasAsync(string alias);
    Task SaveAsync(ProviderSettings settings);   // publishes ProviderSettingsSavedNotification
    Task DeleteAsync(Guid key);                  // publishes ProviderSettingsDeletedNotification
}
EOF
cat > src/MyPackage/Providers/ProviderSettingsNotifications.cs <<'EOF'
namespace MyPackage.Providers;

public sealed class ProviderSettingsSavedNotification : INotification
{
    public ProviderSettingsSavedNotification(ProviderSettings settings) => Settings = settings;
    public ProviderSettings Settings { get; }
}

public sealed class ProviderSettingsDeletedNotification : INotification
{
    public ProviderSettingsDeletedNotification(Guid key) => Key = key;
    public Guid Key { get; }
}
EOF
