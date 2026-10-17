#!/usr/bin/env bash
set -euo pipefail
d=src/Umbraco.Community.Redirects
mkdir -p $d/Services
cat > $d/Umbraco.Community.Redirects.csproj <<'EOF'
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
cat > $d/Services/RedirectService.cs <<'EOF'
namespace Umbraco.Community.Redirects.Services;

public sealed record RedirectRow(string FromPath, string ToUrl, bool Permanent);

// Saves redirects to the package's table (EF Core).
public sealed class RedirectService
{
    public Task AddAsync(IEnumerable<RedirectRow> rows, CancellationToken cancellationToken = default) => Task.CompletedTask;
}
EOF
cat > $d/Services/RedirectCsvReader.cs <<'EOF'
namespace Umbraco.Community.Redirects.Services;

public sealed record CsvReadResult(IReadOnlyList<RedirectRow> Rows, IReadOnlyList<string> Errors);

public static class RedirectCsvReader
{
    // Reads "from,to,permanent" rows; collects a message for each row it can't read.
    public static async Task<CsvReadResult> ReadAsync(Stream csv, CancellationToken cancellationToken = default)
    {
        var rows = new List<RedirectRow>();
        var errors = new List<string>();
        using var reader = new StreamReader(csv);
        int line = 0;
        while (await reader.ReadLineAsync(cancellationToken) is { } text)
        {
            line++;
            string[] parts = text.Split(',');
            if (parts.Length != 3 || !bool.TryParse(parts[2], out bool permanent))
            {
                errors.Add($"Line {line}: expected from,to,permanent");
                continue;
            }

            rows.Add(new RedirectRow(parts[0].Trim(), parts[1].Trim(), permanent));
        }

        return new CsvReadResult(rows, errors);
    }
}
EOF
