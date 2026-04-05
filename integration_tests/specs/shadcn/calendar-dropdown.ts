import React from 'react';
import { CalendarDropdownFixture } from './shadcn-component';
import { findButtonContainingText, runShadcnCase, waitForText } from './shadcn-test-utils';

describe('Shadcn calendar dropdown integration', () => {
  it('shadcn_calendar_dropdown', async () => {
    await runShadcnCase(
      React.createElement(CalendarDropdownFixture),
      ['shadcn_calendar_dropdown', 'Selected: 2026-01-31', 'Jan', '2026'],
      async (container, flush) => {
        const calendar = container.querySelector('.rounded-lg.border.border-zinc-200.bg-white') as HTMLElement | null;
        expect(calendar).toBeTruthy();
        expect(calendar!.getBoundingClientRect().width).toBeGreaterThan(340);

        const selectTriggers = Array.from(
          calendar!.querySelectorAll('[data-slot="select-trigger"]'),
        ) as HTMLButtonElement[];
        expect(selectTriggers.length).toBe(2);

        const monthTrigger = selectTriggers[0];
        const yearTrigger = selectTriggers[1];

        monthTrigger.click();
        await flush(2);
        await waitForText(container, 'Feb', flush);
        await waitForText(container, 'Dec', flush);
        await snapshot();

        const marchItem = findButtonContainingText(container, 'Mar');
        expect(marchItem).toBeDefined();
        marchItem!.click();
        await flush(2);
        expect(monthTrigger.textContent).toContain('Mar');
        await snapshot();

        yearTrigger.click();
        await flush(2);
        await waitForText(container, '2028', flush);
        await snapshot();

        const year2028Item = findButtonContainingText(container, '2028');
        expect(year2028Item).toBeDefined();
        year2028Item!.click();
        await flush(2);
        expect(yearTrigger.textContent).toContain('2028');
        await snapshot();
      },
    );
  }, 15000);
});
