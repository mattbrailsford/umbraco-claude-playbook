---
type: regex
pattern: from\s+['"]lit(?:/[^'"]*)?['"]
match: not_contains
target: {source: file, path: src/MyPackage/Client/src/tag-list.element.ts}
---
