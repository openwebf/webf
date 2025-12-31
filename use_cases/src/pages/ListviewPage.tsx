import React, { useMemo, useRef, useState } from 'react';
import { WebFListView, type WebFListViewElement } from '@openwebf/react-core-ui';

type FinishResult = 'success' | 'fail' | 'noMore';

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

export const ListviewPage: React.FC = () => {
  const listRef = useRef<WebFListViewElement>(null);

  const [scrollDirection, setScrollDirection] = useState<'vertical' | 'horizontal'>('vertical');
  const [shrinkWrap, setShrinkWrap] = useState(false);
  const [refreshStyle, setRefreshStyle] = useState<'default' | 'customCupertino'>('customCupertino');

  const [items, setItems] = useState<number[]>(() => Array.from({ length: 60 }, (_, i) => i + 1));
  const [hasMore, setHasMore] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);

  const [nextRefreshResult, setNextRefreshResult] = useState<FinishResult>('success');
  const [nextLoadResult, setNextLoadResult] = useState<FinishResult>('success');
  const [refreshCount, setRefreshCount] = useState(0);
  const [loadCount, setLoadCount] = useState(0);

  const headerText = useMemo(() => {
    const styleLabel = refreshStyle === 'customCupertino' ? 'customCupertino' : 'default';
    return `${scrollDirection} · shrinkWrap=${String(shrinkWrap)} · refresh-style=${styleLabel}`;
  }, [refreshStyle, scrollDirection, shrinkWrap]);

  const onRefresh = async () => {
    if (isRefreshing) return;
    setIsRefreshing(true);
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
    setIsRefreshing(false);
  };

  const onLoadmore = async () => {
    if (isLoadingMore) return;

    if (!hasMore) {
      listRef.current?.finishLoad('noMore');
      return;
    }

    setIsLoadingMore(true);
    setLoadCount(v => v + 1);

    await delay(650);

    const result = nextLoadResult;

    listRef.current?.finishLoad(result);

    if (result === 'success') {
      setItems(prev => {
        const start = (prev[prev.length - 1] ?? 0) + 1;
        const more = Array.from({ length: 20 }, (_, i) => start + i);
        return [...prev, ...more];
      });
    } else if (result === 'noMore') {
      setHasMore(false);
    }
    setIsLoadingMore(false);
  };

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
        {items.map(n => (
          <div key={n} className="w-full rounded-xl border border-line bg-surface-secondary p-4 mt-4 box-border">
            <div className="relative">
              <div className="text-base font-semibold text-fg-primary">Item #{n}</div>
              <div className="text-sm text-fg-secondary mt-1">
                Long-list friendly: keep items simple and keys stable.
              </div>
              <div className="absolute right-0 top-0 text-xs font-mono text-fg-secondary">id:{n}</div>
            </div>
          </div>
        ))}
      </WebFListView>
    </div>
  );
};
