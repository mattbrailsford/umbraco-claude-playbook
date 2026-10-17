#!/usr/bin/env bash
set -euo pipefail
d=src/MyPackage.SearchSync
mkdir -p $d/Indexing $d/Composers
cat > $d/MyPackage.SearchSync.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Indexing/SearchRecord.cs <<'EOF'
namespace MyPackage.SearchSync.Indexing;

public class SearchRecord
{
    public Guid Id { get; set; }
    public string Name { get; set; } = "";
    public string Url { get; set; } = "";
    public Dictionary<string, object?> Fields { get; } = new();
}
EOF
cat > $d/Indexing/ISearchClient.cs <<'EOF'
namespace MyPackage.SearchSync.Indexing;

/// <summary>Talks to the external search service. Accepts batches of up to 1,000 records.</summary>
public interface ISearchClient
{
    Task UpsertAsync(IReadOnlyCollection<SearchRecord> records, CancellationToken ct = default);
    Task DeleteAsync(IReadOnlyCollection<Guid> ids, CancellationToken ct = default);
    Task ClearAsync(CancellationToken ct = default);
}
EOF
cat > $d/Indexing/PublishedContentIndexer.cs <<'EOF'
using Umbraco.Cms.Core.Events;
using Umbraco.Cms.Core.Models;
using Umbraco.Cms.Core.Notifications;
using Umbraco.Cms.Core.Services;

namespace MyPackage.SearchSync.Indexing;

/// <summary>Pushes each page to the search service when it's published.</summary>
public class PublishedContentIndexer(ISearchClient searchClient, IDataTypeService dataTypeService)
    : INotificationAsyncHandler<ContentPublishedNotification>
{
    public async Task HandleAsync(ContentPublishedNotification notification, CancellationToken cancellationToken)
    {
        var records = new List<SearchRecord>();
        foreach (IContent content in notification.PublishedEntities)
        {
            records.Add(await BuildRecordAsync(content));
        }

        await searchClient.UpsertAsync(records, cancellationToken);
    }

    private async Task<SearchRecord> BuildRecordAsync(IContent content)
    {
        var record = new SearchRecord { Id = content.Key, Name = content.Name ?? "" };
        foreach (IProperty property in content.Properties)
        {
            IDataType? dataType = await dataTypeService.GetAsync(property.PropertyType.DataTypeKey);
            record.Fields[property.Alias] = FieldConverter.Convert(property.GetValue(), dataType?.EditorAlias);
        }

        return record;
    }
}
EOF
cat > $d/Indexing/FieldConverter.cs <<'EOF'
namespace MyPackage.SearchSync.Indexing;

internal static class FieldConverter
{
    public static object? Convert(object? value, string? editorAlias) => editorAlias switch
    {
        "Umbraco.TrueFalse" => value is 1 or "1" or true,
        "Umbraco.Integer" or "Umbraco.Decimal" => value,
        _ => value?.ToString(),
    };
}
EOF
cat > $d/Composers/SearchSyncComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Cms.Core.Notifications;
using MyPackage.SearchSync.Indexing;

namespace MyPackage.SearchSync.Composers;

public class SearchSyncComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.AddNotificationAsyncHandler<ContentPublishedNotification, PublishedContentIndexer>();
    }
}
EOF
