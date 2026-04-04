import React from 'react';
import { SwitchFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn switch integration', () => {
  it('shadcn_switch', async () => {
    await runShadcnCase(
      React.createElement(SwitchFixture),
      ['shadcn_switch', 'Enable nightly verification', 'Enabled: yes'],
      async (container, flush) => {
        const toggle = container.querySelector('[role="switch"]') as HTMLButtonElement | null;
        expect(toggle).not.toBeNull();
        const thumb = toggle!.querySelector('span') as HTMLElement | null;
        expect(thumb).not.toBeNull();

        const checkedThumbLeft = thumb!.getBoundingClientRect().left;
        await snapshot();
        toggle!.click();
        await flush(2);
        expect(container.textContent).toContain('Enabled: no');

        const uncheckedThumbLeft = thumb!.getBoundingClientRect().left;
        expect(checkedThumbLeft).toBeGreaterThan(uncheckedThumbLeft);
        await snapshot();
      },
    );
  });
});
