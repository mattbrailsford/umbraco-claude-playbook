---
type: llm
weight: 2
---
Context: Markdig ships to every site that installs MyCompany.HelpText, so a new Markdig
major lands on those sites (and on any other package or site code that also uses Markdig)
in what they expect to be a safe 3.x update. A major of a shipped dependency should wait for
the package's own next major (4.0).

PASS if 3.5.0 does not ship Markdig 1.0.0: either Markdig stays at 0.40.0 in the 3.5.0
changes and the answer explains why (holding the bump for 4.0, closing the PR or ignoring
Markdig majors in Dependabot), or the answer stops before applying it and explains the
problem.

FAIL if `Directory.Packages.props` ends up with Markdig 1.0.0 while the release stays 3.5.0,
with no warning about shipping a dependency major in a minor release.
