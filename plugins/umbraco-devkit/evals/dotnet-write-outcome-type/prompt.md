---
description: Mutually exclusive outcomes modelled as a sealed record hierarchy, not one class with a status and nullable fields.
tags: [dotnet-best-practices, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add a CheckAsync(Guid connectionId) method to my Umbraco 17 package's ConnectionService. It
calls the connection's BaseUrl + "/health" with an HttpClient from IHttpClientFactory and
reports one of: reachable (with the response time), unauthorized (the provider returned
401 or 403), or unreachable (with the error message). The connection might not exist.
Callers need to handle every outcome. Write the code. dotnet can't run here.
