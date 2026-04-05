import React from 'react';
import { DropdownMenuFixture } from './shared/shadcn-component';
import { clickButtonByText, runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn dropdown menu toggle integration', () => {
  it('shadcn_dropdown_menu_toggle', async () => {
    await runShadcnCase(
      React.createElement(DropdownMenuFixture),
      ['shadcn_dropdown_menu', 'Open menu'],
      async (container, flush) => {
        await clickButtonByText(container, flush, 'Open menu');
        expect(container.textContent).toContain('Profile');
        await snapshot();
        await clickButtonByText(container, flush, 'Open menu');
        expect(container.textContent).not.toContain('Profile');
        await snapshot();
      },
    );
  });
});
