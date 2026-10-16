---
type: regex
pattern: 'Microsoft\.EntityFrameworkCore\.Design"\s+Version="(?:10\.0\.0|\[10\.0\.0,[^"]*)"'
target: {source: file, path: Directory.Packages.props}
---
