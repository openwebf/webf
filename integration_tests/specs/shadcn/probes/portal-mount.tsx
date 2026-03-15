/** @jsxImportSource react */
import React from 'react';
import { createPortal } from 'react-dom';
import styles from '../_shared/globals.css';
import { withShadcnSpec } from '../_shared/test-utils';

function PortalMountProbe() {
  const [open, setOpen] = React.useState(false);
  const [count, setCount] = React.useState(0);

  return (
    <div className="shadcn-spec-page">
      <section className="shadcn-probe-card">
        <div>
          <h1 className="shadcn-probe-title">Portal Mount Probe</h1>
          <p className="shadcn-probe-copy">
            Verifies that a React portal can mount directly under `document.body` and still update local state.
          </p>
        </div>
        <div className="shadcn-probe-inline">
          <button className="shadcn-probe-button" data-testid="toggle" onClick={() => setOpen((value) => !value)}>
            Toggle Portal
          </button>
          <span className="shadcn-probe-chip" data-testid="portal-count">
            Count: {count}
          </span>
        </div>
      </section>
      {open
        ? createPortal(
            <div className="shadcn-floating-layer" data-testid="portal-layer">
              <p className="shadcn-probe-copy">This layer should live under document.body.</p>
              <button
                className="shadcn-probe-button-alt"
                data-testid="portal-action"
                onClick={() => setCount((value) => value + 1)}
              >
                Increment From Portal
              </button>
            </div>,
            document.body,
          )
        : null}
    </div>
  );
}

describe('shadcn probes: portal mount', () => {
  it('mounts portal content under document.body and keeps events wired to React state', async () => {
    styles.use();

    try {
      await withShadcnSpec(
        <PortalMountProbe />,
        async ({ container, flush, waitForSelector }) => {
          const toggle = await waitForSelector<HTMLButtonElement>('[data-testid="toggle"]');
          const countLabel = await waitForSelector<HTMLSpanElement>('[data-testid="portal-count"]');

          expect(document.body.querySelector('[data-testid="portal-layer"]')).toBeNull();

          toggle.click();
          await flush(3);

          const portalLayer = document.body.querySelector('[data-testid="portal-layer"]') as HTMLDivElement | null;
          const portalAction = document.body.querySelector('[data-testid="portal-action"]') as HTMLButtonElement | null;

          expect(portalLayer).not.toBeNull();
          expect(portalLayer!.parentElement).toBe(document.body);
          expect(container.contains(portalLayer!)).toBe(false);
          expect(portalAction).not.toBeNull();

          portalAction!.click();
          await flush(3);

          expect(countLabel.textContent).toContain('1');

          await snapshot();
        },
        { framesToWait: 2, width: 320, minHeight: 220 },
      );
    } finally {
      styles.unuse();
    }
  });
});
