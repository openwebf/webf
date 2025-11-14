import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const CupertinoPageTransitionPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Page Transition</h1>
          <p className="text-fg-secondary mb-6">Page transition animations and gestures.</p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line">
            <p className="text-fg-secondary">Coming soon...</p>
          </div>
      </WebFListView>
    </div>
  );
};

