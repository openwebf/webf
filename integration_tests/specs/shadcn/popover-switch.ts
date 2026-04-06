import React from 'react';
import { PopoverSwitchFixture } from '../../../use_cases/src/components/ui/popover';
import { findButtonByText, runShadcnCase } from './shared/shadcn-test-utils';

async function pressButton(container: HTMLElement, flush: (frames?: number) => Promise<void>, text: string) {
  await flush(1);
  const button = findButtonByText(container, text);
  if (!button) {
    throw new Error(`Unable to find button with text "${text}".`);
  }

  const rect = button.getBoundingClientRect();
  await simulateClick(rect.left + rect.width / 2, rect.top + rect.height / 2);
  await flush(2);
}

describe('Shadcn popover switch integration', () => {
  it('shadcn_popover_switch', async () => {
    await runShadcnCase(
      React.createElement(PopoverSwitchFixture),
      ['shadcn_popover_switch', 'Left', 'Center'],
      async (container, flush) => {
        await pressButton(container, flush, 'Left');
        expect(container.textContent).toContain('Left title');
        expect(container.textContent).not.toContain('Center title');
        await snapshot();

        await pressButton(container, flush, 'Center');
        expect(container.textContent).not.toContain('Left title');
        expect(container.textContent).toContain('Center title');
        await snapshot();
      },
    );
  });
});
