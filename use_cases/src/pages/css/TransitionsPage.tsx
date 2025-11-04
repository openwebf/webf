import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const TransitionsPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Transitions</h1>
          <div className="flex gap-4 flex-wrap">
            <div className="bg-surface-secondary border border-line rounded-xl p-4 w-full md:w-[280px]">
              <div className="w-20 h-20 bg-blue-300 rounded transition-[transform,background-color] duration-300 ease-in-out hover:-translate-y-2 hover:scale-105 hover:bg-blue-400" />
              <div className="text-sm text-fg-secondary mt-2">Hover the square to see transform and color transitions.</div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
