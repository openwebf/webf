describe('CSS Grid tailwind arbitrary class selector', () => {
  it('applies escaped class selector for grid template columns', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .grid { display: grid; }
      .grid-cols-\\[1fr_auto\\] { grid-template-columns: 1fr auto; }
      .gap-x-4 { column-gap: 16px; }
    `;
    document.head.appendChild(style);

    const grid = document.createElement('div');
    grid.className = 'grid grid-cols-[1fr_auto] gap-x-4';
    grid.style.width = '394px';

    const item1 = document.createElement('div');
    item1.textContent = 'left';
    item1.style.backgroundColor = '#dbeafe';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'badge';
    item2.style.whiteSpace = 'nowrap';
    item2.style.backgroundColor = '#fee2e2';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();

    expect(getComputedStyle(grid).display).toBe('grid');
    expect(getComputedStyle(grid).gridTemplateColumns).toContain('auto');
    expect(item1.getBoundingClientRect().right).toBeLessThanOrEqual(item2.getBoundingClientRect().left);

    grid.remove();
    style.remove();
  });

  it('wraps card description when layout is driven by escaped tailwind classes', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .grid { display: grid; }
      .grid-cols-\\[1fr_auto\\] { grid-template-columns: 1fr auto; }
      .items-start { align-items: start; }
      .gap-x-4 { column-gap: 16px; }
      .gap-y-1\\.5 { row-gap: 6px; }
      .p-6 { padding: 24px; }
      .pb-0 { padding-bottom: 0; }
      .col-start-1 { grid-column-start: 1; }
      .col-start-2 { grid-column-start: 2; }
      .row-span-2 { grid-row: span 2 / span 2; }
      .self-start { align-self: start; }
      .text-base { font-size: 16px; }
      .text-sm { font-size: 14px; }
      .font-semibold { font-weight: 600; }
      .leading-none { line-height: 1; }
      .text-zinc-500 { color: rgb(113, 113, 122); }
      .tracking-tight { letter-spacing: -0.025em; }
      .badge {
        display: inline-flex;
        white-space: nowrap;
        border: 1px solid rgb(228, 228, 231);
        border-radius: 9999px;
        padding: 2px 10px;
        font-size: 12px;
        line-height: 16px;
      }
    `;
    document.head.appendChild(style);

    const header = document.createElement('div');
    header.className = 'grid grid-cols-[1fr_auto] items-start gap-x-4 gap-y-1.5 p-6 pb-0';
    header.style.width = '394px';
    header.style.boxSizing = 'border-box';
    header.style.border = '1px solid rgb(228, 228, 231)';
    header.style.backgroundColor = 'white';

    const title = document.createElement('h3');
    title.className = 'col-start-1 text-base font-semibold leading-none tracking-tight';
    title.style.margin = '0';
    title.textContent = 'Button';
    header.appendChild(title);

    const desc = document.createElement('p');
    desc.className = 'col-start-1 text-sm text-zinc-500';
    desc.style.margin = '0';
    desc.style.lineHeight = '24px';
    desc.textContent = '对齐官网的 variant 和 size 组合，用本地组件层驱动 use case。';
    header.appendChild(desc);

    const action = document.createElement('div');
    action.className = 'col-start-2 row-span-2 self-start';
    const badge = document.createElement('span');
    badge.className = 'badge';
    badge.textContent = 'official style';
    action.appendChild(badge);
    header.appendChild(action);

    document.body.appendChild(header);
    await waitForFrame();
    await snapshot();

    const descRect = desc.getBoundingClientRect();
    const actionRect = action.getBoundingClientRect();

    expect(descRect.height).toBeGreaterThan(30);
    expect(descRect.right).toBeLessThanOrEqual(actionRect.left + 1);

    header.remove();
    style.remove();
  });

  it('wraps card description inside webf-listview mobile constraints', async () => {
    await resizeViewport(394, 844);

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';

      const style = document.createElement('style');
      style.textContent = `
        .grid { display: grid; }
        .grid-cols-\\[1fr_auto\\] { grid-template-columns: 1fr auto; }
        .items-start { align-items: start; }
        .gap-x-4 { column-gap: 16px; }
        .gap-y-1\\.5 { row-gap: 6px; }
        .p-6 { padding: 24px; }
        .pb-0 { padding-bottom: 0; }
        .col-start-1 { grid-column-start: 1; }
        .col-start-2 { grid-column-start: 2; }
        .row-span-2 { grid-row: span 2 / span 2; }
        .self-start { align-self: start; }
        .text-base { font-size: 16px; }
        .text-sm { font-size: 14px; }
        .font-semibold { font-weight: 600; }
        .leading-none { line-height: 1; }
        .text-zinc-500 { color: rgb(113, 113, 122); }
        .tracking-tight { letter-spacing: -0.025em; }
        .card {
          border: 1px solid rgb(228, 228, 231);
          border-radius: 12px;
          background: white;
          box-sizing: border-box;
        }
        .badge {
          display: inline-flex;
          align-items: center;
          border: 1px solid rgb(228, 228, 231);
          border-radius: 9999px;
          padding: 2px 10px;
          font-size: 12px;
          line-height: 16px;
          white-space: nowrap;
        }
      `;
      document.head.appendChild(style);

      const listView = createElement(
        'webf-listview',
        {
          id: 'listview',
          style: {
            width: '100%',
            padding: '24px 16px',
            boxSizing: 'border-box',
            backgroundColor: 'rgb(250, 250, 250)',
          },
        },
        [
          createElement('section', { style: { display: 'block' } }, [
            createElement('div', { id: 'card', className: 'card' }, [
              createElement('div', {
                id: 'header',
                className: 'grid grid-cols-[1fr_auto] items-start gap-x-4 gap-y-1.5 p-6 pb-0',
              }, [
                createElement('h3', {
                  id: 'title',
                  className: 'col-start-1 text-base font-semibold leading-none tracking-tight',
                  style: { margin: '0' },
                }, [createText('Button')]),
                createElement('p', {
                  id: 'desc',
                  className: 'col-start-1 text-sm text-zinc-500',
                  style: { margin: '0', lineHeight: '24px' },
                }, [createText('对齐官网的 variant 和 size 组合，用本地组件层驱动 use case。')]),
                createElement('div', { id: 'action', className: 'col-start-2 row-span-2 self-start' }, [
                  createElement('div', { className: 'badge' }, [createText('official style')]),
                ]),
              ]),
            ]),
          ]),
        ],
      );

      BODY.appendChild(listView);

      await waitForOnScreen(listView as any);
      await waitForFrame();
      await nextFrames(2);
      await snapshot();

      const header = document.getElementById('header') as HTMLElement;
      const desc = document.getElementById('desc') as HTMLElement;
      const action = document.getElementById('action') as HTMLElement;
      const headerRect = header.getBoundingClientRect();
      const descRect = desc.getBoundingClientRect();
      const actionRect = action.getBoundingClientRect();

      expect(headerRect.width).toBeGreaterThan(0);
      expect(descRect.height).toBeGreaterThan(30);
      expect(descRect.right).toBeLessThanOrEqual(actionRect.left + 1);

      listView.remove();
      style.remove();
    } finally {
      await resizeViewport(-1, -1);
    }
  });
});
