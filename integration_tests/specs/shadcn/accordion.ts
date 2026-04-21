import React from 'react';
import { AccordionFixture } from './shared/shadcn-component';
import { clickButtonContainingText, runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn accordion integration', () => {
  it('shadcn_accordion', async () => {
    await runShadcnCase(
      React.createElement(AccordionFixture),
      ['shadcn_accordion', 'What shipped?', 'Button, input, and card are already aligned.'],
      async (container, flush) => {
        await snapshot();
        await clickButtonContainingText(container, flush, 'What changed?');
        expect(container.textContent).toContain('Overlay and selection primitives now use local official components.');
        await snapshot();
      },
    );
  });
});
