---
type: llm
weight: 2
focus: trace
---
Context: uSync reads a handler's files in no particular tree order, and `SaveAsync` throws
if `ParentId` points at a category that doesn't exist yet. On a new environment none of the
categories exist when the import starts.

PASS if the parent is exported as the parent's Key (or alias), not its integer id, AND
import works whatever order the files are read in: categories are imported parents-first
(for example sorted by depth or path before import), or each is first saved without its
parent and a later pass sets `ParentId` once every category exists, or a missing parent is
retried after the rest.

FAIL if the parent is exported as the integer id, or a child is looked up and saved with
its parent in a single pass with no ordering or second pass, so a child read before its
parent fails or loses its parent.
