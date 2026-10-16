#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Downloads
cat > MyPackage.sln <<'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
EOF
cat > src/MyPackage/MyPackage.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework><PackageId>MyCompany.MyPackage</PackageId></PropertyGroup>
  <ItemGroup><PackageReference Include="Umbraco.Cms.Web.Common" Version="[17.0.0, 18.0.0)" /></ItemGroup>
</Project>
EOF
cat > src/MyPackage/Downloads/DownloadArea.cs <<'EOF'
namespace MyPackage.Downloads;

public class DownloadArea
{
    public Guid Key { get; set; }
    public string Alias { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string StoragePath { get; set; } = string.Empty;

    /// <summary>Member groups that may download. Empty means every logged-in member may.</summary>
    public List<Guid> AllowedMemberGroupKeys { get; set; } = [];

    /// <summary>Member groups that may never download, even if also allowed.</summary>
    public List<Guid> DeniedMemberGroupKeys { get; set; } = [];
}
EOF
cat > src/MyPackage/Downloads/DownloadAreaService.cs <<'EOF'
namespace MyPackage.Downloads;

public interface IDownloadAreaService
{
    Task<IReadOnlyList<DownloadArea>> GetAllAsync();
    Task<DownloadArea?> GetAsync(Guid key);
    Task<DownloadArea?> GetByAliasAsync(string alias);
    Task SaveAsync(DownloadArea area);   // publishes DownloadAreaSavedNotification
    Task DeleteAsync(Guid key);          // publishes DownloadAreaDeletedNotification
}

public sealed record DownloadAreaSavedNotification(DownloadArea Area) : INotification;
public sealed record DownloadAreaDeletedNotification(Guid Key) : INotification;
EOF
cat > src/MyPackage/Downloads/DownloadAccess.cs <<'EOF'
namespace MyPackage.Downloads;

public static class DownloadAccess
{
    public static bool CanDownload(DownloadArea area, IReadOnlyCollection<Guid> memberGroupKeys)
    {
        if (area.DeniedMemberGroupKeys.Any(memberGroupKeys.Contains)) return false;
        return area.AllowedMemberGroupKeys.Count == 0 || area.AllowedMemberGroupKeys.Any(memberGroupKeys.Contains);
    }
}
EOF
