import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const InlineFormattingPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Baseline alignment</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="flex items-baseline gap-3">
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 12 }}>12px</span>
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 16 }}>16px</span>
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 24 }}>24px</span>
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 32 }}>32px</span>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Line-height and inline formatting context</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <p className="leading-8 bg-amber-100 p-2 rounded">
              This paragraph has increased line-height to highlight line boxes.<br/>
              Inline content wraps and aligns along baseline by default.
            </p>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">vertical-align</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="flex items-center gap-3">
              <div className="w-[60px] h-10 bg-emerald-200" style={{ verticalAlign: 'baseline' }} />
              <span className="text-sm text-fg-secondary">baseline</span>
            </div>
            <div className="flex items-center gap-3 mt-2">
              <div className="inline-block w-[60px] h-10 bg-emerald-200 align-middle" />
              <span className="text-sm text-fg-secondary">middle</span>
            </div>
            <div className="flex items-center gap-3 mt-2">
              <div className="inline-block w-[60px] h-10 bg-emerald-200 align-top" />
              <span className="text-sm text-fg-secondary">top</span>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
