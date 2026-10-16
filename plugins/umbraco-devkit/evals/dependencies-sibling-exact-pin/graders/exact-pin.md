---
type: llm
weight: 2
focus: trace
---
PASS if the change makes each packed sibling dependency an exact version ([3.2.0] style)
in a way that actually works when all three pack in one `dotnet pack`. Valid approaches:
keeping the ProjectReferences and adding a CI step after `dotnet pack` that rewrites the
sibling dependencies in each packed .nuspec from version="X" to version="[X]"; or a custom
.nuspec (NuspecFile) whose sibling dependencies use an exact token such as [$version$].

FAIL if it switches to a PackageReference with an exact version to a sibling packed in the
same run (the sibling's package doesn't exist yet at restore), relies on a ProjectReference
attribute or MSBuild property that doesn't exist to make it pack exactly, or only documents
the problem without changing anything.
