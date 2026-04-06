import React from 'react';
import { CalendarFixture } from './shared/shadcn-component';
import { findButtonContainingText, runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn calendar navigation integration', () => {
  it('shadcn_calendar_navigation', async () => {
    await runShadcnCase(
      React.createElement(CalendarFixture),
      ['shadcn_calendar', 'April 2024'],
      async (container, flush) => {
        await waitForFrame();
        await snapshot(1);
        const nextButton = findButtonContainingText(container, '›');
        expect(nextButton).toBeDefined();
        nextButton!.click();
        await waitForFrame();

        expect(container.textContent).toContain('May 2024');
        await snapshot();
      },
    );
  });
});
