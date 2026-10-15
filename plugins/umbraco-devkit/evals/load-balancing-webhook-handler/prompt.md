---
description: A webhook sent from a cache refresher notification fires once per server; it belongs in an action notification.
tags: [umbraco-load-balancing, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package POSTs to a customer's webhook whenever content is published. I handle
`ContentCacheRefresherNotification`, so the webhook only goes out once the cache has the new
content. Some customer sites are load balanced across several servers. Is this handler OK?
If not, what should I change?

```csharp
public class PublishWebhookHandler(IHttpClientFactory httpClientFactory)
    : INotificationAsyncHandler<ContentCacheRefresherNotification>
{
    public async Task HandleAsync(ContentCacheRefresherNotification notification, CancellationToken cancellationToken)
    {
        var client = httpClientFactory.CreateClient("MyPackage");
        await client.PostAsJsonAsync("https://example.com/hook", notification.MessageObject, cancellationToken);
    }
}
```
