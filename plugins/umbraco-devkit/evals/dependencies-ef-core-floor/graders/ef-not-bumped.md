---
type: regex
pattern: 'EntityFrameworkCore\.(?:SqlServer|Sqlite)"\s+Version="10\.0\.10"'
match: not_contains
target: {source: file, path: Directory.Packages.props}
---
