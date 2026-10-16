#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.PagePdf
mkdir -p $d/Sections $d/Composers $d/Controllers
cat > $d/Umbraco.Community.PagePdf.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackageId>Umbraco.Community.PagePdf</PackageId>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="QuestPDF" Version="2025.7.0" />
  </ItemGroup>
</Project>
EOF
cat > $d/Sections/IPdfSection.cs <<'EOF'
using QuestPDF.Infrastructure;
using Umbraco.Cms.Core.Models.PublishedContent;

namespace Umbraco.Community.PagePdf.Sections;

/// <summary>One block of the generated PDF.</summary>
public interface IPdfSection
{
    /// <summary>Whether this section has anything to show for the page.</summary>
    bool AppliesTo(IPublishedContent page);

    void Compose(IContainer container, IPublishedContent page);
}
EOF
cat > $d/Sections/TitleSection.cs <<'EOF'
using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using Umbraco.Cms.Core.Models.PublishedContent;

namespace Umbraco.Community.PagePdf.Sections;

public sealed class TitleSection : IPdfSection
{
    public bool AppliesTo(IPublishedContent page) => true;

    public void Compose(IContainer container, IPublishedContent page)
        => container.Text(page.Name).FontSize(24).Bold();
}
EOF
cat > $d/Sections/BodySection.cs <<'EOF'
using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using Umbraco.Cms.Core.Models.PublishedContent;
using Umbraco.Extensions;

namespace Umbraco.Community.PagePdf.Sections;

public sealed class BodySection : IPdfSection
{
    public bool AppliesTo(IPublishedContent page) => page.HasValue("bodyText");

    public void Compose(IContainer container, IPublishedContent page)
        => container.Text(page.Value<string>("bodyText") ?? "");
}
EOF
cat > $d/Sections/FooterSection.cs <<'EOF'
using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using Umbraco.Cms.Core.Models.PublishedContent;

namespace Umbraco.Community.PagePdf.Sections;

public sealed class FooterSection : IPdfSection
{
    public bool AppliesTo(IPublishedContent page) => true;

    public void Compose(IContainer container, IPublishedContent page)
        => container.Text($"Last updated {page.UpdateDate:d}").FontSize(9);
}
EOF
cat > $d/PdfGenerator.cs <<'EOF'
using QuestPDF.Fluent;
using Umbraco.Cms.Core.Models.PublishedContent;
using Umbraco.Community.PagePdf.Sections;

namespace Umbraco.Community.PagePdf;

public sealed class PdfGenerator
{
    private readonly IPdfSection[] _sections =
    [
        new TitleSection(),
        new BodySection(),
        new FooterSection(),
    ];

    public byte[] Generate(IPublishedContent page) =>
        Document.Create(doc => doc.Page(p => p.Content().Column(column =>
        {
            foreach (IPdfSection section in _sections.Where(s => s.AppliesTo(page)))
            {
                section.Compose(column.Item(), page);
            }
        }))).GeneratePdf();
}
EOF
cat > $d/Composers/PagePdfComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;

namespace Umbraco.Community.PagePdf.Composers;

public sealed class PagePdfComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
        => builder.Services.AddSingleton<PdfGenerator>();
}
EOF
