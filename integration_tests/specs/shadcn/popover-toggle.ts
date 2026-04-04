import React from 'react';
import { PopoverFixture } from './shadcn-component';
import { clickButtonByText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn popover toggle integration', () => {
  it('shadcn_popover_toggle', async () => {
    await runShadcnCase(
      React.createElement(PopoverFixture),
      ['shadcn_popover', 'Open popover'],
      async (container, flush) => {
        await clickButtonByText(container, flush, 'Open popover');
        expect(container.textContent).toContain('Popover title');
        await snapshot();

        await clickButtonByText(container, flush, 'Open popover');
        expect(container.textContent).not.toContain('Popover title');
        await snapshot();
      },
    );
  });
});
