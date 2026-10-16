---
description: Indexing that calls IContentService and IDataTypeService per record. From umbraco/Umbraco.Cms.Integrations#140.
tags: [umbraco-performance, should-trigger, real-bug]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

This pushes published content to an external search service from my Umbraco 17 package.
It's called with the IDs of every published page during a full rebuild. Please review it.

```csharp
public async Task<List<SearchRecord>> BuildRecordsAsync(IEnumerable<int> publishedIds)
{
    var records = new List<SearchRecord>();
    foreach (var id in publishedIds)
    {
        var content = _contentService.GetById(id);
        if (content is null) continue;

        var record = new SearchRecord { Id = content.Key, Name = content.Name };
        foreach (var property in content.Properties)
        {
            var dataType = _dataTypeService
                .GetByEditorAlias(property.PropertyType.PropertyEditorAlias)
                .FirstOrDefault();
            record.Fields[property.Alias] = Convert(property.GetValue(), dataType);
        }
        records.Add(record);
    }
    return records;
}
```
