---
type: llm
weight: 2
focus: {source: file, path: docs/plans/connections/SPEC.md}
---
Judge only the "Connections screen" section.

PASS if every one of these survives, with its specific value: the 10-second test timeout;
success and failure toasts (round-trip ms on success, the provider's message on failure);
testing doesn't update Last used; Last used is relative and shows "Never" when empty; the
empty state ("No connections yet" plus the create button); the limit of 20 connections
with Create disabled and a tooltip; only users with Settings section access see the
screen; rows sorted by name; clicking a row opens the edit workspace.

FAIL if any item is missing or loses its number ("a short timeout", "a limit").
