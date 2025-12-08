import React, { useMemo, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMGeometryPage: React.FC = () => {
  const support = typeof (globalThis as any).DOMMatrix !== 'undefined' && typeof (globalThis as any).DOMPoint !== 'undefined';

  // Interactive controls
  const [tx, setTx] = useState(10);
  const [ty, setTy] = useState(20);
  const [sx, setSx] = useState(1.25);
  const [sy, setSy] = useState(1.25);
  const [deg, setDeg] = useState(15);
  const [px, setPx] = useState(10);
  const [py, setPy] = useState(20);

  const geom = useMemo(() => {
    try {
      const M = (globalThis as any).DOMMatrix;
      const P = (globalThis as any).DOMPoint;
      const m = new M().translate(tx, ty).scale(sx, sy).rotate(0, 0, deg);
      const p = new P(px, py);
      const p2 = p.matrixTransform(m);
      const inv = m.inverse();
      const back = new P(p2.x, p2.y).matrixTransform(inv);
      return {
        matrix: m,
        matrix2d: { a: m.a, b: m.b, c: m.c, d: m.d, e: m.e, f: m.f },
        is2D: (m as any).is2D,
        isIdentity: (m as any).isIdentity,
        point: { x: p.x, y: p.y },
        transformed: { x: p2.x, y: p2.y },
        roundTrip: { x: back.x, y: back.y },
        css: `translate(${tx}px, ${ty}px) scale(${sx}, ${sy}) rotate(${deg}deg)`
      };
    } catch {
      return null;
    }
  }, [tx, ty, sx, sy, deg, px, py]);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">DOMMatrix / DOMPoint</h1>

          {/* Overview */}
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-lg font-medium text-fg-primary mb-2">Overview</div>
            {!support ? (
              <div className="text-fg-secondary">DOMMatrix/DOMPoint not available in this environment.</div>
            ) : (
              <div className="text-sm text-fg-secondary leading-relaxed">
                <p className="mb-2"><span className="font-semibold text-fg-primary">DOMPoint</span> represents a point in 2D/3D space. <span className="font-semibold text-fg-primary">DOMMatrix</span> represents an affine transform (translate, scale, rotate, etc.). Combine them to transform coordinates or elements.</p>
                <p>Below you can tweak a matrix and see: the raw matrix values, how a point is transformed, and the same transform applied to a demo element.</p>
              </div>
            )}
          </div>

          {/* Interactive Matrix Builder */}
          {support && geom && (
            <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
              <div className="text-lg font-medium text-fg-primary mb-3">Interactive Matrix Builder</div>
              <div className="flex flex-col md:flex-row gap-4">
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-fg-primary mb-2">Transform Controls</div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-3">
                      <label className="text-xs text-fg-secondary w-24">Translate X</label>
                      <input type="range" min={-200} max={200} step={1} value={tx} onChange={e => setTx(parseInt(e.target.value, 10))} className="flex-1" />
                      <input type="number" value={tx} onChange={e => setTx(parseInt(e.target.value || '0', 10))} className="w-20 rounded border border-line px-2 py-1 text-sm" />
                    </div>
                    <div className="flex items-center gap-3">
                      <label className="text-xs text-fg-secondary w-24">Translate Y</label>
                      <input type="range" min={-200} max={200} step={1} value={ty} onChange={e => setTy(parseInt(e.target.value, 10))} className="flex-1" />
                      <input type="number" value={ty} onChange={e => setTy(parseInt(e.target.value || '0', 10))} className="w-20 rounded border border-line px-2 py-1 text-sm" />
                    </div>
                    <div className="flex items-center gap-3">
                      <label className="text-xs text-fg-secondary w-24">Scale X</label>
                      <input type="range" min={0.25} max={3} step={0.01} value={sx} onChange={e => setSx(parseFloat(e.target.value))} className="flex-1" />
                      <input type="number" step="0.01" value={sx} onChange={e => setSx(parseFloat(e.target.value || '1'))} className="w-20 rounded border border-line px-2 py-1 text-sm" />
                    </div>
                    <div className="flex items-center gap-3">
                      <label className="text-xs text-fg-secondary w-24">Scale Y</label>
                      <input type="range" min={0.25} max={3} step={0.01} value={sy} onChange={e => setSy(parseFloat(e.target.value))} className="flex-1" />
                      <input type="number" step="0.01" value={sy} onChange={e => setSy(parseFloat(e.target.value || '1'))} className="w-20 rounded border border-line px-2 py-1 text-sm" />
                    </div>
                    <div className="flex items-center gap-3">
                      <label className="text-xs text-fg-secondary w-24">Rotate (deg)</label>
                      <input type="range" min={-180} max={180} step={1} value={deg} onChange={e => setDeg(parseInt(e.target.value, 10))} className="flex-1" />
                      <input type="number" value={deg} onChange={e => setDeg(parseInt(e.target.value || '0', 10))} className="w-20 rounded border border-line px-2 py-1 text-sm" />
                    </div>
                  </div>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-fg-primary mb-2">Matrix (2D components)</div>
                  <div className="flex flex-wrap gap-2 text-sm font-mono">
                    <div className="p-2 bg-white rounded border flex-1 min-w-[120px]">a: {geom.matrix2d.a.toFixed(4)}</div>
                    <div className="p-2 bg-white rounded border flex-1 min-w-[120px]">b: {geom.matrix2d.b.toFixed(4)}</div>
                    <div className="p-2 bg-white rounded border flex-1 min-w-[120px]">c: {geom.matrix2d.c.toFixed(4)}</div>
                    <div className="p-2 bg-white rounded border flex-1 min-w-[120px]">d: {geom.matrix2d.d.toFixed(4)}</div>
                    <div className="p-2 bg-white rounded border flex-1 min-w-[120px]">e: {geom.matrix2d.e.toFixed(4)}</div>
                    <div className="p-2 bg-white rounded border flex-1 min-w-[120px]">f: {geom.matrix2d.f.toFixed(4)}</div>
                  </div>
                  <div className="flex gap-2 text-xs text-fg-secondary mt-2">
                    <span className="px-2 py-1 bg-white rounded border">is2D: {String(geom.is2D)}</span>
                    <span className="px-2 py-1 bg-white rounded border">isIdentity: {String(geom.isIdentity)}</span>
                  </div>
                </div>
              </div>

              <div className="mt-4 flex flex-col md:flex-row gap-4">
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-fg-primary mb-2">Transform a Point</div>
                  <div className="flex items-center gap-3 mb-3">
                    <label className="text-xs text-fg-secondary w-24">Point (x, y)</label>
                    <input type="number" value={px} onChange={e => setPx(parseInt(e.target.value || '0', 10))} className="w-20 rounded border border-line px-2 py-1 text-sm" />
                    <input type="number" value={py} onChange={e => setPy(parseInt(e.target.value || '0', 10))} className="w-20 rounded border border-line px-2 py-1 text-sm" />
                  </div>
                  <pre className="font-mono text-xs bg-surface rounded border border-line p-2">{JSON.stringify({ from: geom.point, to: geom.transformed, inverseBack: geom.roundTrip }, null, 2)}</pre>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-fg-primary mb-2">Apply to Element</div>
                  <div className="relative h-40 border border-dashed border-line rounded bg-white overflow-hidden">
                    <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 border-2 border-rose-500/40 rounded pointer-events-none" />
                    <div
                      className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 bg-gradient-to-tr from-indigo-500 to-purple-600 rounded shadow text-white flex items-center justify-center text-xs font-semibold"
                      style={{ transform: geom.css }}
                    >
                      transform
                    </div>
                  </div>
                  <div className="text-xs text-fg-secondary mt-2 font-mono break-all">
                    CSS: {geom.css}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Recipes */}
          {support && (
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Common Recipes</div>
              <ul className="list-disc pl-5 text-sm text-fg-secondary space-y-2">
                <li><span className="font-semibold text-fg-primary">Compose transforms</span>: `new DOMMatrix().translate(x,y).scale(sx,sy).rotate(0,0,deg)`</li>
                <li><span className="font-semibold text-fg-primary">Transform a point</span>: `new DOMPoint(x,y).matrixTransform(matrix)`</li>
                <li><span className="font-semibold text-fg-primary">Invert a matrix</span>: `const inv = matrix.inverse();`</li>
                <li><span className="font-semibold text-fg-primary">Multiply matrices</span>: `m3 = m1.multiply(m2)` (apply `m2` then `m1`).</li>
                <li><span className="font-semibold text-fg-primary">From arrays/strings</span>: `DOMMatrix.fromFloat32Array(arr)` or `new DOMMatrix(cssMatrixString)`.</li>
              </ul>
            </div>
          )}
      </WebFListView>
    </div>
  );
};
