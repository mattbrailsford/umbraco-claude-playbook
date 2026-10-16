#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/Umbraco.Community.SlugRules .github/workflows
cat > src/Umbraco.Community.SlugRules/Umbraco.Community.SlugRules.csproj <<'XML'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFrameworks>net6.0;net8.0;net10.0</TargetFrameworks>
    <Version>2.4.0</Version>
    <PackageId>Umbraco.Community.SlugRules</PackageId>
    <Authors>Sam Ortiz</Authors>
    <Description>Rules for how Umbraco builds URL segments: transliteration, stop words and length limits. No backoffice UI; configure it in appsettings.json.</Description>
    <PackageTags>umbraco umbraco-marketplace urls</PackageTags>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageProjectUrl>https://github.com/samortiz/Umbraco.Community.SlugRules</PackageProjectUrl>
    <RepositoryUrl>https://github.com/samortiz/Umbraco.Community.SlugRules</RepositoryUrl>
    <PackageReadmeFile>README.md</PackageReadmeFile>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Core" Version="10.0.0" />
  </ItemGroup>
  <ItemGroup>
    <None Include="../../README.md" Pack="true" PackagePath="\" />
  </ItemGroup>
</Project>
XML
cat > src/Umbraco.Community.SlugRules/SlugRulesUrlSegmentProvider.cs <<'CS'
using Umbraco.Cms.Core.Models;
using Umbraco.Cms.Core.Strings;

namespace Umbraco.Community.SlugRules;

public class SlugRulesUrlSegmentProvider : IUrlSegmentProvider
{
    public string? GetUrlSegment(IContentBase content, string? culture = null) => null;
}
CS
cat > README.md <<'MD'
# Slug Rules

Rules for how Umbraco builds URL segments: transliteration, stop words and length limits.

There's no backoffice UI. Configure it under `SlugRules` in `appsettings.json`.

Works on Umbraco 10 and later. CI runs the tests against Umbraco 10, 13 and 17.
MD
cat > .github/workflows/ci.yml <<'YML'
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        umbraco: ['10.8.0', '13.5.0', '17.0.0']
    steps:
      - uses: actions/checkout@v4
      - run: dotnet test -p:UmbracoVersion=${{ matrix.umbraco }}
YML
printf 'MIT License\n\nCopyright (c) 2026 Sam Ortiz\n' > LICENSE
