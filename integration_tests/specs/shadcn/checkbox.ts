import React from 'react';
import { CheckboxFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn checkbox integration', () => {
  it('shadcn_checkbox', async () => {
    await runShadcnCase(
      React.createElement(CheckboxFixture),
      ['shadcn_checkbox', 'Enable migration gate', 'Checked: no'],
      async (container, flush) => {
        const checkbox = container.querySelector('[role="checkbox"]') as HTMLButtonElement | null;
        await snapshot();
        expect(checkbox).not.toBeNull();
        checkbox!.click();
        await flush(2);
        expect(container.textContent).toContain('Checked: yes');
        await snapshot();
      },
    );
  });
});
