import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const OverflowPage: React.FC = () => {
  const longText = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. '.repeat(6);
  const content = (
    <div className="w-60">
      {longText}
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Overflow</h1>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-4">
            <div className="font-medium text-fg-primary">overflow: hidden</div>
            <div className="text-sm text-fg-secondary mb-2">Content clipped, no scrollbars.</div>
            <div className="flex gap-3 flex-wrap">
              <div className="w-40 h-24 border border-dashed border-line rounded bg-surface overflow-hidden">{content}</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-4">
            <div className="font-medium text-fg-primary">overflow: auto</div>
            <div className="text-sm text-fg-secondary mb-2">Scrollbars appear when needed.</div>
            <div className="flex gap-3 flex-wrap">
              <div className="w-40 h-24 border border-dashed border-line rounded bg-surface overflow-auto">{content}</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="font-medium text-fg-primary">overflow: scroll</div>
            <div className="text-sm text-fg-secondary mb-2">Scrollbars are always shown.</div>
            <div className="flex gap-3 flex-wrap">
              <div className="w-40 h-24 border border-dashed border-line rounded bg-surface overflow-scroll">{content}</div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
