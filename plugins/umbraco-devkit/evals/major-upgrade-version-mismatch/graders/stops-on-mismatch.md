---
type: llm
weight: 2
---
The .csproj targets Umbraco.Cms.Web.Common 17.6.1, but the client's package.json has
`@umbraco-cms/backoffice` 16.4.0.

PASS if the reply stops and reports that the C# and frontend CMS versions disagree, and says
that needs fixing before the upgrade starts.

FAIL if it doesn't notice the mismatch, or carries on with the upgrade anyway.
