import React from 'react';
import { SeparatorFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn separator integration', () => {
  it('shadcn_separator', async () => {
    await runShadcnCase(
      React.createElement(SeparatorFixture),
      ['shadcn_separator', 'Account', 'Settings'],
      async (container) => {
        expect(container.querySelector('[role="separator"]')).not.toBeNull();
        await snapshot();
      },
    );
  });
});
