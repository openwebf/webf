import React, { useMemo } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMGeometryPage: React.FC = () => {
  const support = typeof (globalThis as any).DOMMatrix !== 'undefined' && typeof (globalThis as any).DOMPoint !== 'undefined';

  const geom = useMemo(() => {
    try {
      const M = (globalThis as any).DOMMatrix;
      const P = (globalThis as any).DOMPoint;
      const m = new M().translate(10, 20).scale(1.5).rotate(0, 0, 15);
      const p = new P(10, 20);
      const p2 = p.matrixTransform(m);
      return {
        matrix: { a: m.a, b: m.b, c: m.c, d: m.d, e: m.e, f: m.f },
        point: { x: p.x, y: p.y },
        transformed: { x: p2.x, y: p2.y },
      };
    } catch {
      return null;
    }
  }, []);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">DOMMatrix / DOMPoint</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            {!support || !geom ? (
              <div>DOMMatrix/DOMPoint not available in this environment.</div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div>
                  <div className="font-mono text-sm">Matrix (2D components)</div>
                  <pre className="font-mono text-sm">{JSON.stringify(geom.matrix, null, 2)}</pre>
                </div>
                <div>
                  <div className="font-mono text-sm">Point transform</div>
                  <pre className="font-mono text-sm">{JSON.stringify({ from: geom.point, to: geom.transformed }, null, 2)}</pre>
                </div>
              </div>
            )}
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
