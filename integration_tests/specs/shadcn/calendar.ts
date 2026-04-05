import React from 'react';
import { CalendarFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn calendar integration', () => {
  it('shadcn_calendar', async () => {
    await runShadcnCase(
      React.createElement(CalendarFixture),
      ['shadcn_calendar', 'April 2024', 'Selected: 2024-04-14'],
      async (container, flush) => {
        const dayButton = Array.from(container.querySelectorAll('button')).find(
          (node) => node.textContent?.trim() === '16',
        ) as HTMLButtonElement | undefined;
        expect(dayButton).toBeDefined();
        dayButton!.click();
        await flush(2);
        expect(container.textContent).toContain('Selected: 2024-04-16');
        await snapshot();
      },
    );
  });
});
