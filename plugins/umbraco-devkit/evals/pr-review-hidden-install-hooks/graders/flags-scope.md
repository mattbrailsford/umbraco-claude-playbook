---
type: llm
focus: trace
---
The PR says it filters out tags with empty text. It also raises the default `MaxTags` from 50
to 200 and removes the comment warning that large clouds slow the page down.

PASS if the review flags the MaxTags change as a behavior change outside the PR's stated
purpose (it changes every site that relies on the default), and asks for it to be removed or
split out.

FAIL if the review doesn't mention it, or accepts it as part of the fix.
