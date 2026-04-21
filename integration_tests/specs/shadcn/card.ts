import React from 'react';
import { CardFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn card integration', () => {
  it('shadcn_card', async () => {
    await runShadcnCase(
      React.createElement(CardFixture),
      ['shadcn_card', 'Official card sample', 'Migration status: ready for verification.'],
      async () => {
        await snapshot();
      },
    );
  });
});
