import React, { useEffect, useRef, useState } from 'react';
import { WebFListView, WebFTouchArea } from '@openwebf/react-core-ui';

export const DOMEventsPage: React.FC = () => {
  const touchAreaRef = useRef<HTMLElement>(null);
  const scrollBoxRef = useRef<HTMLDivElement>(null);
  const customRef = useRef<HTMLDivElement>(null);
  const [log, setLog] = useState<string[]>([]);
  const [isLogCollapsed, setIsLogCollapsed] = useState(false);

  const push = (s: string) => setLog(prev => [new Date().toLocaleTimeString() + ' ' + s, ...prev].slice(0, 50));

  // Use WebFTouchArea for interaction events instead of raw DOM listeners
  const getRelative = (evt: TouchEvent) => {
    const el = touchAreaRef.current as HTMLElement | null;
    const t = (evt.touches && evt.touches[0]) || (evt.changedTouches && evt.changedTouches[0]);
    if (!el || !t) return { x: 0, y: 0 };
    const rect = el.getBoundingClientRect();
    return { x: Math.round(t.clientX - rect.left), y: Math.round(t.clientY - rect.top) };
  };

  // Use JSX onScroll rather than imperative listener

  useEffect(() => {
    const el = customRef.current;
    if (!el) return;
    const onCustom = (e: Event) => push('CustomEvent received: my-event');
    el.addEventListener('my-event', onCustom as EventListener);
    return () => el.removeEventListener('my-event', onCustom as EventListener);
  }, []);

  const dispatchCustom = () => {
    const ev = new CustomEvent('my-event', { detail: { hello: 'world' } });
    customRef.current?.dispatchEvent(ev);
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6 pb-40">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">DOM Events</h1>

          <WebFTouchArea
            ref={touchAreaRef}
            className="bg-surface-secondary border border-line rounded-xl p-4 mb-6"
            onTouchStart={(e) => {
              const { x, y } = getRelative(e);
              push(`touchstart @(${x},${y})`);
            }}
            onTouchMove={(e) => {
              const { x, y } = getRelative(e);
              push(`touchmove @(${x},${y})`);
            }}
            onTouchEnd={(e) => {
              const { x, y } = getRelative(e);
              push(`touchend @(${x},${y})`);
            }}
            onTouchCancel={() => push('touchcancel')}
          >
            <h2 className="text-lg font-medium text-fg-primary mb-2">Touch Events</h2>
            <div className="w-56 h-28 border border-dashed border-line rounded-md bg-surface flex items-center justify-center text-fg-secondary select-none">
              Touch / Drag Here
            </div>
          </WebFTouchArea>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Scroll Events</h2>
            <div
              ref={scrollBoxRef}
              className="w-56 h-28 border border-dashed border-line rounded-md bg-surface overflow-auto"
              onScroll={(e) => push('scroll: ' + (e.currentTarget as HTMLDivElement).scrollTop)}
            >
              <div className="h-[300px] p-2">Scrollable content</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">CustomEvent</h2>
            <div ref={customRef} className="w-56 h-28 border border-dashed border-line rounded-md bg-surface flex items-center justify-center">
              Listen: my-event
            </div>
            <div className="mt-2">
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={dispatchCustom}>
                Dispatch my-event
              </button>
            </div>
          </div>
          {/* Log moved to fixed bottom panel */}
      </WebFListView>
      {/* Fixed Bottom Event Log Panel */}
      <div className="fixed bottom-0 left-0 right-0 z-50">
        <div className="max-w-3xl mx-auto px-3 md:px-6">
          <div className="bg-surface-secondary border border-line rounded-t-xl shadow-xl">
            <div className="flex items-center justify-between p-3">
              <div className="text-lg font-medium text-fg-primary">Event Log</div>
              <div className="flex items-center gap-2">
                <button
                  className="px-3 py-1.5 rounded bg-black text-white hover:bg-neutral-700 text-sm"
                  onClick={() => setLog([])}
                >
                  Clear
                </button>
                <button
                  className="px-3 py-1.5 rounded border border-line bg-white hover:bg-neutral-50 text-sm"
                  onClick={() => setIsLogCollapsed(v => !v)}
                  aria-expanded={!isLogCollapsed}
                  aria-controls="event-log-panel"
                >
                  {isLogCollapsed ? 'Expand' : 'Fold'}
                </button>
              </div>
            </div>
            <div
              id="event-log-panel"
              className={`border-t border-line rounded-b-xl overflow-hidden transition-all duration-300 ease-in-out ${
                isLogCollapsed ? 'max-h-0 opacity-0' : 'max-h-[24vh] opacity-100'
              }`}
            >
              <div className="bg-surface p-3 overflow-y-auto max-h-[24vh] text-sm font-mono">
                {log.length === 0 ? (
                  <div className="text-center text-fg-secondary italic py-6">No events yet</div>
                ) : (
                  log.map((l, i) => (<div key={i} className="py-0.5">{l}</div>))
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
