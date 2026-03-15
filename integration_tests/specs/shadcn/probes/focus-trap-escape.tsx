/** @jsxImportSource react */
import React from 'react';
import { createPortal } from 'react-dom';
import styles from '../_shared/globals.css';
import { pressKey, withShadcnSpec } from '../_shared/test-utils';

function FocusTrapEscapeProbe() {
  const triggerRef = React.useRef<HTMLButtonElement | null>(null);
  const primaryRef = React.useRef<HTMLButtonElement | null>(null);
  const secondaryRef = React.useRef<HTMLButtonElement | null>(null);
  const [open, setOpen] = React.useState(false);
  const [focusLabel, setFocusLabel] = React.useState('Trigger');

  React.useEffect(() => {
    if (!open) {
      return;
    }

    setFocusLabel('Primary');
    primaryRef.current?.focus();
  }, [open]);

  const handleDialogKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
    if (event.key === 'Escape') {
      event.preventDefault();
      setOpen(false);
      setFocusLabel('Trigger');
      requestAnimationFrame(() => triggerRef.current?.focus());
      return;
    }

    if (event.key !== 'Tab') {
      return;
    }

    event.preventDefault();

    if (event.shiftKey) {
      if (document.activeElement === primaryRef.current) {
        setFocusLabel('Secondary');
        secondaryRef.current?.focus();
      } else {
        setFocusLabel('Primary');
        primaryRef.current?.focus();
      }
      return;
    }

    if (document.activeElement === primaryRef.current) {
      setFocusLabel('Secondary');
      secondaryRef.current?.focus();
    } else {
      setFocusLabel('Primary');
      primaryRef.current?.focus();
    }
  };

  return (
    <div className="shadcn-spec-page">
      <section className="shadcn-probe-card">
        <div>
          <h1 className="shadcn-probe-title">Focus Trap Probe</h1>
          <p className="shadcn-probe-copy">
            Verifies focus enters the dialog, loops on `Tab`, and returns to the trigger when `Escape` closes it.
          </p>
        </div>
        <button
          className="shadcn-probe-button"
          data-testid="dialog-trigger"
          onFocus={() => setFocusLabel('Trigger')}
          ref={triggerRef}
          onClick={() => setOpen(true)}
        >
          Open Dialog
        </button>
        <span className="shadcn-probe-chip" data-testid="focus-readout">
          Focus: {focusLabel}
        </span>
      </section>
      {open
        ? createPortal(
            <div className="shadcn-dialog-backdrop">
              <div className="shadcn-dialog-shell" data-testid="dialog" onKeyDown={handleDialogKeyDown} tabIndex={-1}>
                <p className="shadcn-probe-title">Dialog</p>
                <p className="shadcn-probe-copy">Tab should cycle between the two actions.</p>
                <div className="shadcn-dialog-actions">
                  <button
                    className="shadcn-probe-button"
                    data-testid="primary"
                    onFocus={() => setFocusLabel('Primary')}
                    ref={primaryRef}
                  >
                    Primary
                  </button>
                  <button
                    className="shadcn-probe-button-alt"
                    data-testid="secondary"
                    onFocus={() => setFocusLabel('Secondary')}
                    ref={secondaryRef}
                  >
                    Secondary
                  </button>
                </div>
              </div>
            </div>,
            document.body,
          )
        : null}
    </div>
  );
}

describe('shadcn probes: focus trap and escape dismissal', () => {
  // Blocked: dispatched KeyboardEvent instances are not currently driving React keyboard handlers in WebF.
  xit('loops focus with Tab and restores focus to the trigger on Escape', async () => {
    styles.use();

    try {
      await withShadcnSpec(
        <FocusTrapEscapeProbe />,
        async ({ flush, waitForSelector }) => {
          const trigger = await waitForSelector<HTMLButtonElement>('[data-testid="dialog-trigger"]');
          const focusReadout = await waitForSelector<HTMLSpanElement>('[data-testid="focus-readout"]');
          trigger.click();
          await flush(3);

          const dialog = document.body.querySelector('[data-testid="dialog"]') as HTMLDivElement | null;

          expect(dialog).not.toBeNull();
          expect(document.body.querySelector('[data-testid="primary"]')).not.toBeNull();
          expect(document.body.querySelector('[data-testid="secondary"]')).not.toBeNull();
          expect(focusReadout.textContent).toContain('Primary');

          await pressKey(dialog!, 'Tab');
          expect(focusReadout.textContent).toContain('Secondary');

          await pressKey(dialog!, 'Tab', { shiftKey: true });
          expect(focusReadout.textContent).toContain('Primary');

          await pressKey(dialog!, 'Escape');
          await flush(3);

          expect(document.body.querySelector('[data-testid="dialog"]')).toBeNull();
          expect(focusReadout.textContent).toContain('Trigger');

          await snapshot();
        },
        { framesToWait: 2, width: 320, minHeight: 220 },
      );
    } finally {
      styles.unuse();
    }
  });
});
