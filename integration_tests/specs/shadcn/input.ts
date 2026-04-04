import React from 'react';
import { InputFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn input integration', () => {
  it('shadcn_input', async () => {
    await runShadcnCase(
      React.createElement(InputFixture),
      ['shadcn_input', 'Repository', 'Use the project slug for generated examples.'],
      async (container) => {
        expect(container.querySelector('input[placeholder="webf-enterprise-canvas"]')).not.toBeNull();
        await snapshot();
      },
    );
  });
});
