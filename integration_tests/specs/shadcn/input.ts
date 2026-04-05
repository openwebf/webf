import React from 'react';
import { InputFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn input integration', () => {
  it('shadcn_input', async () => {
    await runShadcnCase(
      React.createElement(InputFixture),
      ['shadcn_input', 'Repository', 'Use the project slug for generated examples.'],
      async (container) => {
        const input = container.querySelector('input[placeholder="webf-enterprise-canvas"]') as HTMLInputElement | null;
        expect(input).not.toBeNull();
        expect(input!.matches(':focus-visible')).toBe(false);
        await snapshot();
        input!.click();
        await waitForFrame();
        expect(input!.matches(':focus-visible')).toBe(true);
        expect(getComputedStyle(input!).boxShadow).toContain('rgb(212, 212, 216)');
        await snapshot();
      },
    );
  });
});
