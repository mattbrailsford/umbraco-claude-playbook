---
type: regex
pattern: 'Caching\.Memory|CentralPackageTransitivePinningEnabled'
match: not_contains
target: {source: file, path: Directory.Packages.props}
---
