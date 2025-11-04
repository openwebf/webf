import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DisplayFlowPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Display: block / inline / inline-block</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="flex gap-3 flex-wrap items-start">
              <div className="block w-40 p-2 bg-gray-200 border border-line rounded">block element</div>
              <span className="inline px-2 py-1 bg-emerald-100 border border-line rounded">inline element A</span>
              <span className="inline px-2 py-1 bg-emerald-100 border border-line rounded">inline element B</span>
              <div className="inline-block w-[120px] p-2 bg-amber-200 border border-line rounded">inline-block 120px</div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Block Formatting Context (BFC)</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-sm text-fg-secondary mb-2">Overflow creates a new BFC, containing floats.</div>
            <div className="overflow-hidden border border-dashed border-line rounded p-2 w-[220px] bg-surface">
              <div className="float-left w-20 h-12 bg-blue-300 rounded m-1" />
              <div className="float-left w-20 h-12 bg-blue-300 rounded m-1" />
              <div className="float-left w-20 h-12 bg-blue-300 rounded m-1" />
              <div className="text-sm text-fg-secondary clear-both">Text wraps around floats but stays contained.</div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
