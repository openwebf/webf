/** @jsxImportSource react */
import React from 'react';
import { createPortal } from 'react-dom';
import styles from '../_shared/globals.css';
import { cn } from '../_shared/cn';
import { withShadcnSpec } from '../_shared/test-utils';

function FloatingLayerMeasurementProbe() {
  const anchorRef = React.useRef<HTMLButtonElement | null>(null);
  const [wide, setWide] = React.useState(false);
  const [observerCount, setObserverCount] = React.useState(0);
  const [measurement, setMeasurement] = React.useState({ top: 0, left: 0, width: 0 });

  React.useEffect(() => {
    const anchor = anchorRef.current;
    if (!anchor) {
      return;
    }

    const updateMeasurement = () => {
      const rect = anchor.getBoundingClientRect();
      setMeasurement({
        top: Math.round(rect.bottom),
        left: Math.round(rect.left),
        width: Math.round(rect.width),
      });
    };

    updateMeasurement();

    if (typeof ResizeObserver !== 'function') {
      return;
    }

    const observer = new ResizeObserver(() => {
      setObserverCount((value) => value + 1);
      updateMeasurement();
    });

    observer.observe(anchor);
    return () => observer.disconnect();
  }, [wide]);

  return (
    <div className="shadcn-spec-page">
      <section className="shadcn-probe-card">
        <div>
          <h1 className="shadcn-probe-title">Floating Layer Measurement Probe</h1>
          <p className="shadcn-probe-copy">
            Verifies `getBoundingClientRect()` and `ResizeObserver` can drive floating-layer width and position updates.
          </p>
        </div>
        <div className="shadcn-probe-inline">
          <button
            className={cn('shadcn-anchor', wide && 'shadcn-anchor-wide')}
            data-testid="anchor"
            onClick={() => setWide((value) => !value)}
            ref={anchorRef}
            type="button"
          >
            Toggle Anchor Width
          </button>
          <span className="shadcn-probe-chip" data-testid="observer-count">
            Observer count: {observerCount}
          </span>
        </div>
        <p className="shadcn-probe-readout" data-testid="measurement-readout">
          {measurement.left}:{measurement.top}:{measurement.width}
        </p>
      </section>
      {createPortal(
        <div
          className="shadcn-floating-layer"
          data-testid="floating-layer"
          style={{
            left: `${measurement.left}px`,
            position: 'fixed',
            top: `${measurement.top}px`,
            width: `${measurement.width}px`,
          }}
        >
          Floating layer width follows the anchor.
        </div>,
        document.body,
      )}
    </div>
  );
}

describe('shadcn probes: floating layer measurement', () => {
  it('keeps floating-layer measurements in sync with anchor size changes', async () => {
    styles.use();

    try {
      await withShadcnSpec(
        <FloatingLayerMeasurementProbe />,
        async ({ clickCenter, flush, waitForFrames, waitForSelector }) => {
          const anchor = await waitForSelector<HTMLButtonElement>('[data-testid="anchor"]');
          const readout = await waitForSelector<HTMLParagraphElement>('[data-testid="measurement-readout"]');
          const observerCount = await waitForSelector<HTMLSpanElement>('[data-testid="observer-count"]');

          await flush(4);

          const floatingLayer = document.body.querySelector('[data-testid="floating-layer"]') as HTMLDivElement | null;
          expect(floatingLayer).not.toBeNull();

          const initialAnchorRect = anchor.getBoundingClientRect();
          expect(parseInt(floatingLayer!.style.width, 10)).toBe(Math.round(initialAnchorRect.width));
          expect(readout.textContent).toContain(`${Math.round(initialAnchorRect.width)}`);

          await clickCenter(anchor);
          await waitForFrames(4);

          const updatedAnchorRect = anchor.getBoundingClientRect();
          expect(Math.round(updatedAnchorRect.width)).toBeGreaterThan(Math.round(initialAnchorRect.width));
          expect(parseInt(floatingLayer!.style.width, 10)).toBe(Math.round(updatedAnchorRect.width));
          expect(parseInt(observerCount.textContent!.replace(/\D+/g, ''), 10)).toBeGreaterThan(0);

          await snapshot();
        },
        { framesToWait: 2, width: 320, minHeight: 240 },
      );
    } finally {
      styles.unuse();
    }
  });
});
