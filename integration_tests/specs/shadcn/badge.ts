import React from 'react';
import { BadgeFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn badge integration', () => {
  it('shadcn_badge', async () => {
    await runShadcnCase(
      React.createElement(BadgeFixture),
      ['shadcn_badge', 'Default badge', 'Outline badge'],
      async (container) => {
        const badges = Array.from(container.querySelectorAll('div')).filter((node) => {
          const element = node as HTMLElement;
          return (
            element.className.includes('inline-flex') &&
            ['Default badge', 'Secondary badge', 'Destructive badge', 'Outline badge'].includes(
              element.textContent?.trim() || '',
            )
          );
        }) as HTMLElement[];

        expect(badges.length).toBe(4);

        const outlineBadge = badges.find(
          (node) => node.textContent?.trim() === 'Outline badge',
        ) as HTMLElement | undefined;

        expect(outlineBadge).toBeDefined();
        expect(getComputedStyle(outlineBadge!).backgroundColor).toBe('rgb(255, 255, 255)');
        expect(getComputedStyle(outlineBadge!).borderTopColor).toBe('rgb(113, 113, 122)');
        await snapshot();
      },
    );
  });
});
