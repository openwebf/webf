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

function ButtonVariantsFixture() {
  return React.createElement(
    'div',
    { className: 'min-h-screen bg-zinc-50 p-6' },
    React.createElement(
      'div',
      {
        className:
          'mx-auto grid max-w-3xl gap-4 rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm',
      },
      React.createElement('h1', { className: 'text-xl font-semibold text-zinc-950' }, 'shadcn_button_variants'),
      React.createElement(
        'div',
        { className: 'flex flex-wrap gap-2' },
        React.createElement(Button, null, 'Primary action'),
        React.createElement(Button, { variant: 'secondary' }, 'Secondary action'),
        React.createElement(Button, { variant: 'outline' }, 'Outline action'),
        React.createElement(Button, { variant: 'ghost' }, 'Ghost action'),
        React.createElement(Button, { variant: 'destructive' }, 'Delete action'),
      ),
    ),
  );
}

describe('Shadcn button variants integration', () => {
  it('shadcn_button_variants', async () => {
    styles.use();

    try {
      await resizeViewport(430, 900);

      await withReactSpec(
        React.createElement(ButtonVariantsFixture),
        async ({ container, flush }) => {
          await flush(8);

          await waitForText(container, 'shadcn_button_variants', flush);
          await waitForText(container, 'Primary action', flush);
          await waitForText(container, 'Delete action', flush);

          expect(container.querySelectorAll('button').length).toBe(5);
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
