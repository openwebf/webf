import React from 'react';
import { CollapsibleFixture } from './shadcn-component';
import { clickButtonByText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn collapsible integration', () => {
  it('shadcn_collapsible', async () => {
    await runShadcnCase(
      React.createElement(CollapsibleFixture),
      ['shadcn_collapsible', 'Toggle details'],
      async (container, flush) => {
        await snapshot();
        await clickButtonByText(container, flush, 'Toggle details');
        expect(container.textContent).toContain('Hidden rollout details now use the official local collapsible primitive.');
        await snapshot();
      },
    );
  });
});
