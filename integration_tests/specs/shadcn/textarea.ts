import React from 'react';
import { TextareaFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn textarea integration', () => {
  it('shadcn_textarea', async () => {
    await runShadcnCase(
      React.createElement(TextareaFixture),
      ['shadcn_textarea'],
      async (container) => {
        expect(container.querySelector('textarea[placeholder="Describe the rollout status"]')).not.toBeNull();
        await snapshot();
      },
    );
  });
});
