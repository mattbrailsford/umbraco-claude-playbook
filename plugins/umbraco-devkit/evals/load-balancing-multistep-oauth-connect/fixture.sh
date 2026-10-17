#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Mailchimp
mkdir -p $d/Services
cat > $d/Umbraco.Community.Mailchimp.csproj <<'EOF'
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
cat > $d/MailchimpOptions.cs <<'EOF'
namespace Umbraco.Community.Mailchimp;

public class MailchimpOptions
{
    public string ClientId { get; set; } = "";
    public string ClientSecret { get; set; } = "";
    public string AuthorizeUrl { get; set; } = "https://login.mailchimp.com/oauth2/authorize";
    public string TokenUrl { get; set; } = "https://login.mailchimp.com/oauth2/token";
}
EOF
cat > $d/Services/MailchimpTokenStore.cs <<'EOF'
using Umbraco.Cms.Core.Services;

namespace Umbraco.Community.Mailchimp.Services;

// Stores the access token in the database through Umbraco's key-value store.
public sealed class MailchimpTokenStore(IKeyValueService keyValueService)
{
    private const string Key = "Umbraco.Community.Mailchimp.AccessToken";

    public void Save(string token) => keyValueService.SetValue(Key, token);

    public string? Get() => keyValueService.GetValue(Key);
}
EOF
