import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMOffsetsPage: React.FC = () => {
  const wrapRef = useRef<HTMLDivElement>(null);
  const targetRef = useRef<HTMLDivElement>(null);
  const [result, setResult] = useState<any>(null);

  const measure = () => {
    const el = targetRef.current!;
    const rect = el.getBoundingClientRect();
    setResult({
      offsetWidth: el.offsetWidth,
      offsetHeight: el.offsetHeight,
      offsetTop: el.offsetTop,
      offsetLeft: el.offsetLeft,
      rect: { x: rect.x, y: rect.y, width: rect.width, height: rect.height },
    });
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Offsets & Measurements</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div ref={wrapRef} className="relative p-3 border border-dashed border-line rounded bg-surface">
              <div ref={targetRef} className="relative w-40 h-24 bg-emerald-100 border border-line rounded" />
            </div>
            <div className="mt-2">
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={measure}>Measure</button>
            </div>
            {result && (
              <pre className="font-mono text-sm mt-2">{JSON.stringify(result, null, 2)}</pre>
            )}
          </div>
      </WebFListView>
    </div>
  );
};
