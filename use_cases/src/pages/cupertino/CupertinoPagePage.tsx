import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const CupertinoPagePage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Page</h1>
          <p className="text-fg-secondary mb-6">Navigator 2.0 compatible Cupertino page.</p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line">
            <p className="text-fg-secondary">Coming soon...</p>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};

