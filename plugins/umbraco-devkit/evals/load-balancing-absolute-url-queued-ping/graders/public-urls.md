---
type: llm
weight: 2
---
Context: the queued URLs are sent from a background job, outside any request. Behind a
load balancer the host of an incoming request can be an internal name, and a site with
several domains has a different public host per page.

PASS if each page's absolute URL comes from Umbraco's routing for that page: the
published URL provider in absolute mode (`IPublishedUrlProvider.GetUrl(..., UrlMode.Absolute)`,
`content.Url(mode: UrlMode.Absolute)`) using the domains assigned in Umbraco, worked out
either when the page is published or in the job (inside an ensured Umbraco context), or
configuration every server shares such as `WebRouting:UmbracoApplicationUrl`.

FAIL if the host comes from an `HttpContext` read in the background job, a host remembered
from an earlier request in a static or singleton, the raw request headers rebuilt by hand
(`X-Forwarded-Host`), a hard-coded host, or relative URLs sent to IndexNow.
