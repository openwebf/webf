/** @jsxImportSource react */
import React from 'react';
import styles from './shadcn_showcase_page.css';
import { ShadcnShowcasePage } from '../../../../use_cases/src/pages/ShadcnShowcasePage';

describe('ShadcnShowcasePage runtime', () => {
  it('wraps the Button card description at mobile width', async () => {
    styles.use();

    await resizeViewport(394, 844);

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';

      await withReactSpec(
        <ShadcnShowcasePage />,
        async ({ container, flush }) => {
          await flush(6);
          await nextFrames(2);

          const desc = Array.from(container.querySelectorAll('p')).find(
            (node) =>
              node.textContent?.includes('对齐官网的 variant 和 size 组合，用本地组件层驱动 use case。'),
          ) as HTMLElement | undefined;

          expect(desc).toBeDefined();

          const header = desc!.parentElement as HTMLElement | null;
          const action = Array.from(header?.children ?? []).find((node) =>
            node.textContent?.includes('official style'),
          ) as HTMLElement | undefined;

          expect(header).not.toBeNull();
          expect(action).toBeDefined();

          const descRect = desc!.getBoundingClientRect();
          const actionRect = action!.getBoundingClientRect();

          expect(descRect.height).toBeGreaterThan(30);
          expect(descRect.right).toBeLessThanOrEqual(actionRect.left + 1);

          await snapshot();
        },
        {
          containerStyle: {
            width: '100%',
          },
          framesToWait: 4,
        },
      );
    } finally {
      styles.unuse();
      await resizeViewport(-1, -1);
    }
  });
});
