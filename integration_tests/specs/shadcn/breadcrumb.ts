import React from 'react';
import { BreadcrumbFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn breadcrumb integration', () => {
  it('shadcn_breadcrumb', async () => {
    await runShadcnCase(
      React.createElement(BreadcrumbFixture),
      ['shadcn_breadcrumb', 'Projects', 'Official shadcn rollout'],
      async (container) => {
        expect(container.querySelector('[aria-label="breadcrumb"]')).not.toBeNull();
        const list = container.querySelector('[aria-label="breadcrumb"] ol') as HTMLOListElement | null;
        expect(list).toBeTruthy();
        expect(list!.style.listStyleType).toBe('none');
        await snapshot();
      },
    );
  });
});
