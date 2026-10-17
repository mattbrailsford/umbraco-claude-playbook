---
type: llm
weight: 2
focus: {source: file, path: src/MyPackage/PropertyEditors/Color/ColorValueConverter.cs}
---
PASS if the converter overrides `GetPropertyCacheLevel` and returns
`PropertyCacheLevel.Element` (or `Elements`). The value only depends on its own data, so
Element is the natural choice, but Elements is acceptable.

FAIL if it does not override `GetPropertyCacheLevel` (the base class returns Snapshot,
which the published cache treats as None, so the conversion runs on every read), returns
None or Snapshot, or the file doesn't exist.
