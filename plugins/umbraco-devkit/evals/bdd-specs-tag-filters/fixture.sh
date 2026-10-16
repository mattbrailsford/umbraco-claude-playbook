#!/usr/bin/env bash
set -euo pipefail
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.TagCloud

An Umbraco 17 package (C# plus a Lit backoffice client). Trunk branch: `main`.

## Feature workflow

Each feature gets a plan folder at `docs/plans/<feature-slug>/`, created on `main`. Closed
plans move to `docs/archive/plans/<feature-slug>/`. Ideas live in `docs/ideas/`.
EOF
mkdir -p src/Umbraco.Community.TagCloud/Services docs/plans/tag-filters
cat > src/Umbraco.Community.TagCloud/Umbraco.Community.TagCloud.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" />
  </ItemGroup>
</Project>
EOF
cat > src/Umbraco.Community.TagCloud/Services/TagCloudService.cs <<'EOF'
using Umbraco.Cms.Core.Services;

namespace Umbraco.Community.TagCloud.Services;

public class TagCloudService(ITagService tagService)
{
    public IReadOnlyList<(string Text, int Weight)> GetCloud(string group) =>
        tagService.GetAllContentTags(group)
            .OrderByDescending(t => t.NodeCount)
            .Select(t => (t.Text, t.NodeCount))
            .ToList();
}
EOF
cat > docs/plans/tag-filters/README.md <<'EOF'
# Tag filters

Read these in order:

1. [x] [BRIEF.md](./BRIEF.md) — editors can hide tags from the cloud
2. [x] [ARCHITECTURE.md](./ARCHITECTURE.md) — a filter list stored in settings, applied in TagCloudService
3. [x] [SPEC.md](./SPEC.md) — exclude by exact name or prefix, case-insensitive
4. [x] [STORIES.md](./STORIES.md) — two stories
5. [x] [PLAN.md](./PLAN.md) — three tasks
6. [ ] [BUILD-LOG.md](./BUILD-LOG.md) — <pending>

See [DECISION-LOG.md](./DECISION-LOG.md) for why things changed along the way.
EOF
cat > docs/plans/tag-filters/BRIEF.md <<'EOF'
# Tag filters: brief

## Problem
Editors can't keep internal tags ("draft", "internal-*") out of the public tag cloud.

## Success
No internal tag shows in the cloud once it's on the filter list.
EOF
cat > docs/plans/tag-filters/ARCHITECTURE.md <<'EOF'
# Tag filters: architecture

- `TagFilterOptions` bound from `TagCloud:Filters` in appsettings.json: a list of exact names
  and a list of prefixes.
- `TagFilter` applies the options; `TagCloudService` calls it before ordering.
- No database change.
- Options are validated on start (`ValidateOnStart`); an empty prefix is invalid.
EOF
cat > docs/plans/tag-filters/SPEC.md <<'EOF'
# Tag filters: spec

- A tag whose text equals an exact name, ignoring case, is left out.
- A tag whose text starts with a prefix, ignoring case, is left out.
- With no filters configured, the cloud is unchanged.

## Management API surface
None.

## Frontend components
None.
EOF
cat > docs/plans/tag-filters/STORIES.md <<'EOF'
# Tag filters: stories

## STORY-1: Hide tags by name
As an editor, I can list tag names to hide, so drafts never show publicly.

- Given "draft" is an excluded name, when the cloud has a tag "Draft", then "Draft" is not in the cloud.
- Given "draft" is an excluded name, when the cloud has a tag "drafting", then "drafting" is in the cloud.

## STORY-2: Hide tags by prefix
As an editor, I can hide every tag with a prefix, so a family of internal tags stays out.

- Given "internal-" is an excluded prefix, when the cloud has "internal-hr" and "Internal-IT", then neither is in the cloud.
- Given "internal-" is an excluded prefix, when the cloud has "intern", then "intern" is in the cloud.

## STORY-3: No filters
- Given no filters are configured, when the cloud is built, then it has every tag, in the same order as before.

## Errors
- Given an excluded prefix is empty or whitespace, when the options are bound, then validation fails with a message naming `TagCloud:Filters:Prefixes`.
EOF
cat > docs/plans/tag-filters/PLAN.md <<'EOF'
# Tag filters: plan

- [ ] Add `TagFilterOptions` and bind it from `TagCloud:Filters`.
- [ ] Add `TagFilter` with exact-name and prefix rules.
- [ ] Call `TagFilter` from `TagCloudService` before ordering.
EOF
cat > docs/plans/tag-filters/DECISION-LOG.md <<'EOF'
# Tag filters: decision log
EOF
mkdir -p tests/Umbraco.Community.TagCloud.Tests/Builders tests/Umbraco.Community.TagCloud.Tests/Services
cat > tests/Umbraco.Community.TagCloud.Tests/Umbraco.Community.TagCloud.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><IsPackable>false</IsPackable></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.*" />
    <PackageReference Include="NUnit" Version="4.*" />
    <PackageReference Include="NUnit3TestAdapter" Version="5.*" />
    <PackageReference Include="Moq" Version="4.*" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="../../src/Umbraco.Community.TagCloud/Umbraco.Community.TagCloud.csproj" />
  </ItemGroup>
</Project>
EOF
cat > tests/Umbraco.Community.TagCloud.Tests/Builders/TagBuilder.cs <<'EOF'
using Umbraco.Cms.Core.Models;

namespace Umbraco.Community.TagCloud.Tests.Builders;

public class TagBuilder
{
    private string _text = "tag";
    private int _nodeCount = 1;

    public TagBuilder WithText(string text) { _text = text; return this; }
    public TagBuilder WithNodeCount(int count) { _nodeCount = count; return this; }

    public ITag Build() => new Tag { Text = _text, Group = "default", NodeCount = _nodeCount };
}
EOF
cat > tests/Umbraco.Community.TagCloud.Tests/Services/TagCloudServiceTests.cs <<'EOF'
using Moq;
using Umbraco.Cms.Core.Models;
using Umbraco.Cms.Core.Services;
using Umbraco.Community.TagCloud.Services;
using Umbraco.Community.TagCloud.Tests.Builders;

namespace Umbraco.Community.TagCloud.Tests.Services;

public class TagCloudServiceTests
{
    public class GivenTagsWithDifferentCounts
    {
        private IReadOnlyList<(string Text, int Weight)> _cloud = null!;

        [SetUp]
        public void Arrange()
        {
            var tagService = new Mock<ITagService>();
            tagService.Setup(s => s.GetAllContentTags("default", null)).Returns(new ITag[]
            {
                new TagBuilder().WithText("small").WithNodeCount(1).Build(),
                new TagBuilder().WithText("big").WithNodeCount(9).Build(),
            });
            _cloud = new TagCloudService(tagService.Object).GetCloud("default");
        }

        [Test]
        public void OrdersTheBiggestTagFirst() => Assert.That(_cloud[0].Text, Is.EqualTo("big"));
    }
}
EOF
