import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';
import { showGlobalModal } from '../../hooks/useGlobalModal';
import { WebFRouter } from '../../router';

export const HelpSubPage: React.FC = () => {
  return (
    <div className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">Help & Support</h1>

        <div className="flex flex-col gap-4">
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-base font-medium text-fg-primary mb-1">FAQ</div>
            <div className="text-sm text-fg-secondary">How do I use hybrid routing?</div>
            <div className="text-xs text-fg-tertiary mt-1">Use webf-router-link elements with path attributes.</div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-base font-medium text-fg-primary mb-1">What is webf-global-root?</div>
            <div className="text-sm text-fg-secondary">A special element whose content renders above all routes.</div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-base font-medium text-fg-primary mb-1">Documentation</div>
            <div className="text-sm text-fg-secondary">Visit openwebf.com for full docs.</div>
          </div>

          <FlutterCupertinoButton variant="filled" onClick={() => showGlobalModal('Contact Support', 'Email: support@openwebf.com\nDiscord: discord.gg/DvUBtXZ5rK\nGitHub: github.com/openwebf/webf\n\nWe typically respond within 24 hours.')}>
            Contact Support (Show Modal)
          </FlutterCupertinoButton>

          <FlutterCupertinoButton variant="tinted" onClick={() => WebFRouter.pop()}>
            Back to Global Modal Demo
          </FlutterCupertinoButton>
        </div>
      </WebFListView>
    </div>
  );
};
