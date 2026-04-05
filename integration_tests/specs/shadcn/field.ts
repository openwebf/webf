import React from 'react';
import { FieldFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn field integration', () => {
  it('shadcn_field', async () => {
    await runShadcnCase(
      React.createElement(FieldFixture),
      ['shadcn_field', 'Registry URL', 'Use the official registry as the default source.'],
      async () => {
        await snapshot();
      },
    );
  });
});
