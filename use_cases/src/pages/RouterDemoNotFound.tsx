import React, { useMemo, useState } from 'react';
import { WebFRouter, WebFRouterLink, useLocation } from '../router';
import { joinBase, safeJson } from './RouterDemoUtils';

const basePath = '/routing';

export function RouterDemoNotFound() {
  const location = useLocation();
  const stateJson = useMemo(() => safeJson(location.state), [location.state]);
  const [tryPath, setTryPath] = useState('/routing/does-not-exist');

  return (
    <div className="mx-auto max-w-3xl space-y-4 text-left">
      <div className="flex items-start justify-between gap-3">
        <h1 className="text-2xl font-semibold text-fg-primary">Not Found</h1>
        <div className="rounded-lg border border-line px-3 py-2 bg-surface">
          <div className="text-xs text-fg-secondary">Path</div>
          <div className="font-mono text-xs text-fg">{location.pathname}</div>
        </div>
      </div>

      <div className="rounded-lg border border-line p-4 bg-surface space-y-2">
        <div className="text-sm text-fg-secondary">State</div>
        <pre className="overflow-auto rounded bg-black/30 p-3 text-xs text-fg">{stateJson}</pre>
      </div>

      <div className="rounded-lg border border-line p-4 bg-surface space-y-3">
        <div className="text-sm font-semibold text-fg-primary">Try another missing path</div>
        <div className="flex gap-2">
          <input
            className="flex-1 rounded-md border border-line bg-surface px-3 py-2 text-sm text-fg"
            value={tryPath}
            onChange={(e) => setTryPath(e.target.value)}
          />
          <button
            className="rounded-md bg-blue-500/70 px-4 py-2 text-sm text-white hover:bg-blue-500/80"
            onClick={() => WebFRouter.replace(tryPath, { from: location.pathname, at: Date.now() })}
          >
            Go
          </button>
        </div>
      </div>

      <div className="grid gap-3 sm:grid-cols-2">
        <WebFRouterLink path={joinBase(basePath, '/')}>
          <div className="rounded-lg bg-white/10 px-4 py-2 text-sm text-fg hover:bg-white/15">Home</div>
        </WebFRouterLink>
        <WebFRouterLink path={joinBase(basePath, '/users/1')}>
          <div className="rounded-lg bg-white/10 px-4 py-2 text-sm text-fg hover:bg-white/15">User #1</div>
        </WebFRouterLink>
        <WebFRouterLink path={joinBase(basePath, '/files/docs/getting-started')}>
          <div className="rounded-lg bg-white/10 px-4 py-2 text-sm text-fg hover:bg-white/15">Files</div>
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

