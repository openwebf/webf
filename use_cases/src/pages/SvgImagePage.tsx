import React, { useMemo, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

const makeSvg = (color: string) =>
  `data:image/svg+xml;utf8,` +
  encodeURIComponent(`
<svg xmlns='http://www.w3.org/2000/svg' width='100' height='100' viewBox='0 0 100 100'>
  <rect x='5' y='5' width='90' height='90' rx='12' ry='12' fill='${color}' stroke='black' stroke-width='2'/>
  <text x='50' y='55' font-size='18' text-anchor='middle' fill='white' font-family='sans-serif'>SVG</text>
  Sorry, your browser does not support inline SVG.
</svg>`);

export const SvgImagePage: React.FC = () => {
  const [color, setColor] = useState('#10b981');
  const [size, setSize] = useState(100);
  const src = useMemo(() => makeSvg(color), [color]);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">SVG via &lt;img&gt;</h1>
          <p className="text-fg-secondary mb-4">Demonstrate rendering inline SVG data URLs and dynamic sizing.</p>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="md:flex md:space-x-3 space-y-3 md:space-y-0">
              <div className="flex-1">
                <label className="text-sm text-fg-secondary">Color</label>
                <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={color} onChange={(e) => setColor(e.target.value)} />
              </div>
              <div className="w-full md:w-40">
                <label className="text-sm text-fg-secondary">Size (px)</label>
                <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={size} onChange={(e) => setSize(Number(e.target.value) || 0)} />
              </div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 flex items-center justify-center">
            <img src={src} alt="svg" style={{ width: size, height: size }} />
          </div>
        </div>
      </WebFListView>
    </div>
  );
};

