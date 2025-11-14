import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const SelectorsPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Selectors</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <style>{`
              .sel-item::before { content: '• '; color: #9ca3af; }
              .sel-grid [data-role="admin"] { background: #fee2e2; }
              .sel-item:hover { border-color: #60a5fa; }
              .sel-grid .sel-item:nth-child(2n) { background: #f3f4f6; }
              .sel-item::after { content: attr(data-label); float: right; color: #6b7280; font-size: 12px; }
            `}</style>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-2 sel-grid">
              <div className="sel-item p-2 rounded border border-line bg-surface" data-label=":hover">Hover me</div>
              <div className="sel-item p-2 rounded border border-line bg-surface" data-role="admin" data-label='[data-role="admin"]'>Admin</div>
              <div className="sel-item p-2 rounded border border-line bg-surface" data-label=":nth-child(2n)">Even</div>
              <div className="sel-item p-2 rounded border border-line bg-surface" data-label="::before/::after">Pseudo elements</div>
              <div className="sel-item p-2 rounded border border-line bg-surface" data-label="Combinators">Descendant</div>
              <div className="sel-item p-2 rounded border border-line bg-surface" data-label="Attr content">Attr</div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
