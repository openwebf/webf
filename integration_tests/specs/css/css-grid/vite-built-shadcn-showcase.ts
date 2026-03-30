describe('Vite-built Shadcn showcase in WebF', () => {
  it('wraps the Button card description at mobile width', async () => {
    await resizeViewport(394, 844);

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';

      history.pushState({}, '', '/shadcn-showcase');
      const webfRef = (globalThis as any).webf;
      const originalHybridHistory = webfRef?.hybridHistory;
      if (webfRef && 'hybridHistory' in webfRef) {
        webfRef.hybridHistory = undefined;
      }

      const root = document.createElement('div');
      root.id = 'root';
      document.body.appendChild(root);

      const cssText = await fetch('http://localhost:4000/use_cases-build/assets/index-F1DELOHG.css')
        .then((res) => res.text());
      const style = document.createElement('style');
      style.textContent = cssText.replaceAll('/assets/', 'http://localhost:4000/use_cases-assets/');
      document.head.appendChild(style);

      const jsText = await fetch('http://localhost:4000/use_cases-build/assets/index-BPE63uTS.js')
        .then((res) => res.text());
      const script = document.createElement('script');
      script.type = 'module';
      script.textContent = jsText.replaceAll('/assets/', 'http://localhost:4000/use_cases-assets/');
      document.body.appendChild(script);

      await nextFrames(24);

      const paragraphTexts = Array.from(document.querySelectorAll('p'))
        .map((node) => node.textContent || '')
        .slice(0, 20);
      const headingTexts = Array.from(document.querySelectorAll('h1, h2, h3'))
        .map((node) => node.textContent || '')
        .slice(0, 20);
      console.log('location.pathname=', location.pathname);
      console.log('hybridHistory.path=', (globalThis as any).webf?.hybridHistory?.path);
      console.log('headings=', JSON.stringify(headingTexts));
      console.log('paragraphs=', JSON.stringify(paragraphTexts));

      const desc = Array.from(document.querySelectorAll('p')).find((node) =>
        node.textContent?.includes('对齐官网的 variant 和 size 组合，用本地组件层驱动 use case。'),
      ) as HTMLElement | undefined;

      expect(desc).toBeDefined();

      const header = desc!.parentElement as HTMLElement;
      const action = Array.from(header.children).find((node) =>
        node.textContent?.includes('official style'),
      ) as HTMLElement | undefined;

      expect(action).toBeDefined();

      const descRect = desc!.getBoundingClientRect();
      const actionRect = action!.getBoundingClientRect();

      expect(descRect.height).toBeGreaterThan(30);
      expect(descRect.right).toBeLessThanOrEqual(actionRect.left + 1);

      await snapshot();

      if (webfRef && 'hybridHistory' in webfRef) {
        webfRef.hybridHistory = originalHybridHistory;
      }
    } finally {
      await resizeViewport(-1, -1);
    }
  });
});
