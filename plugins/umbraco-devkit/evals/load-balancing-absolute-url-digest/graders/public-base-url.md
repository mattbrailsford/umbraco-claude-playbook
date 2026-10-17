---
type: llm
weight: 2
---
Context: a background job runs outside any request. Behind a load balancer, the host of a
request that reaches a server can be an internal name or a health check.

PASS if the links' scheme and host come from configuration every server shares: Umbraco's
`WebRouting:UmbracoApplicationUrl` (through `IOptions<WebRoutingSettings>` or
`IHostingEnvironment.ApplicationMainUrl`), or a package option holding the public backoffice
URL, with a sensible message or skip when it isn't set.

FAIL if the job takes the host from an `HttpContext` (`IHttpContextAccessor` in the job),
remembers the host from an earlier request in a static or singleton, hard-codes a host, or
writes relative links into the email.
