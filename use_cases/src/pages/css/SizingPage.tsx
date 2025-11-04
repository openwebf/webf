import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const SizingPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Sizing</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Width / Height</h2>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 120, height: 60 }}>120x60px</div>
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 180, height: 80 }}>180x80px</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Min / Max</h2>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: '30%', minWidth: 120 }}>30% min 120px</div>
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: '50%', maxWidth: 200 }}>50% max 200px</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-2">box-sizing</h2>
            <div className="flex gap-4 flex-wrap items-start">
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 120, padding: 16, borderWidth: 8, boxSizing: 'content-box' }}>content-box</div>
              <div className="bg-gray-100 border border-line rounded p-2 text-fg-secondary" style={{ width: 120, padding: 16, borderWidth: 8, boxSizing: 'border-box' }}>border-box</div>
            </div>
            <div className="text-sm text-fg-secondary mt-2">Both boxes set width: 120px; note overall size difference.</div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
