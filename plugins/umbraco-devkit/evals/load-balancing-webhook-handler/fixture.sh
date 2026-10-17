#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.PublishHooks
mkdir -p $d/Composers $d/Configuration
cat > $d/Umbraco.Community.PublishHooks.csproj <<'EOF'
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
cat > $d/Configuration/PublishHooksOptions.cs <<'EOF'
namespace Umbraco.Community.PublishHooks.Configuration;

/// <summary>Bound from "PublishHooks" in appsettings.json.</summary>
public class PublishHooksOptions
{
    public string? WebhookUrl { get; set; }
}
EOF
cat > $d/Composers/PublishHooksComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.PublishHooks.Configuration;

namespace Umbraco.Community.PublishHooks.Composers;

public class PublishHooksComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.Configure<PublishHooksOptions>(builder.Config.GetSection("PublishHooks"));
        builder.Services.AddHttpClient("PublishHooks");
    }
}
EOF
