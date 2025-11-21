import React, { useMemo, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMStylePage: React.FC = () => {
  const [bg, setBg] = useState('#93c5fd');
  const [w, setW] = useState(140);
  const [transform, setTransform] = useState('rotate(0deg)');

  const boxStyle = useMemo<React.CSSProperties>(() => ({
    background: bg,
    width: w,
    transform,
  }), [bg, w, transform]);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">element.style</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="flex gap-2 flex-wrap items-center">
              <label className="text-sm">background <input className="ml-1 rounded border border-line px-2 py-1 bg-surface" value={bg} onChange={e => setBg(e.target.value)} /></label>
              <label className="text-sm">width(px) <input className="ml-1 rounded border border-line px-2 py-1 bg-surface" value={w} onChange={e => setW(Number(e.target.value) || 0)} /></label>
              <label className="text-sm">transform <input className="ml-1 rounded border border-line px-2 py-1 bg-surface" value={transform} onChange={e => setTransform(e.target.value)} /></label>
            </div>
            <div className="mt-3">
              <div className="h-20 border border-line rounded bg-gray-200 flex items-center justify-center" style={boxStyle}>target</div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
