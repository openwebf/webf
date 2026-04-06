import React from 'react';
import { PopoverLayerFixture } from './shared/shadcn-component';
import { clickButtonByText, runShadcnCase } from './shared/shadcn-test-utils';

describe('Shadcn popover layering integration', () => {
  it('shadcn_popover_layer', async () => {
    await runShadcnCase(
      React.createElement(PopoverLayerFixture),
      ['shadcn_popover_layer', 'Open layered popover'],
      async (container, flush) => {
        await clickButtonByText(container, flush, 'Open layered popover');
        await flush(2);
        const content = container.querySelector('[data-slot="popover-content"]') as HTMLDivElement | null;
        const underlay = container.querySelector('[data-slot="popover-underlay"]') as HTMLDivElement | null;

        expect(content).not.toBeNull();
        expect(underlay).not.toBeNull();
        expect(container.textContent).toContain('Popover layer title');

        const contentRect = content!.getBoundingClientRect();
        const underlayRect = underlay!.getBoundingClientRect();
        const overlapLeft = Math.max(contentRect.left, underlayRect.left);
        const overlapTop = Math.max(contentRect.top, underlayRect.top);
        const overlapRight = Math.min(contentRect.right, underlayRect.right);
        const overlapBottom = Math.min(contentRect.bottom, underlayRect.bottom);

        expect(overlapRight).toBeGreaterThan(overlapLeft);
        expect(overlapBottom).toBeGreaterThan(overlapTop);

        const probeX = overlapLeft + (overlapRight - overlapLeft) / 2;
        const probeY = overlapTop + (overlapBottom - overlapTop) / 2;
        // @ts-ignore WebF exposes an async variant in integration tests.
        const topNode = await document.elementFromPoint_async(probeX, probeY);

        expect(topNode).not.toBeNull();
        expect(content!.contains(topNode as Node)).toBe(true);

        await simulateClick(probeX, probeY);
        await flush(2);
        expect(container.textContent).toContain('Popover layer title');
        await snapshot();
      },
    );
  });
});
