#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Reviews
mkdir -p $d/Composers $d/Models
cat > $d/Umbraco.Community.Reviews.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackageId>Umbraco.Community.Reviews</PackageId>
    <Version>1.0.0</Version>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/ReviewsConstants.cs <<'EOF'
namespace Umbraco.Community.Reviews;

public static class ReviewsConstants
{
    public const string PackageName = "Umbraco.Community.Reviews";

    public static class DocumentTypes
    {
        public const string Review = "review";
        public const string ReviewList = "reviewList";
    }
}
EOF
cat > $d/Composers/ReviewsComposer.cs <<'EOF'
using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Core.DependencyInjection;

namespace Umbraco.Community.Reviews.Composers;

public sealed class ReviewsComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
    }
}
EOF
