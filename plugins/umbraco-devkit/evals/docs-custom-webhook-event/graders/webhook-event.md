---
type: llm
weight: 2
focus: trace
---
PASS if the code written in this run:
- defines a class deriving from WebhookEventBase<OrderSavedNotification>
- implements the abstract Alias property
- has a constructor that passes IWebhookFiringService, IWebhookService,
  IOptionsMonitor<WebhookSettings> and IServerRoleAccessor to the base constructor
- registers it in the composer with builder.AddWebhookEvent<T>() or
  builder.WebhookEvents().Add<T>()

A [WebhookEvent("Order Saved", ...)] attribute for the display name is optional.

FAIL if it implements IWebhookEvent from scratch, registers it as a plain notification
handler only, passes the wrong constructor arguments, or doesn't register it as a webhook
event.
