import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DisplayFlowPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Display: block / inline / inline-block</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="flex gap-3 flex-wrap items-start">
              <div className="block w-40 p-2 bg-gray-200 border border-line rounded">block element</div>
              <span className="inline px-2 py-1 bg-emerald-100 border border-line rounded">inline element A</span>
              <span className="inline px-2 py-1 bg-emerald-100 border border-line rounded">inline element B</span>
              <div className="inline-block w-[120px] p-2 bg-amber-200 border border-line rounded">inline-block 120px</div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Other display values</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Common value beyond the basics: none (hidden).</div>
            {/* none */}
            <div className="border border-dashed border-line rounded p-3">
              <div className="flex items-center gap-2">
                <div className="px-2 py-1 rounded border border-line bg-rose-100">visible</div>
                <div className="hidden px-2 py-1 rounded border border-line bg-rose-100">hidden (display: none)</div>
                <div className="text-sm text-fg-secondary">The hidden box does not affect layout.</div>
              </div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Margin collapsing</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Adjacent vertical margins collapse into a single margin. Adding padding/border or creating a BFC prevents collapse.</div>
            <div className="grid md:grid-cols-2 gap-4">
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-sm text-fg-secondary">Siblings with collapsing margins</div>
                <div className="bg-amber-100 border border-line rounded mt-4 mb-6 p-2">A (mt-4, mb-6)</div>
                <div className="bg-amber-100 border border-line rounded mt-6 p-2">B (mt-6)</div>
                <div className="text-xs text-fg-secondary mt-2">mt-6 and mb-6 between A/B collapse to 6</div>
              </div>
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-sm text-fg-secondary">Prevented by padding on parent</div>
                <div className="p-1 border border-line rounded">
                  <div className="bg-emerald-100 border border-line rounded mt-4 mb-6 p-2">A (mt-4, mb-6)</div>
                  <div className="bg-emerald-100 border border-line rounded mt-6 p-2">B (mt-6)</div>
                </div>
                <div className="text-xs text-fg-secondary mt-2">Padding creates separation; margins no longer collapse</div>
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
