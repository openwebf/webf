import React from 'react';
import { DropdownMenuFixture } from './shadcn-component';
import { clickButtonByText, clickButtonContainingText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn dropdown menu integration', () => {
  it('shadcn_dropdown_menu', async () => {
    await runShadcnCase(
      React.createElement(DropdownMenuFixture),
      ['shadcn_dropdown_menu', 'Open menu'],
      async (container, flush) => {
        await clickButtonByText(container, flush, 'Open menu');
        expect(container.textContent).toContain('Billing');
        expect(container.textContent).toContain('⇧⌘P');
        expect(container.textContent).toContain('Log out');

        const menuContent = Array.from(container.querySelectorAll('div')).find((node) => {
          const element = node as HTMLElement;
          const text = element.textContent || '';
          return (
            element.className.includes('absolute') &&
            text.includes('My Account') &&
            text.includes('Log out')
          );
        }) as HTMLElement | undefined;

        expect(menuContent).toBeDefined();
        expect(menuContent!.getBoundingClientRect().width).toBeGreaterThanOrEqual(240);

        const separators = Array.from(menuContent!.querySelectorAll('*')).filter((node) => {
          const style = getComputedStyle(node);
          return style.height === '1px' && style.backgroundColor === 'rgb(212, 212, 216)';
        });

        expect(separators.length).toBe(2);
        await snapshot();
        await clickButtonContainingText(container, flush, 'Team');
        expect(container.textContent).not.toContain('Billing');
        await snapshot();
      },
    );
  });
});
