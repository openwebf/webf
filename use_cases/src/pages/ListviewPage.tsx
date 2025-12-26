import React, { useMemo, useRef, useState } from 'react';
import { WebFListView, type WebFListViewElement } from '@openwebf/react-core-ui';

type FinishResult = 'success' | 'fail' | 'noMore';

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

export const ListviewPage: React.FC = () => {
  const listRef = useRef<WebFListViewElement>(null);

  const [scrollDirection, setScrollDirection] = useState<'vertical' | 'horizontal'>('vertical');
  const [shrinkWrap, setShrinkWrap] = useState(false);
  const [refreshStyle, setRefreshStyle] = useState<'default' | 'customCupertino'>('customCupertino');
  const [controlsOpen, setControlsOpen] = useState(true);

  const [items, setItems] = useState<number[]>(() => Array.from({ length: 60 }, (_, i) => i + 1));
  const [hasMore, setHasMore] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);

  const [nextRefreshResult, setNextRefreshResult] = useState<FinishResult>('success');
  const [nextLoadResult, setNextLoadResult] = useState<FinishResult>('success');
  const [lastAction, setLastAction] = useState<string>('—');
  const [refreshCount, setRefreshCount] = useState(0);
  const [loadCount, setLoadCount] = useState(0);

  const headerText = useMemo(() => {
    const styleLabel = refreshStyle === 'customCupertino' ? 'customCupertino' : 'default';
    return `${scrollDirection} · shrinkWrap=${String(shrinkWrap)} · refresh-style=${styleLabel}`;
  }, [refreshStyle, scrollDirection, shrinkWrap]);

  const onRefresh = async () => {
    if (isRefreshing) return;
    setIsRefreshing(true);
    setLastAction('Refreshing…');
    setRefreshCount(v => v + 1);

    await delay(700);

    const result = nextRefreshResult;
    if (result === 'success') {
      setItems(prev => {
        const start = (prev[0] ?? 0) + 1;
        const fresh = Array.from({ length: 8 }, (_, i) => start + i).reverse();
        return [...fresh, ...prev];
      });
      setHasMore(true);
    }

    listRef.current?.finishRefresh(result);
    setLastAction(`Refresh finished: ${result}`);
    setIsRefreshing(false);
  };

  const onLoadmore = async () => {
    if (isLoadingMore) return;

    if (!hasMore) {
      listRef.current?.finishLoad('noMore');
      setLastAction('Load finished: noMore');
      return;
    }

    setIsLoadingMore(true);
    setLastAction('Loading more…');
    setLoadCount(v => v + 1);

    await delay(650);

    const result = nextLoadResult;
    if (result === 'success') {
      setItems(prev => {
        const start = (prev[prev.length - 1] ?? 0) + 1;
        const more = Array.from({ length: 20 }, (_, i) => start + i);
        return [...prev, ...more];
      });
    } else if (result === 'noMore') {
      setHasMore(false);
    }

    listRef.current?.finishLoad(result);
    setLastAction(`Load finished: ${result}`);
    setIsLoadingMore(false);
  };

  const resetHeader = () => {
    listRef.current?.resetHeader();
    setLastAction('Header reset');
  };

  const resetFooter = () => {
    listRef.current?.resetFooter();
    setHasMore(true);
    setLastAction('Footer reset');
  };

  const resetData = () => {
    listRef.current?.resetHeader();
    listRef.current?.resetFooter();
    setItems(Array.from({ length: 60 }, (_, i) => i + 1));
    setHasMore(true);
    setLastAction('Data reset');
  };

  const itemClass =
    scrollDirection === 'horizontal'
      ? 'w-64 mr-3 rounded-xl border border-line bg-surface-secondary p-4 box-border'
      : 'w-full rounded-xl border border-line bg-surface-secondary p-4 box-border';

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView
        ref={listRef}
        className="min-h-screen w-full px-3 md:px-6 py-6 box-border"
        scrollDirection={scrollDirection}
        shrinkWrap={shrinkWrap}
        refresh-style={refreshStyle === 'customCupertino' ? 'customCupertino' : undefined}
        onRefresh={onRefresh}
        onLoadmore={onLoadmore}
      >
        {/* Custom refresh indicator (only visible when refresh-style="customCupertino") */}
        <div
          {...({ slotName: 'refresh-indicator' } as any)}
          className="hidden items-center justify-center py-2"
        >
          <div className="h-4 w-4 border-2 border-[#007aff] border-t-transparent rounded-full animate-spin mr-2" />
          <div className="text-sm font-medium text-[#007aff]">Refreshing…</div>
        </div>

        <div className="bg-surface-secondary rounded-2xl border border-line p-5 mb-5">
          <div className="text-2xl font-semibold text-fg-primary mb-2">WebFListView</div>
          <div className="text-sm text-fg-secondary leading-relaxed">
            Infinite scrolling list optimized for long lists, with pull-to-refresh and load-more.
          </div>
          <div className="mt-3 text-xs font-mono text-fg">{headerText}</div>
        </div>

        <div className="bg-surface-secondary rounded-2xl border border-line p-5 mb-5">
          <div className="text-base font-semibold text-fg-primary mb-2">How to use</div>
          <div className="text-sm text-fg-secondary leading-relaxed">
            Pull down to trigger <span className="font-mono text-fg">onRefresh</span>. Scroll near the end to trigger{' '}
            <span className="font-mono text-fg">onLoadmore</span>. Use{' '}
            <span className="font-mono text-fg">finishRefresh(result)</span> /{' '}
            <span className="font-mono text-fg">finishLoad(result)</span> to control the indicators (success/fail/noMore).
          </div>
        </div>

        <div className="text-sm font-semibold text-fg-primary mb-3">Items</div>
        <div className={scrollDirection === 'horizontal' ? 'flex flex-row' : 'flex flex-col gap-3'}>
          {items.map(n => (
            <div key={n} className={itemClass}>
              <div className="relative">
                <div className="text-base font-semibold text-fg-primary">Item #{n}</div>
                <div className="text-sm text-fg-secondary mt-1">
                  Long-list friendly: keep items simple and keys stable.
                </div>
                <div className="absolute right-0 top-0 text-xs font-mono text-fg-secondary">id:{n}</div>
              </div>
            </div>
          ))}
        </div>

        <div className="h-96" />

        {/* Fixed positioned child: floating controls */}
        <div className="fixed right-4 bottom-4 z-50 w-[380px] max-w-[calc(100vw-2rem)]">
          <div className="bg-surface-secondary border border-line rounded-2xl shadow-lg overflow-hidden animate-[webf-float-panel-in_220ms_ease-out]">
            <div className="flex items-center justify-between px-4 py-3 border-b border-line">
            <div>
              <div className="text-sm font-semibold text-fg-primary">Controls</div>
              <div className="text-[11px] font-mono text-fg-secondary">{headerText}</div>
            </div>
            <button
              className="h-8 w-8 rounded-lg border border-line bg-surface-tertiary text-fg text-sm flex items-center justify-center"
              onClick={() => setControlsOpen(v => !v)}
              aria-label={controlsOpen ? 'Collapse controls' : 'Expand controls'}
              title={controlsOpen ? 'Collapse' : 'Expand'}
            >
              <span
                className={`inline-block transition-transform duration-200 ${controlsOpen ? 'rotate-180' : 'rotate-0'}`}
                aria-hidden="true"
              >
                ▾
              </span>
            </button>
          </div>

          <div
            className={`overflow-hidden transition-[max-height,opacity,transform] duration-200 ease-out will-change-transform ${
              controlsOpen ? 'max-h-[calc(75vh-3.25rem)] opacity-100 translate-y-0' : 'max-h-0 opacity-0 -translate-y-1'
            }`}
          >
            <div className="p-4 max-h-[calc(75vh-3.25rem)] overflow-auto">
              <div className="flex flex-wrap gap-2 mb-4">
                <button
                  className="px-3 py-2 rounded-lg border border-line bg-surface-tertiary text-fg text-sm"
                  onClick={() => setScrollDirection(d => (d === 'vertical' ? 'horizontal' : 'vertical'))}
                >
                  Toggle direction
                </button>
                <button
                  className="px-3 py-2 rounded-lg border border-line bg-surface-tertiary text-fg text-sm"
                  onClick={() => setShrinkWrap(v => !v)}
                >
                  Toggle shrinkWrap
                </button>
                <button
                  className="px-3 py-2 rounded-lg border border-line bg-surface-tertiary text-fg text-sm"
                  onClick={() => setRefreshStyle(v => (v === 'customCupertino' ? 'default' : 'customCupertino'))}
                >
                  Toggle refresh style
                </button>
                <button
                  className="px-3 py-2 rounded-lg border border-line bg-surface-tertiary text-fg text-sm"
                  onClick={resetHeader}
                >
                  resetHeader()
                </button>
                <button
                  className="px-3 py-2 rounded-lg border border-line bg-surface-tertiary text-fg text-sm"
                  onClick={resetFooter}
                >
                  resetFooter()
                </button>
                <button
                  className="px-3 py-2 rounded-lg border border-line bg-surface-tertiary text-fg text-sm"
                  onClick={resetData}
                >
                  Reset data
                </button>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="bg-surface-tertiary rounded-xl border border-line p-4">
                  <div className="text-sm font-semibold text-fg-primary mb-2">Next refresh result</div>
                  <div className="flex flex-wrap gap-2">
                    {(['success', 'fail', 'noMore'] as const).map(v => (
                      <button
                        key={v}
                        className={`px-3 py-2 rounded-lg border text-sm ${
                          nextRefreshResult === v
                            ? 'border-brand-link bg-surface-hover text-fg-primary'
                            : 'border-line bg-surface text-fg'
                        }`}
                        onClick={() => setNextRefreshResult(v)}
                      >
                        {v}
                      </button>
                    ))}
                  </div>
                </div>
                <div className="bg-surface-tertiary rounded-xl border border-line p-4">
                  <div className="text-sm font-semibold text-fg-primary mb-2">Next load result</div>
                  <div className="flex flex-wrap gap-2">
                    {(['success', 'fail', 'noMore'] as const).map(v => (
                      <button
                        key={v}
                        className={`px-3 py-2 rounded-lg border text-sm ${
                          nextLoadResult === v
                            ? 'border-brand-link bg-surface-hover text-fg-primary'
                            : 'border-line bg-surface text-fg'
                        }`}
                        onClick={() => setNextLoadResult(v)}
                      >
                        {v}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="mt-4 text-sm text-fg-secondary">
                Status: <span className="font-mono text-fg">{lastAction}</span> · Items:{' '}
                <span className="font-mono text-fg">{items.length}</span> · Refreshes:{' '}
                <span className="font-mono text-fg">{refreshCount}</span> · Loads:{' '}
                <span className="font-mono text-fg">{loadCount}</span> · hasMore:{' '}
                <span className="font-mono text-fg">{String(hasMore)}</span>
              </div>
            </div>
          </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
