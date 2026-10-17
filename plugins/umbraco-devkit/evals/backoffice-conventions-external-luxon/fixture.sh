#!/usr/bin/env bash
set -euo pipefail
c=src/Umbraco.Community.JobBoard/Client
mkdir -p $c/src/runs $c/public
cat > $c/package.json <<'EOF'
{
  "name": "job-board-client",
  "private": true,
  "type": "module",
  "scripts": { "build": "tsc && vite build" },
  "dependencies": { "luxon": "^3.6.0" },
  "devDependencies": {
    "@types/luxon": "^3.6.0",
    "@umbraco-cms/backoffice": "^17.0.0",
    "typescript": "^5.9.0",
    "vite": "^7.0.0"
  }
}
EOF
cat > $c/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';

export default defineConfig({
	build: {
		lib: { entry: 'src/index.ts', formats: ['es'], fileName: 'job-board' },
		outDir: '../wwwroot/App_Plugins/JobBoard',
		emptyOutDir: true,
		rollupOptions: { external: [/^@umbraco/] },
	},
});
EOF
cat > $c/src/runs/types.ts <<'EOF'
export interface JobRun {
	id: string;
	jobName: string;
	/** ISO 8601, UTC. */
	startedUtc: string;
	/** ISO 8601, UTC; missing while the run is in progress. */
	finishedUtc?: string;
	status: 'running' | 'succeeded' | 'failed';
}
EOF
cat > $c/src/runs/job-runs-table.element.ts <<'EOF'
import { css, customElement, html, property } from '@umbraco-cms/backoffice/external/lit';
import { UmbLitElement } from '@umbraco-cms/backoffice/lit-element';
import type { JobRun } from './types.js';

@customElement('job-board-runs-table')
export class JobRunsTableElement extends UmbLitElement {
	@property({ attribute: false }) runs: JobRun[] = [];

	override render() {
		return html`<uui-table>
			<uui-table-head>
				<uui-table-head-cell>Job</uui-table-head-cell>
				<uui-table-head-cell>Started</uui-table-head-cell>
				<uui-table-head-cell>Duration</uui-table-head-cell>
				<uui-table-head-cell>Status</uui-table-head-cell>
			</uui-table-head>
			${this.runs.map(
				(run) => html`<uui-table-row>
					<uui-table-cell>${run.jobName}</uui-table-cell>
					<uui-table-cell>${run.startedUtc}</uui-table-cell>
					<uui-table-cell>${run.finishedUtc ?? ''}</uui-table-cell>
					<uui-table-cell>${run.status}</uui-table-cell>
				</uui-table-row>`,
			)}
		</uui-table>`;
	}

	static override styles = css`
		:host {
			display: block;
		}
	`;
}

declare global {
	interface HTMLElementTagNameMap {
		'job-board-runs-table': JobRunsTableElement;
	}
}
EOF
cat > $c/src/index.ts <<'EOF'
export * from './runs/job-runs-table.element.js';
EOF
