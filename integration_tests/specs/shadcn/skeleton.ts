import React from 'react';
import { SkeletonFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn skeleton integration', () => {
  it('shadcn_skeleton', async () => {
    await runShadcnCase(
      React.createElement(SkeletonFixture),
      ['shadcn_skeleton', 'Loading card preview'],
      async (container) => {
        expect(container.querySelector('[data-testid="skeleton-avatar"]')).not.toBeNull();
        expect(container.querySelector('[data-testid="skeleton-block"]')).not.toBeNull();
        await snapshot();
      },
    );
  });
});
