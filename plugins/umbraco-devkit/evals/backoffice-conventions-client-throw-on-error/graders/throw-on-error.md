---
type: llm
weight: 2
---
Context: `tryExecute` from `@umbraco-cms/backoffice/resources` shows Umbraco's error
notification only when the promise it is given rejects. This package's generated hey-api
client resolves a failed request (403, 500) to `{ error }` instead of throwing, because
the client isn't configured with `throwOnError: true`. So wrapping the call in `tryExecute`
alone shows the editor nothing when a delete fails.

PASS if, in the final code, a failed delete shows the editor an error notification. Best:
the client is configured to throw (`throwOnError: true` in `generate-openapi.js`'s
`@hey-api/client-fetch` plugin, in `createConfig`, or via
`client.setConfig({ throwOnError: true })`), so every call through `tryExecute` gets it.
Also passes: the delete path checks `error` and shows a notification itself through
`UMB_NOTIFICATION_CONTEXT`.

FAIL if a failed delete would show nothing: the call goes through `tryExecute` (or straight
to the client) with the client still resolving `{ error }`, and nothing else notifies.
