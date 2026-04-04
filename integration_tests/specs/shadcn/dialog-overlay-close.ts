import React from 'react';
import { DialogFixture } from './shadcn-component';
import { clickButtonByText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn dialog overlay integration', () => {
  it('shadcn_dialog_overlay_close', async () => {
    await runShadcnCase(
      React.createElement(DialogFixture),
      ['shadcn_dialog', 'Open dialog'],
      async (container, flush) => {
        await clickButtonByText(container, flush, 'Open dialog');
        expect(container.textContent).toContain('Migration profile');
        await snapshot();
        
        const overlay = container.querySelector('.fixed.inset-0') as HTMLElement | null;
        expect(overlay).not.toBeNull();
        overlay!.click();
        await flush(2);

        expect(container.textContent).not.toContain('Migration profile');
        await snapshot();
      },
    );
  });
});
