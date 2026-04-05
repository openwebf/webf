import React from 'react';
import { CalendarDropdownFixture } from './shadcn-component';
import { findButtonContainingText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn calendar dropdown integration', () => {
  it('shadcn_calendar_dropdown', async () => {
    await runShadcnCase(
      React.createElement(CalendarDropdownFixture),
      ['shadcn_calendar_dropdown', 'Selected: 2026-01-31', 'Jan', '2026'],
      async (container, flush) => {
        const calendar = container.querySelector('.rounded-lg.border.border-zinc-200.bg-white') as HTMLElement | null;
        expect(calendar).toBeTruthy();
        expect(calendar!.getBoundingClientRect().width).toBeGreaterThan(340);

        const nextButton = findButtonContainingText(container, '›');
        expect(nextButton).toBeDefined();
        nextButton!.click();
        await flush(2);

        expect(container.textContent).toContain('Feb');
        await snapshot();
      },
    );
  });
});
