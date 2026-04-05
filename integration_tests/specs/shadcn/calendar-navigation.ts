import React from 'react';
import { CalendarFixture } from './shadcn-component';
import { findButtonContainingText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn calendar navigation integration', () => {
  it('shadcn_calendar_navigation', async () => {
    await runShadcnCase(
      React.createElement(CalendarFixture),
      ['shadcn_calendar', 'April 2024'],
      async (container, flush) => {
        const nextButton = findButtonContainingText(container, '›');
        expect(nextButton).toBeDefined();
        nextButton!.click();
        await flush(2);

        expect(container.textContent).toContain('May 2024');
        await snapshot();
      },
    );
  });
});
