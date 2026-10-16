---
type: llm
weight: 2
focus: trace
---
PASS if the prefix and paging values reach the SQL only as parameters
(FromSqlInterpolated/FromSql with placeholders, or SqlParameter), and the sort column and
direction come from a fixed mapping or allow-list of known column names, so user input is
never written into the SQL text.

FAIL if the prefix, the sort column, the direction, or the paging values are concatenated
or interpolated into SQL text (for example with FromSqlRaw and $"..."), even after a
validation check that could be bypassed.
