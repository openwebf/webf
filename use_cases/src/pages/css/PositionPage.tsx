import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const PositionPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">relative + absolute</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="relative h-36 border border-dashed border-line bg-surface rounded">
              <div className="absolute w-20 h-10 bg-blue-200 rounded flex items-center justify-center" style={{ left: 8, top: 8 }}>TL</div>
              <div className="absolute w-20 h-10 bg-blue-200 rounded flex items-center justify-center" style={{ right: 8, top: 8 }}>TR</div>
              <div className="absolute w-20 h-10 bg-blue-200 rounded flex items-center justify-center" style={{ left: 8, bottom: 8 }}>BL</div>
              <div className="absolute w-20 h-10 bg-blue-200 rounded flex items-center justify-center" style={{ right: 8, bottom: 8 }}>BR</div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">position: sticky</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="h-44 overflow-auto border border-dashed border-line rounded bg-surface">
              <div className="sticky top-0 bg-red-200 p-2 border-b border-line">Sticky Header</div>
              <div className="h-80 p-2 text-fg-secondary">
                Scroll inside this container to see the sticky header.
                <br/>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur gravida eu velit vitae faucibus.
                <br/>Mauris fermentum, ligula vitae ultricies posuere, turpis libero dictum erat, a congue massa nisi id arcu.
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
