#!/usr/bin/env bash
set -euo pipefail
mkdir -p docs/plans/connections/mockups
cat > docs/plans/connections/SPEC.md <<'EOF'
# Connections: spec

## Data model

`Connection`: `Id` (Guid), `Name`, `ProviderAlias`, `BaseUrl`, `LastUsedUtc`.

## Connections screen

![Connections screen](mockups/connections.png)

<!-- TODO: write this section -->
EOF
cat > docs/plans/connections/mockups/connections.html <<'EOF'
<!-- Source of mockups/connections.png -->
<umb-body-layout headline="Connections">
  <uui-button slot="action" look="primary" label="Create connection"></uui-button>
  <uui-table>
    <uui-table-head>
      <uui-table-head-cell>Name</uui-table-head-cell>
      <uui-table-head-cell>Provider</uui-table-head-cell>
      <uui-table-head-cell>Last used</uui-table-head-cell>
      <uui-table-head-cell></uui-table-head-cell>
    </uui-table-head>
    <uui-table-row>
      <uui-table-cell>Main CRM</uui-table-cell><uui-table-cell>HubSpot</uui-table-cell>
      <uui-table-cell>2 hours ago</uui-table-cell>
      <uui-table-cell><uui-button look="secondary" label="Test"></uui-button></uui-table-cell>
    </uui-table-row>
  </uui-table>
</umb-body-layout>
EOF
cat > docs/plans/connections/design-notes.md <<'EOF'
Notes from the design call (raw):

- screen is a table: Name, Provider, Last used, then a Test button per row. Create
  connection button top right, primary look. headline "Connections". rows sorted by name.
- Test button: calls POST .../connections/{id}/test. Button goes into a waiting state.
  Timeout is 10 seconds. On success show a green toast with the round trip ms. On failure
  red toast with the provider's message. Test doesn't change Last used.
- Last used = last time the package actually called the provider with this connection,
  shown relative ("2 hours ago"), "Never" if null.
- empty state: no table, just text "No connections yet" + the create button.
- max 20 connections per site, Create button is disabled at 20 with a tooltip saying why.
- only users with access to the Settings section see the screen at all.
- row click opens the edit workspace.
EOF
