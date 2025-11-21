import React, { useRef } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton, FlutterCupertinoActionSheet } from '@openwebf/react-cupertino-ui';
// Tailwind migration

export const ActionSheetPage: React.FC = () => {
  const basicActionSheetRef = useRef<any>(null);
  const destructiveActionSheetRef = useRef<any>(null);
  const customActionSheetRef = useRef<any>(null);
  const longListActionSheetRef = useRef<any>(null);

  const showBasicActionSheet = () => {
    basicActionSheetRef.current?.show({
      title: 'Choose an Option',
      message: 'Select one of the options below',
      actions: [
        { text: 'Option 1', event: 'action', value: 'option1' },
        { text: 'Option 2', event: 'action', value: 'option2' },
        { text: 'Option 3', event: 'action', value: 'option3' },
      ],
      cancelButton: { text: 'Cancel', event: 'cancel' }
    });
  };

  const showDestructiveActionSheet = () => {
    destructiveActionSheetRef.current?.show({
      title: 'Delete Item',
      message: 'This action cannot be undone',
      actions: [
        { text: 'Edit Item', event: 'action', value: 'edit' },
        { text: 'Duplicate Item', event: 'action', value: 'duplicate' },
        { text: 'Delete Item', event: 'action', value: 'delete', isDestructive: true },
      ],
      cancelButton: { text: 'Cancel', event: 'cancel' }
    });
  };

  const showCustomActionSheet = () => {
    customActionSheetRef.current?.show({
      title: 'Share Options',
      actions: [
        { text: 'Copy Link', event: 'action', value: 'copy', icon: 'doc_on_doc' },
        { text: 'Send via Email', event: 'action', value: 'email', icon: 'mail' },
        { text: 'Send via Message', event: 'action', value: 'message', icon: 'message' },
        { text: 'Share on Social Media', event: 'action', value: 'social', icon: 'share' },
      ],
      cancelButton: { text: 'Cancel', event: 'cancel' }
    });
  };

  const showLongListActionSheet = () => {
    longListActionSheetRef.current?.show({
      title: 'Select Country',
      message: 'Choose your country from the list',
      actions: [
        { text: 'United States', event: 'action', value: 'us' },
        { text: 'United Kingdom', event: 'action', value: 'uk' },
        { text: 'Canada', event: 'action', value: 'ca' },
        { text: 'Australia', event: 'action', value: 'au' },
        { text: 'Germany', event: 'action', value: 'de' },
        { text: 'France', event: 'action', value: 'fr' },
        { text: 'Italy', event: 'action', value: 'it' },
        { text: 'Spain', event: 'action', value: 'es' },
        { text: 'Japan', event: 'action', value: 'jp' },
        { text: 'South Korea', event: 'action', value: 'kr' },
        { text: 'China', event: 'action', value: 'cn' },
        { text: 'India', event: 'action', value: 'in' },
      ],
      cancelButton: { text: 'Cancel', event: 'cancel' }
    });
  };

  const handleAction = (event: any) => {
    console.log('Action selected:', event.detail);
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Action Sheet Showcase</h1>
          <div className="flex flex-col gap-4">
            
            {/* Basic Action Sheet */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Basic Action Sheet</div>
              <div className="text-sm text-fg-secondary mb-3">Simple action sheet with multiple options and cancel button</div>
              <div className="bg-surface border border-line rounded p-3">
                <FlutterCupertinoButton variant="filled" onClick={showBasicActionSheet}>
                  Show Basic Action Sheet
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={basicActionSheetRef}
                  onSelect={handleAction}
                />
              </div>
            </div>

            {/* Destructive Action Sheet */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Destructive Action Sheet</div>
              <div className="text-sm text-fg-secondary mb-3">Action sheet with destructive actions highlighted in red</div>
              <div className="bg-surface border border-line rounded p-3">
                <FlutterCupertinoButton variant="filled" onClick={showDestructiveActionSheet}>
                  Show Destructive Actions
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={destructiveActionSheetRef}
                  onSelect={handleAction}
                />
              </div>
            </div>

            {/* Custom Action Sheet */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Custom Action Sheet</div>
              <div className="text-sm text-fg-secondary mb-3">Action sheet with icons and custom styling</div>
              <div className="bg-surface border border-line rounded p-3">
                <FlutterCupertinoButton variant="filled" onClick={showCustomActionSheet}>
                  Show Custom Action Sheet
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={customActionSheetRef}
                  onSelect={handleAction}
                />
              </div>
            </div>

            {/* Long List Action Sheet */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Long List Action Sheet</div>
              <div className="text-sm text-fg-secondary mb-3">Action sheet with many options that can scroll</div>
              <div className="bg-surface border border-line rounded p-3">
                <FlutterCupertinoButton variant="filled" onClick={showLongListActionSheet}>
                  Show Long List
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={longListActionSheetRef}
                  onSelect={handleAction}
                />
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
