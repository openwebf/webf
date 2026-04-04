import React from 'react';
import { DialogFixture } from './shadcn-component';
import { clickButtonByText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn dialog integration', () => {
  it('shadcn_dialog', async () => {
    await runShadcnCase(
      React.createElement(DialogFixture),
      ['shadcn_dialog', 'Open dialog'],
      async (container, flush) => {
        await clickButtonByText(container, flush, 'Open dialog');
        await snapshot();
        expect(container.textContent).toContain('Migration profile');
        expect(container.textContent).toContain('Save changes');
        await clickButtonByText(container, flush, 'Save changes');
        expect(container.textContent).not.toContain('Migration profile');
        await snapshot();
      },
    );
  });
});
