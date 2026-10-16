#!/usr/bin/env bash
set -euo pipefail
mkdir -p src/MyPackage/Search src/MyPackage/Client/src/dashboard
cat > src/MyPackage/Search/SearchService.cs <<'EOF'
namespace MyPackage.Search;

internal sealed class SearchService : ISearchService
{
    private readonly IBoostCalculator _boost;
    public SearchService(IBoostCalculator boost) => _boost = boost;

    public IReadOnlyList<SearchHit> Rank(IEnumerable<SearchHit> hits)
        => hits.Select(h => h with { Score = h.Score * _boost.For(h.DocumentType) })
               .OrderByDescending(h => h.Score)
               .ToList();
}
EOF
cat > src/MyPackage/Search/SearchBoostOptions.cs <<'EOF'
namespace MyPackage.Search;

public sealed class SearchBoostOptions
{
    public const string SectionName = "MyPackage:SearchBoost";
    public string[] BoostedDocumentTypes { get; set; } = [];
}
EOF
cat > src/MyPackage/Client/src/dashboard/settings-dashboard.element.ts <<'EOF'
import { html, customElement, state } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';

@customElement('my-package-settings-dashboard')
export class MyPackageSettingsDashboardElement extends UmbLitElement {
	@state() private _boostedTypes: string[] = [];

	override render() {
		return html`<uui-box headline="Search">
			<p>Boosted document types: ${this._boostedTypes.join(', ')}</p>
		</uui-box>`;
	}
}
export default MyPackageSettingsDashboardElement;
EOF
