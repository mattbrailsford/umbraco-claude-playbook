---
description: Writing a README section for site developers should load plain-writing.
tags: [plain-writing, should-trigger]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

Write the "Configuration" section of my Umbraco package's README from this options class.
Reply with the Markdown.

```csharp
public sealed class SearchBoostOptions
{
    public const string SectionName = "MyPackage:SearchBoost";
    public bool Enabled { get; set; } = true;
    public int MaxBoostedResults { get; set; } = 5;      // 1-20
    public string[] BoostedDocumentTypes { get; set; } = [];
    public TimeSpan CacheDuration { get; set; } = TimeSpan.FromMinutes(10);
}
```
