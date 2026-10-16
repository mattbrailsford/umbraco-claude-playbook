---
type: llm
weight: 2
focus: trace
---
PASS if the RSS provider does not implement write or delete methods it can't support: the
code splits the read and write capabilities (for example IProductReader and
IProductWriter, with ShopApiProvider implementing both and the RSS provider only the
reader), and code that writes only asks for providers that can write.

FAIL if the RSS provider implements SaveAsync/DeleteAsync by throwing (for example
NotSupportedException or NotImplementedException) or by silently doing nothing.
