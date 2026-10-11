// Shared loader for umb-design mockups. Copy into <plan-folder>/mockups/ beside the screens.
//
// - Loads UUI 2.x, the major Umbraco 17.6+ and 18 ship. For Umbraco 17.5 or older (UUI 1.x),
//   change UUI_VERSION to '1' and the stylesheet links in each page to uui-css@1.
// - Swaps <uui-icon name="icon-*"> for the real backoffice icon, so mockups use the same icon
//   names the code will. Pin BACKOFFICE_VERSION to the project's Umbraco version.

const UUI_VERSION = '2';
const BACKOFFICE_VERSION = '17.6.1';
const ICON_BASE = `https://cdn.jsdelivr.net/npm/@umbraco-cms/backoffice@${BACKOFFICE_VERSION}/dist-cms/packages/core/icon-registry/icons`;

await import(`https://cdn.jsdelivr.net/npm/@umbraco-ui/uui@${UUI_VERSION}/+esm`);

const iconCache = new Map();
function loadIcon(name) {
	if (!iconCache.has(name)) {
		iconCache.set(
			name,
			import(`${ICON_BASE}/${name}.js`).then((m) => m.default).catch(() => null),
		);
	}
	return iconCache.get(name);
}

async function swapIcons(root) {
	const icons = root.querySelectorAll('uui-icon[name^="icon-"]');
	await Promise.all(
		[...icons].map(async (el) => {
			const svg = await loadIcon(el.getAttribute('name'));
			if (!svg) return console.warn(`No backoffice icon named ${el.getAttribute('name')}`);
			// A uui-icon that already failed a name lookup stays on its fallback, so swap in a
			// fresh one carrying the same attributes (slot, class, style) and the real SVG.
			const fresh = document.createElement('uui-icon');
			for (const { name, value } of el.attributes) if (name !== 'name') fresh.setAttribute(name, value);
			fresh.svg = svg;
			el.replaceWith(fresh);
		}),
	);
}

await swapIcons(document);
// Let open-on-load elements (toasts, popovers) finish animating in before a screenshot.
await new Promise((resolve) => setTimeout(resolve, 1000));
document.documentElement.dataset.mockupReady = 'true';
