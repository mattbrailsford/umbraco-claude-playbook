---
type: regex
pattern: 'Microsoft\.EntityFrameworkCore\.SqlServer"\s+Version="(?:10\.0\.0|\[10\.0\.0,[^"]*)"'
target: {source: file, path: Directory.Packages.props}
---
