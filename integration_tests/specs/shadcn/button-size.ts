import React from 'react';
import styles from './shadcn-componennt.css';
import { Button } from './shadcn-component';

async function waitForText(
  container: HTMLElement,
  expectedText: string,
  flush: (frames?: number) => Promise<void>,
  attempts = 24,
): Promise<void> {
  for (let i = 0; i < attempts; i += 1) {
    if (container.textContent?.includes(expectedText)) {
      return;
    }
    await flush(1);
  }

  throw new Error(`Expected text "${expectedText}" was not rendered.`);
}

function ButtonSizesFixture() {
  return React.createElement(
    'div',
    { className: 'min-h-screen bg-zinc-50 p-6' },
    React.createElement(
      'div',
      {
        className:
          'mx-auto grid max-w-3xl gap-4 rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm',
      },
      React.createElement('h1', { className: 'text-xl font-semibold text-zinc-950' }, 'shadcn_button_sizes'),
      React.createElement(
        'div',
        { className: 'flex flex-wrap items-center gap-2' },
        React.createElement(Button, { size: 'xs' }, 'Extra small'),
        React.createElement(Button, { size: 'sm' }, 'Small'),
        React.createElement(Button, null, 'Default'),
        React.createElement(Button, { size: 'lg' }, 'Large'),
        React.createElement(Button, { size: 'icon', 'aria-label': 'Expand' }, '+'),
      ),
    ),
  );
}

describe('Shadcn button sizes integration', () => {
  it('shadcn_button_sizes', async () => {
    styles.use();

    try {
      await resizeViewport(430, 900);

      await withReactSpec(
        React.createElement(ButtonSizesFixture),
        async ({ container, flush }) => {
          await flush(8);

          await waitForText(container, 'shadcn_button_sizes', flush);
          await waitForText(container, 'Extra small', flush);
          await waitForText(container, 'Large', flush);

          expect(container.querySelectorAll('button').length).toBe(5);
          expect(container.querySelector('button[aria-label="Expand"]')).not.toBeNull();
          await snapshot();
        },
        {
          containerStyle: {
            width: '100%',
          },
          framesToWait: 4,
        },
      );
    } finally {
      styles.unuse();
      await resizeViewport(-1, -1);
    }
  });
});
