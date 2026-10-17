#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Redirects
mkdir -p $d/Composers $d/Models
cat > $d/Umbraco.Community.Redirects.csproj <<'EOF'
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
cat > $d/Models/RedirectDocumentTypes.cs <<'EOF'
namespace Umbraco.Community.Redirects.Models;

/// <summary>
/// The package installs a "redirectsFolder" document type (allowed at the root) and a
/// "redirect" document type allowed under it. A site has one folder, usually with a few
/// hundred redirects. Editors add, change and unpublish redirects in the backoffice.
/// </summary>
public static class RedirectDocumentTypes
{
    public const string Folder = "redirectsFolder";
    public const string Redirect = "redirect";

    // Properties on "redirect"
    public const string FromPath = "fromPath";      // Textstring, e.g. "/old-page"
    public const string ToUrl = "toUrl";            // Textstring, absolute or relative URL
    public const string Permanent = "permanent";    // Toggle: 301 when on, 302 when off
}
EOF
cat > $d/Composers/RedirectsComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;

namespace Umbraco.Community.Redirects.Composers;

public class RedirectsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
    }
}
EOF
