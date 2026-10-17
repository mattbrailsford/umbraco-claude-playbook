#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.IndexNow
mkdir -p $d/Services
cat > $d/Umbraco.Community.IndexNow.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Api.Management" Version="[17.0.0, 18)" />
    <PackageReference Include="Umbraco.Cms.Persistence.EFCore" Version="[17.0.0, 18)" />
  </ItemGroup>
</Project>
EOF
cat > $d/Services/IndexNowClient.cs <<'EOF'
namespace Umbraco.Community.IndexNow.Services;

public sealed class IndexNowClient(HttpClient http)
{
    // Posts the batch to api.indexnow.org with the site's key. Every URL must be absolute.
    public async Task SubmitAsync(string host, IReadOnlyCollection<string> absoluteUrls, CancellationToken cancellationToken)
    {
        using HttpResponseMessage response = await http.PostAsJsonAsync(
            "https://api.indexnow.org/indexnow", new { host, urlList = absoluteUrls }, cancellationToken);
        response.EnsureSuccessStatusCode();
    }
}
EOF
cat > $d/IndexNowOptions.cs <<'EOF'
namespace Umbraco.Community.IndexNow;

public class IndexNowOptions
{
    public string Key { get; set; } = "";
}
EOF
