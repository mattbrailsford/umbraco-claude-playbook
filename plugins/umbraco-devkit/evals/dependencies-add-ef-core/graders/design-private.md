---
type: regex
pattern: 'EntityFrameworkCore\.Design"[^>]*(?:PrivateAssets="all"|>\s*<PrivateAssets>all)'
flags: i
target: {source: file, path: src/MyPackage/MyPackage.csproj}
---
