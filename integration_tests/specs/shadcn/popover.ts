import React from 'react';
import { PopoverFixture } from './shared/shadcn-component';
import { clickButtonByText, runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn popover integration', () => {
  it('shadcn_popover', async () => {
    await runShadcnCase(
      React.createElement(PopoverFixture),
      ['shadcn_popover', 'Open popover'],
      async (container, flush) => {
        await snapshot();
        await clickButtonByText(container, flush, 'Open popover');
        expect(container.textContent).toContain('Popover title');
        expect(container.textContent).toContain('Popover body for official shadcn coverage.');
        await snapshot();
      },
    );
  });
});
