---
type: llm
---
PASS if the vendor access token is not kept in `localStorage` or `sessionStorage`: it stays
on the server (cached there), or only in memory.

FAIL if any code written in this run stores the vendor access token in `localStorage` or
`sessionStorage`.
