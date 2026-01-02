import React, { useMemo, useState } from 'react';
import { WebFRouter, WebFRouterLink, useLocation, useParams } from '../router';
import { joinBase, safeJson } from './RouterDemoUtils';

const basePath = '/routing';

function inferFilesPath(pathname: string): string {
  const prefix = joinBase(basePath, '/files/');
  if (!pathname.startsWith(prefix)) return '';
  return pathname.slice(prefix.length);
}

export function RouterDemoFiles() {
  const params = useParams();
  const location = useLocation();

  const splat = (params as any)?.['*'] as string | undefined;
  const filePath = splat ?? inferFilesPath(location.pathname);

  const [input, setInput] = useState(filePath || 'docs/getting-started');
  const stateJson = useMemo(() => safeJson(location.state), [location.state]);

  const normalized = useMemo(() => input.replace(/^\/+/, ''), [input]);

  return (
    <div className="mx-auto max-w-3xl space-y-4 text-left">
      <div className="flex items-start justify-between gap-3">
        <h1 className="text-2xl font-semibold text-fg-primary">Files</h1>
        <div className="rounded-lg border border-line px-3 py-2 bg-surface">
          <div className="text-xs text-fg-secondary">Path</div>
          <div className="font-mono text-xs text-fg">{location.pathname}</div>
        </div>
      </div>

      <div className="rounded-lg border border-line p-4 bg-surface space-y-2">
        <div className="text-sm text-fg-secondary">Wildcard</div>
        <div className="font-mono text-sm text-fg">* = {filePath || '(empty)'}</div>
      </div>

      <div className="rounded-lg border border-line p-4 bg-surface space-y-3">
        <div className="text-sm font-semibold text-fg-primary">Open a file path</div>
        <div className="flex gap-2">
          <input
            className="flex-1 rounded-md border border-line bg-surface px-3 py-2 text-sm text-fg"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="docs/getting-started"
          />
          <button
            className="rounded-md bg-blue-500/70 px-4 py-2 text-sm text-white hover:bg-blue-500/80"
            onClick={() =>
              WebFRouter.replace(joinBase(basePath, `/files/${normalized}`), { from: location.pathname, at: Date.now() })
            }
          >
            Go
          </button>
        </div>
        <div className="grid gap-2 sm:grid-cols-2">
          <button
            className="rounded-md bg-white/10 px-3 py-2 text-sm text-fg hover:bg-white/15 text-left"
            onClick={() => WebFRouter.replace(joinBase(basePath, '/files/docs'), { from: location.pathname, at: Date.now() })}
          >
            /files/docs
          </button>
          <button
            className="rounded-md bg-white/10 px-3 py-2 text-sm text-fg hover:bg-white/15 text-left"
            onClick={() =>
              WebFRouter.replace(joinBase(basePath, '/files/docs/getting-started'), { from: location.pathname, at: Date.now() })
            }
          >
            /files/docs/getting-started
          </button>
          <button
            className="rounded-md bg-white/10 px-3 py-2 text-sm text-fg hover:bg-white/15 text-left"
            onClick={() =>
              WebFRouter.replace(joinBase(basePath, '/files/assets/icons/app.png'), { from: location.pathname, at: Date.now() })
            }
          >
            /files/assets/icons/app.png
          </button>
          <button
            className="rounded-md bg-white/10 px-3 py-2 text-sm text-fg hover:bg-white/15 text-left"
            onClick={() => WebFRouter.replace(joinBase(basePath, '/files/'), { from: location.pathname, at: Date.now() })}
          >
            /files/
          </button>
        </div>
      </div>

      <div className="rounded-lg border border-line p-4 bg-surface space-y-2">
        <div className="text-sm text-fg-secondary">State</div>
        <pre className="overflow-auto rounded bg-black/30 p-3 text-xs text-fg">{stateJson}</pre>
      </div>

      <div className="grid gap-3 sm:grid-cols-2">
        <WebFRouterLink path={joinBase(basePath, '/')}>
          <div className="rounded-lg bg-white/10 px-4 py-2 text-sm text-fg hover:bg-white/15">Home</div>
        </WebFRouterLink>
        <button
          className="rounded-lg bg-white/10 px-4 py-2 text-sm text-fg hover:bg-white/15"
          onClick={() => WebFRouter.maybePop?.() || WebFRouter.back()}
        >
          Back
        </button>
      </div>
    </div>
  );
}

