import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton, FlutterCupertinoSwitch } from '@openwebf/react-cupertino-ui';
import { showGlobalModal } from '../../hooks/useGlobalModal';
import { WebFRouter } from '../../router';

export const SettingsSubPage: React.FC = () => {
  return (
    <div className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">Settings</h1>

        <div className="flex flex-col gap-4">
          <div className="bg-surface-secondary border border-line rounded-xl p-4 flex items-center justify-between">
            <div className="text-base text-fg-primary">Dark Mode</div>
            <FlutterCupertinoSwitch />
          </div>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 flex items-center justify-between">
            <div className="text-base text-fg-primary">Notifications</div>
            <FlutterCupertinoSwitch />
          </div>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 flex items-center justify-between">
            <div className="text-base text-fg-primary">Auto-save</div>
            <FlutterCupertinoSwitch />
          </div>

          <FlutterCupertinoButton variant="filled" onClick={() => showGlobalModal('Settings Saved', 'All your settings have been saved successfully.\n\nDark Mode: ON\nNotifications: ON\nAuto-save: ON')}>
            Save & Show Modal
          </FlutterCupertinoButton>

          <FlutterCupertinoButton variant="tinted" onClick={() => WebFRouter.pop()}>
            Back to Global Modal Demo
          </FlutterCupertinoButton>
        </div>
      </WebFListView>
    </div>
  );
};
