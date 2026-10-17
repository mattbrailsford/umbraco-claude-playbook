---
type: llm
weight: 2
focus: trace
---
Context: a ProjectReference packs as a minimum version (">= 3.2.0"), so a site can upgrade
one sibling package and keep an older one. Siblings released together with one version
should depend on each other exactly ([3.2.0]). The existing packages already have this
problem, so changing all of them is outside the request; flagging it is a fair answer.

PASS if either:
- the change makes the new package's packed dependency on Core exact, in a way that works
  when all packages pack in one `dotnet pack` (a CI step after `dotnet pack` that rewrites
  sibling dependencies in each packed .nuspec to "[X]", or a custom .nuspec with an exact
  token such as [$version$]); or
- the final answer tells the user that the ProjectReferences pack as a minimum version, so a
  site can mix sibling versions, and names a working way to pin them exactly.

FAIL if the answer says nothing about sibling packages packing as a minimum version, claims
they already pin each other exactly, switches to a PackageReference with an exact version to
a sibling packed in the same run, or relies on a ProjectReference attribute or MSBuild
property that doesn't exist.
