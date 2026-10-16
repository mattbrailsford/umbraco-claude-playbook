---
type: llm
focus: {source: file, path: src/Umbraco.Community.Items/Services/ItemService.cs}
---
Context: the package supports Umbraco 17 and 18 on one branch each, so a member obsoleted
on both should be removed no earlier than Umbraco 20 (the highest supported major + 2).

PASS if the old overload is marked [Obsolete] with a message that names the version it will
be removed in, and that version is Umbraco 20, or package 7.0 (the package version that lines up
with Umbraco 20: 4.x is v17, 5.x is v18).

FAIL if there is no [Obsolete], the message names no removal version, or it names an
earlier version (such as Umbraco 18 or 19, or package 5.0 or 6.0).
