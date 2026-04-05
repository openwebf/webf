import React from 'react';
import { SelectFixture } from './shadcn-component';
import { findButtonContainingText, runShadcnCase } from './shadcn-test-utils';

describe('Shadcn select integration', () => {
  it('shadcn_select', async () => {
    await runShadcnCase(
      React.createElement(SelectFixture),
      ['shadcn_select', 'Selected: starter'],
      async (container, flush) => {
        const trigger = findButtonContainingText(container, '⌄');
        expect(trigger).toBeDefined();
        trigger!.click();
        await flush(2);
        await snapshot();
        expect(container.textContent).toContain('Enterprise');

        const content = container.querySelector('[data-slot="select-content"]') as HTMLElement | null;
        const separator = container.querySelector('[data-slot="select-separator"] > div') as HTMLElement | null;
        const selectedItem = container.querySelector(
          '[data-slot="select-item"][data-state="checked"]',
        ) as HTMLElement | null;

        expect(content).toBeTruthy();
        expect(separator).toBeTruthy();
        expect(selectedItem).toBeTruthy();

        const contentWidth = content!.getBoundingClientRect().width;
        const separatorWidth = separator!.getBoundingClientRect().width;
        const selectedItemWidth = selectedItem!.getBoundingClientRect().width;

        expect(contentWidth).toBeGreaterThan(0);
        expect(separatorWidth).toBeGreaterThan(contentWidth * 0.85);
        expect(selectedItemWidth).toBeGreaterThan(contentWidth * 0.75);

        const proItem = findButtonContainingText(container, 'Pro');
        expect(proItem).toBeDefined();
        proItem!.click();
        await flush(2);

        expect(container.textContent).toContain('Selected: pro');
        expect(container.textContent).not.toContain('Enterprise');
        await snapshot();

        trigger!.click();
        await flush(2);
        await snapshot();
      },
    );
  });
});
