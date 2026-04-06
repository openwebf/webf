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
        const button = await clickButtonByText(container, flush, 'Open popover');
        await flush(2);
        expect(container.textContent).toContain('Popover title');
        expect(container.textContent).toContain('Popover body for official shadcn coverage.');
        const content = container.querySelector('[data-slot="popover-content"]') as HTMLDivElement | null;
        expect(content).not.toBeNull();
        expect(getComputedStyle(content!).position).toBe('fixed');
        expect(content!.getBoundingClientRect().top).toBeGreaterThanOrEqual(
          button.getBoundingClientRect().bottom,
        );
        await snapshot();
      },
    );
  });
});
