#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Webhooks
cat > src/MyPackage/MyPackageComposer.cs <<'EOF'
namespace MyPackage;

public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddHttpClient<WebhookSender>();
        builder.AddNotificationAsyncHandler<ContentPublishedNotification, PublishedWebhookHandler>();
    }
}
EOF
cat > src/MyPackage/Webhooks/WebhookSender.cs <<'EOF'
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace MyPackage.Webhooks;

public sealed class WebhookSender
{
    private readonly HttpClient _http;

    public WebhookSender(HttpClient http)
    {
        _http = http;
        _http.Timeout = TimeSpan.FromSeconds(10);
    }

    public async Task SendAsync(object payload, CancellationToken ct = default)
    {
        var body = JsonSerializer.Serialize(payload);
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes("change-me"));
        var signature = Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes(body)));
        using var request = new HttpRequestMessage(HttpMethod.Post, "https://example.com/hooks/umbraco")
        {
            Content = new StringContent(body, Encoding.UTF8, "application/json"),
        };
        request.Headers.Add("X-Signature", signature);
        (await _http.SendAsync(request, ct)).EnsureSuccessStatusCode();
    }
}
EOF
cat > src/MyPackage/Webhooks/PublishedWebhookHandler.cs <<'EOF'
namespace MyPackage.Webhooks;

internal sealed class PublishedWebhookHandler : INotificationAsyncHandler<ContentPublishedNotification>
{
    private readonly WebhookSender _sender;
    public PublishedWebhookHandler(WebhookSender sender) => _sender = sender;

    public async Task HandleAsync(ContentPublishedNotification notification, CancellationToken ct)
    {
        foreach (var content in notification.PublishedEntities)
            await _sender.SendAsync(new { content.Key, content.Name }, ct);
    }
}
EOF
