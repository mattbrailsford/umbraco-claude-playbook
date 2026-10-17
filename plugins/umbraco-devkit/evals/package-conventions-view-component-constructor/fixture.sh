#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Reviews
mkdir -p $d/ViewComponents $d/Services $d/Composers $d/Views/Shared/Components/Reviews
cat > $d/Umbraco.Community.Reviews.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackageId>Umbraco.Community.Reviews</PackageId>
    <Version>2.3.1</Version>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Website" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > README.md <<'EOF'
# Umbraco.Community.Reviews

Product reviews for Umbraco 17 sites.

## Showing reviews

```cshtml
@await Component.InvokeAsync("Reviews", new { productKey = Model.Key })
```

## Customising

To change which reviews show or add data to the view, inherit from `ReviewsViewComponent`
and register your class instead:

```csharp
public class MyReviewsViewComponent : ReviewsViewComponent
{
    public MyReviewsViewComponent(IReviewService reviewService) : base(reviewService) { }

    public override async Task<IViewComponentResult> InvokeAsync(Guid productKey)
    {
        // your changes
        return await base.InvokeAsync(productKey);
    }
}
```
EOF
cat > $d/Services/IReviewService.cs <<'EOF'
namespace Umbraco.Community.Reviews.Services;

public sealed record Review(Guid Key, Guid ProductKey, string Author, int Rating, string Text, DateTime CreatedUtc);

public interface IReviewService
{
    Task<IReadOnlyList<Review>> GetForProductAsync(Guid productKey, int take);
}
EOF
cat > $d/Services/ReviewService.cs <<'EOF'
namespace Umbraco.Community.Reviews.Services;

internal sealed class ReviewService : IReviewService
{
    public Task<IReadOnlyList<Review>> GetForProductAsync(Guid productKey, int take)
        => Task.FromResult<IReadOnlyList<Review>>([]); // storage omitted
}
EOF
cat > $d/Services/IReviewSummaryService.cs <<'EOF'
namespace Umbraco.Community.Reviews.Services;

public sealed record ReviewSummary(double AverageRating, int Count);

/// <summary>Average rating and review count for a product, cached per product.</summary>
public interface IReviewSummaryService
{
    Task<ReviewSummary> GetAsync(Guid productKey);
}
EOF
cat > $d/Services/ReviewSummaryService.cs <<'EOF'
namespace Umbraco.Community.Reviews.Services;

internal sealed class ReviewSummaryService : IReviewSummaryService
{
    public Task<ReviewSummary> GetAsync(Guid productKey) => Task.FromResult(new ReviewSummary(0, 0)); // storage omitted
}
EOF
cat > $d/Composers/ReviewsComposer.cs <<'EOF'
using Microsoft.Extensions.DependencyInjection;
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;
using Umbraco.Community.Reviews.Services;

namespace Umbraco.Community.Reviews.Composers;

public sealed class ReviewsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddScoped<IReviewService, ReviewService>();
        builder.Services.AddScoped<IReviewSummaryService, ReviewSummaryService>();
    }
}
EOF
cat > $d/ViewComponents/ReviewsViewComponent.cs <<'EOF'
using Microsoft.AspNetCore.Mvc;
using Umbraco.Community.Reviews.Services;

namespace Umbraco.Community.Reviews.ViewComponents;

public sealed record ReviewsViewModel(Guid ProductKey, IReadOnlyList<Review> Reviews);

public class ReviewsViewComponent : ViewComponent
{
    protected IReviewService ReviewService { get; }

    public ReviewsViewComponent(IReviewService reviewService)
        => ReviewService = reviewService;

    public virtual async Task<IViewComponentResult> InvokeAsync(Guid productKey)
    {
        IReadOnlyList<Review> reviews = await ReviewService.GetForProductAsync(productKey, take: 10);
        return View(new ReviewsViewModel(productKey, reviews));
    }
}
EOF
cat > $d/Views/Shared/Components/Reviews/Default.cshtml <<'EOF'
@model Umbraco.Community.Reviews.ViewComponents.ReviewsViewModel
<section class="reviews">
    @foreach (var review in Model.Reviews)
    {
        <article>
            <strong>@review.Author</strong> (@review.Rating/5)
            <p>@review.Text</p>
        </article>
    }
</section>
EOF
