import React from 'react';
import { ProgressFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn progress integration', () => {
  it('shadcn_progress', async () => {
    await runShadcnCase(
      React.createElement(ProgressFixture),
      ['shadcn_progress', 'Migration progress', '66% complete'],
      async (container) => {
        expect(container.querySelector('[role="progressbar"]')?.getAttribute('aria-valuenow')).toBe('66');
        await snapshot();
      },
    );
  });
});
