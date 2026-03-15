/** @jsxImportSource react */
import React from 'react';
import styles from '../_shared/globals.css';
import { pressKey, withShadcnSpec } from '../_shared/test-utils';

const ITEMS = ['Account', 'Projects', 'Billing'];

function RovingFocusProbe() {
  const refs = React.useRef<Array<HTMLButtonElement | null>>([]);
  const [focusIndex, setFocusIndex] = React.useState(0);
  const [selectedIndex, setSelectedIndex] = React.useState(0);

  React.useEffect(() => {
    refs.current[focusIndex]?.focus();
  }, [focusIndex]);

  const moveFocus = (nextIndex: number) => {
    setFocusIndex(nextIndex);
  };

  const handleKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>, index: number) => {
    if (event.key === 'ArrowRight' || event.key === 'ArrowDown') {
      event.preventDefault();
      moveFocus((index + 1) % ITEMS.length);
      return;
    }

    if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') {
      event.preventDefault();
      moveFocus((index - 1 + ITEMS.length) % ITEMS.length);
      return;
    }

    if (event.key === 'Home') {
      event.preventDefault();
      moveFocus(0);
      return;
    }

    if (event.key === 'End') {
      event.preventDefault();
      moveFocus(ITEMS.length - 1);
      return;
    }

    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      setSelectedIndex(index);
    }
  };

  return (
    <div className="shadcn-spec-page">
      <section className="shadcn-probe-card">
        <div>
          <h1 className="shadcn-probe-title">Roving Focus Probe</h1>
          <p className="shadcn-probe-copy">
            Verifies arrow-key focus movement and explicit selection behavior for tab-like composite widgets.
          </p>
        </div>
        <div aria-label="Account sections" className="shadcn-tablist" role="tablist">
          {ITEMS.map((item, index) => (
            <button
              aria-selected={selectedIndex === index}
              className="shadcn-tab"
              data-focus={focusIndex === index}
              data-selected={selectedIndex === index}
              data-testid={`tab-${index}`}
              key={item}
              onClick={() => {
                setFocusIndex(index);
                setSelectedIndex(index);
              }}
              onKeyDown={(event) => handleKeyDown(event, index)}
              ref={(node) => {
                refs.current[index] = node;
              }}
              role="tab"
              tabIndex={focusIndex === index ? 0 : -1}
              type="button"
            >
              {item}
            </button>
          ))}
        </div>
        <p className="shadcn-probe-chip" data-testid="focus-readout">
          Focus: {ITEMS[focusIndex]}
        </p>
        <p className="shadcn-probe-chip" data-testid="selected-readout">
          Selected: {ITEMS[selectedIndex]}
        </p>
      </section>
    </div>
  );
}

describe('shadcn probes: roving focus', () => {
  // Blocked: dispatched KeyboardEvent instances are not currently driving React keyboard handlers in WebF.
  xit('moves focus with arrows/Home/End and updates selection on Enter', async () => {
    styles.use();

    try {
      await withShadcnSpec(
        <RovingFocusProbe />,
        async ({ flush, waitForSelector }) => {
          const first = await waitForSelector<HTMLButtonElement>('[data-testid="tab-0"]');
          const second = await waitForSelector<HTMLButtonElement>('[data-testid="tab-1"]');
          const third = await waitForSelector<HTMLButtonElement>('[data-testid="tab-2"]');
          const focusReadout = await waitForSelector<HTMLParagraphElement>('[data-testid="focus-readout"]');
          const readout = await waitForSelector<HTMLParagraphElement>('[data-testid="selected-readout"]');

          first.focus();
          await flush(2);
          expect(focusReadout.textContent).toContain('Account');

          await pressKey(first, 'ArrowRight');
          expect(focusReadout.textContent).toContain('Projects');
          expect(second.tabIndex).toBe(0);
          expect(first.tabIndex).toBe(-1);
          expect(second.getAttribute('data-focus')).toBe('true');

          await pressKey(second, 'End');
          expect(focusReadout.textContent).toContain('Billing');
          expect(third.getAttribute('data-focus')).toBe('true');

          await pressKey(third, 'Home');
          expect(focusReadout.textContent).toContain('Account');
          expect(first.getAttribute('data-focus')).toBe('true');

          await pressKey(first, 'ArrowRight');
          expect(focusReadout.textContent).toContain('Projects');

          await pressKey(second, 'Enter');
          await flush(2);

          expect(readout.textContent).toContain('Projects');
          expect(second.getAttribute('aria-selected')).toBe('true');

          await snapshot();
        },
        { framesToWait: 2, width: 320, minHeight: 220 },
      );
    } finally {
      styles.unuse();
    }
  });
});
