import React, { useEffect, useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMEventsPage: React.FC = () => {
  const mouseBoxRef = useRef<HTMLDivElement>(null);
  const scrollBoxRef = useRef<HTMLDivElement>(null);
  const customRef = useRef<HTMLDivElement>(null);
  const [log, setLog] = useState<string[]>([]);

  const push = (s: string) => setLog(prev => [new Date().toLocaleTimeString() + ' ' + s, ...prev].slice(0, 50));

  useEffect(() => {
    const mouseEl = mouseBoxRef.current;
    if (!mouseEl) return;
    const onMove = (e: MouseEvent) => push(`mousemove @(${e.offsetX},${e.offsetY})`);
    const onDown = () => push('mousedown');
    const onEnter = () => push('mouseenter');
    mouseEl.addEventListener('mousemove', onMove);
    mouseEl.addEventListener('mousedown', onDown);
    mouseEl.addEventListener('mouseenter', onEnter);
    return () => {
      mouseEl.removeEventListener('mousemove', onMove);
      mouseEl.removeEventListener('mousedown', onDown);
      mouseEl.removeEventListener('mouseenter', onEnter);
    };
  }, []);

  useEffect(() => {
    const el = scrollBoxRef.current;
    if (!el) return;
    const onScroll = () => push('scroll: ' + el.scrollTop);
    el.addEventListener('scroll', onScroll);
    return () => el.removeEventListener('scroll', onScroll);
  }, []);

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
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">DOM Events</h1>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Mouse Events</h2>
            <div ref={mouseBoxRef} className="w-56 h-28 border border-dashed border-line rounded-md bg-surface flex items-center justify-center text-fg-secondary">
              Move / Click Me
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Scroll Events</h2>
            <div ref={scrollBoxRef} className="w-56 h-28 border border-dashed border-line rounded-md bg-surface overflow-auto">
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

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Log</h2>
            <div className="text-sm font-mono bg-surface border border-line rounded p-2 max-h-64 overflow-auto">
              {log.length === 0 ? 'No events yet' : log.map((l, i) => (<div key={i}>{l}</div>))}
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
