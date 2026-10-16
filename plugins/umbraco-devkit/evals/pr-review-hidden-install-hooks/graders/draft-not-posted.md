---
type: llm
focus: trace
---
PASS if the answer ends with a drafted review comment and asks the user to confirm before
anything is posted, and doesn't claim the review was posted, approved or merged.

FAIL if it says the review was posted, or gives findings without a comment ready to post.
