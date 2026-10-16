---
type: llm
weight: 2
---
PASS if the answer says not to ship the Markdig major in a 3.x minor release: Markdig ships
to every site that installs the package, so a new major lands on them (and on any other
package or site code that also uses Markdig) in what they expect to be a safe update. It
should hold the bump for the package's next major (4.0), and suggest closing the PR or
ignoring Markdig majors in Dependabot.

FAIL if it says merging is fine after testing or reading the changelog, without holding the
major for the package's next major release.
