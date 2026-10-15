---
type: llm
---
PASS if the old overload is marked [Obsolete] with a message that names the version it will
be removed in, and that version is Umbraco 20 (or the package's version that lines up with
v20), on both the v17 and v18 branches.

FAIL if there is no [Obsolete], the message names no removal version, or it names a
different version.
