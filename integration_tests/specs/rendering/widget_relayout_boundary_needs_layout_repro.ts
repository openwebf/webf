async function openCupertinoContextMenuFor(target: HTMLElement) {
  const rect = target.getBoundingClientRect();
  const x = rect.left + rect.width / 2;
  const y = rect.top + rect.height / 2;

  try {
    await simulatePointAdd(x, y, 1);
    await simulatePointDown(x, y, 1);
    await sleep(0.8);
  } finally {
    await simulatePointUp(x, y, 1);
    await simulatePointRemove(x, y, 1);
  }

  await sleep(0.8);
  await nextFrames(8);
}

function webfSyncStyleBuffer() {
  const sync = (globalThis as any).__webf_sync_buffer__;
  if (typeof sync === 'function') sync();
}

async function assertNoFlutterRelayoutBoundaryError() {
  const flutterError = await takeFlutterError();
  if (!flutterError) return;

  if (flutterError.includes('_debugRelayoutBoundaryAlreadyMarkedNeedsLayout')) {
    fail(flutterError);
    return;
  }

  fail(`Unexpected Flutter error:\n${flutterError}`);
}

describe('_debugRelayoutBoundaryAlreadyMarkedNeedsLayout repro', () => {
  async function mountScroller(options: {
    scrollerOverflow: string;
    targetMaxHeight: string;
    useContextMenu?: boolean;
  }) {
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    const target = createElement(
      'div',
      {
        id: 'target',
        style: {
          height: '400px',
          maxHeight: options.targetMaxHeight,
          backgroundColor: '#dbeafe',
        },
      },
      [createText('target')],
    );

    const scroller = createElement(
      'div',
      {
        id: 'scroller',
        style: {
          width: '200px',
          height: '200px',
          overflow: options.scrollerOverflow,
          position: 'relative',
          border: '1px solid #111827',
          boxSizing: 'border-box',
        },
      },
      [target],
    ) as HTMLDivElement;

    const root = createElement(
      'div',
      {
        id: 'root',
        style: {
          padding: '24px',
        },
      },
      [],
    );

    if (options.useContextMenu) {
      const contextMenu = createElement('flutter-cupertino-context-menu', { id: 'menu' }, [scroller]);
      (contextMenu as any).setActions([{ text: 'Open', event: 'open', default: true }]);
      root.appendChild(contextMenu);
    } else {
      root.appendChild(scroller);
    }

    document.body.appendChild(root);

    await waitForOnScreen(root);
    await nextFrames(2);

    return { root, scroller, target };
  }

  afterEach(async () => {
    try {
      await dismissFlutterOverlays();
    } catch (_) {}
    try {
      document.getElementById('root')?.remove();
    } catch (_) {}
    try {
      await resizeViewport(-1, -1);
    } catch (_) {}
    try {
      await clearFlutterError();
    } catch (_) {}
  });

  it('Test 1: Multi-subtree mount (CupertinoContextMenu) + sizing invalidation', async () => {
    await clearFlutterError();
    await resizeViewport(800, 600);

    const { scroller, target } = await mountScroller({
      scrollerOverflow: 'scroll',
      targetMaxHeight: 'none',
      useContextMenu: true,
    });

    scroller.scrollTop = 120;
    await openCupertinoContextMenuFor(target);
    await nextFrames(2);

    target.style.maxHeight = '50px';
    webfSyncStyleBuffer();

    await nextFrames(2);
    await assertNoFlutterRelayoutBoundaryError();
  });

  it('Test 2: Overflow wrapper rebuild + sizing change in same batch', async () => {
    await clearFlutterError();
    await resizeViewport(800, 600);

    const { scroller, target } = await mountScroller({
      scrollerOverflow: 'visible',
      targetMaxHeight: 'none',
      useContextMenu: false,
    });

    scroller.style.overflow = 'scroll';
    target.style.maxHeight = '50px';
    webfSyncStyleBuffer();

    await nextFrames(2);
    await assertNoFlutterRelayoutBoundaryError();
  });

  it('Test 3: Position reattach (static→absolute) + sizing change', async () => {
    await clearFlutterError();
    await resizeViewport(800, 600);

    const { scroller, target } = await mountScroller({
      scrollerOverflow: 'scroll',
      targetMaxHeight: 'none',
      useContextMenu: false,
    });

    target.style.position = 'absolute';
    target.style.left = '0';
    target.style.top = '0';
    target.style.maxHeight = '50px';
    webfSyncStyleBuffer();

    await nextFrames(2);
    await assertNoFlutterRelayoutBoundaryError();
  });
});
