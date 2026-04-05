import React from 'react';
import { RadioGroupFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn radio group integration', () => {
  it('shadcn_radio_group', async () => {
    await runShadcnCase(
      React.createElement(RadioGroupFixture),
      ['shadcn_radio_group', 'Starter', 'Selected tier: starter'],
      async (container, flush) => {
        const radios = Array.from(container.querySelectorAll('[role="radio"]')) as HTMLButtonElement[];
        expect(radios.length).toBe(2);
        await snapshot();
        radios[1].click();
        await flush(2);
        expect(container.textContent).toContain('Selected tier: pro');
        await snapshot();
      },
    );
  });
});
