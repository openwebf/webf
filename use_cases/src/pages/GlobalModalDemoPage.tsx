import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';
import { showGlobalModal } from '../hooks/useGlobalModal';
import { WebFRouter } from '../router';

export const GlobalModalDemoPage: React.FC = () => {
  return (
    <div className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">Global Modal Demo</h1>
        <p className="text-sm text-fg-secondary mb-6">
          The modal renders inside &lt;webf-global-root&gt; and stays visible across all sub-routes.
        </p>

        <div className="flex flex-col gap-4">
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-lg font-medium text-fg-primary mb-2">Test from this page</div>
            <FlutterCupertinoButton variant="filled" onClick={() => showGlobalModal('Root Page Modal', 'This modal was triggered from the root /global-modal page.')}>
              Show Modal Here
            </FlutterCupertinoButton>
          </div>

          <div className="text-lg font-medium text-fg-primary mt-4 mb-2">Navigate to sub-routes:</div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-base font-medium text-fg-primary mb-1">Settings Page</div>
            <div className="text-sm text-fg-secondary mb-3">Has its own modal content</div>
            <FlutterCupertinoButton variant="tinted" onClick={() => WebFRouter.pushState({}, '/global-modal/settings')}>
              Go to Settings
            </FlutterCupertinoButton>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-base font-medium text-fg-primary mb-1">Profile Page</div>
            <div className="text-sm text-fg-secondary mb-3">Has its own modal content</div>
            <FlutterCupertinoButton variant="tinted" onClick={() => WebFRouter.pushState({}, '/global-modal/profile')}>
              Go to Profile
            </FlutterCupertinoButton>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-base font-medium text-fg-primary mb-1">Help Page</div>
            <div className="text-sm text-fg-secondary mb-3">Has its own modal content</div>
            <FlutterCupertinoButton variant="tinted" onClick={() => WebFRouter.pushState({}, '/global-modal/help')}>
              Go to Help
            </FlutterCupertinoButton>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
