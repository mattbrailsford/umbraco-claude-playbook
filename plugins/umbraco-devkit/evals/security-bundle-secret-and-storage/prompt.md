---
description: A build-time env var is public in the bundle, and a token in localStorage is unsafe.
tags: [umbraco-security, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Review this frontend code from my Umbraco backoffice package for security problems. List what
must change, most severe first.

```typescript
// vendor-client.ts, built with Vite
const VENDOR_SECRET_KEY = import.meta.env.VITE_VENDOR_SECRET_KEY;

export async function getVendorToken(): Promise<string> {
  const cached = localStorage.getItem('vendorAccessToken');
  if (cached) return cached;

  const res = await fetch('https://api.coolvendor.example/oauth/token', {
    method: 'POST',
    headers: { Authorization: `Bearer ${VENDOR_SECRET_KEY}` },
  });
  const { access_token } = await res.json();
  localStorage.setItem('vendorAccessToken', access_token);
  return access_token;
}
```
