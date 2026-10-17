#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.SiteSearch
mkdir -p $d/Composers $d/Handlers $d/Services
cat > $d/Umbraco.Community.SiteSearch.csproj <<'EOF'
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
cat > $d/SiteSearchOptions.cs <<'EOF'
namespace Umbraco.Community.SiteSearch;

/// <summary>Bound from the "SiteSearch" section of appsettings.json.</summary>
public class SiteSearchOptions
{
    /// <summary>The customer's external search indexer. Receives JSON POSTs.</summary>
    public string IndexerUrl { get; set; } = "";
    public string ApiKey { get; set; } = "";
}
EOF
cat > $d/Services/SearchSuggestionsCache.cs <<'EOF'
using Umbraco.Cms.Core.Cache;

namespace Umbraco.Community.SiteSearch.Services;

/// <summary>Type-ahead suggestions built from page titles, cached per server.</summary>
public sealed class SearchSuggestionsCache(AppCaches appCaches)
{
    private const string Prefix = "Umbraco.Community.SiteSearch.Suggestions.";

    public IReadOnlyList<string> Get(string culture, Func<IReadOnlyList<string>> build) =>
        appCaches.RuntimeCache.GetCacheItem(Prefix + culture, build)!;

    public void Clear() => appCaches.RuntimeCache.ClearByKey(Prefix);
}
EOF
cat > $d/Handlers/ContentChangedHandler.cs <<'EOF'
using Umbraco.Cms.Core.Events;
using Umbraco.Cms.Core.Notifications;
using Umbraco.Community.SiteSearch.Services;

namespace Umbraco.Community.SiteSearch.Handlers;

/// <summary>Keeps the package's own caches in step with content changes.</summary>
public sealed class ContentChangedHandler(SearchSuggestionsCache suggestions)
    : INotificationHandler<ContentCacheRefresherNotification>
{
    public void Handle(ContentCacheRefresherNotification notification)
    {
        // Any content change can change a title, so drop the suggestions.
        suggestions.Clear();
    }
}
EOF
cat > $d/Composers/SiteSearchComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Cms.Core.Notifications;
using Umbraco.Community.SiteSearch.Handlers;
using Umbraco.Community.SiteSearch.Services;

namespace Umbraco.Community.SiteSearch.Composers;

public class SiteSearchComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.Configure<SiteSearchOptions>(builder.Config.GetSection("SiteSearch"));
        builder.Services.AddSingleton<SearchSuggestionsCache>();
        builder.AddNotificationHandler<ContentCacheRefresherNotification, ContentChangedHandler>();
    }
}
EOF
