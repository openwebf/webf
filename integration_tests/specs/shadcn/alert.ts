import React from 'react';
import { AlertFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn alert integration', () => {
  it('shadcn_alert', async () => {
    await runShadcnCase(
      React.createElement(AlertFixture),
      ['shadcn_alert', 'Heads up', 'Review'],
      async (container) => {
        expect(container.querySelector('[role="alert"]')).not.toBeNull();
        await snapshot();
      },
    );
  });
});
