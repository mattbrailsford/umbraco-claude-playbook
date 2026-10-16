---
description: A controller on the /umbraco/management/api/ path that skips ManagementApiControllerBase has no backoffice auth.
tags: [umbraco-security, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Security review this Umbraco 17 package controller before I merge it. List the problems,
most severe first.

```csharp
[ApiController]
[Route("/umbraco/management/api/v1/my-package/connections")]
public class ConnectionController : ControllerBase
{
    private readonly IConnectionService _connections;

    public ConnectionController(IConnectionService connections) => _connections = connections;

    [HttpGet]
    public async Task<IActionResult> GetAllAsync()
        => Ok(await _connections.GetAllAsync());

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteAsync(Guid id)
    {
        await _connections.DeleteAsync(id);
        return NoContent();
    }
}
```
