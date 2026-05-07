import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';
import { showGlobalModal } from '../../hooks/useGlobalModal';
import { WebFRouter } from '../../router';

export const ProfileSubPage: React.FC = () => {
  return (
    <div className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">Profile</h1>

        <div className="flex flex-col items-center gap-3 mb-6">
          <div className="w-20 h-20 rounded-full bg-blue-500 flex items-center justify-center">
            <span className="text-white text-3xl font-bold">U</span>
          </div>
          <div className="text-lg font-medium text-fg-primary">User Name</div>
          <div className="text-sm text-fg-secondary">user@example.com</div>
        </div>

        <div className="flex flex-col gap-4">
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="text-sm text-fg-secondary">Member since: Jan 2024</div>
            <div className="text-sm text-fg-secondary">Plan: Pro</div>
          </div>

          <FlutterCupertinoButton variant="filled" onClick={() => showGlobalModal('Edit Profile', 'Name: User Name\nEmail: user@example.com\nPlan: Pro\nMember since: Jan 2024\n\nTap outside or close to dismiss.')}>
            Edit Profile (Show Modal)
          </FlutterCupertinoButton>

          <FlutterCupertinoButton variant="tinted" onClick={() => WebFRouter.pop()}>
            Back to Global Modal Demo
          </FlutterCupertinoButton>
        </div>
      </WebFListView>
    </div>
  );
};
