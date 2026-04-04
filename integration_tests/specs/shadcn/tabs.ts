import React from 'react';
import { TabsFixture } from './shadcn-component';
import { clickButtonByText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn tabs integration', () => {
  it('shadcn_tabs', async () => {
    await runShadcnCase(
      React.createElement(TabsFixture),
      ['shadcn_tabs', 'Account settings panel'],
      async (container, flush) => {
        await snapshot();
        await clickButtonByText(container, flush, 'Security');
        expect(container.textContent).toContain('Security settings panel');
        expect(container.textContent).not.toContain('Account settings panel');
        await snapshot();
      },
    );
  });
});
