import React, { useRef } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton, FlutterCupertinoAlert } from '@openwebf/react-cupertino-ui';
// Tailwind migration: replaced module CSS with utilities

export const AlertPage: React.FC = () => {
  const basicAlertRef = useRef<any>(null);
  const confirmAlertRef = useRef<any>(null);
  const customAlertRef = useRef<any>(null);
  const destructiveAlertRef = useRef<any>(null);
  const defaultButtonAlertRef = useRef<any>(null);

  const showBasicAlert = () => {
    basicAlertRef.current?.show();
  };

  const showConfirmAlert = () => {
    confirmAlertRef.current?.show();
  };

  const showCustomAlert = () => {
    customAlertRef.current?.show();
  };

  const showDestructiveAlert = () => {
    destructiveAlertRef.current?.show();
  };

  const showDefaultButtonAlert = () => {
    defaultButtonAlertRef.current?.show();
  };

  const onCancel = () => {
    console.log('Operation cancelled');
  };

  const onConfirm = () => {
    console.log('Operation confirmed');
  };

  const onDelete = () => {
    console.log('Executing delete operation');
  };

  const onLater = () => {
    console.log('Postponed');
  };

  const onUpdate = () => {
    console.log('Executing update operation');
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Alert</h1>
          <div className="flex flex-col gap-4">
            
            {/* Basic Usage */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Basic Usage</div>
              <FlutterCupertinoButton variant="filled" onClick={showBasicAlert}>
                Show Basic Alert
              </FlutterCupertinoButton>
            </div>

            {/* With Title and Buttons */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">With Title and Buttons</div>
              <FlutterCupertinoButton variant="filled" onClick={showConfirmAlert}>
                Show Confirm Alert
              </FlutterCupertinoButton>
            </div>

            {/* With Title and Message */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">With Title and Message</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomAlert}>
                Show Title and Message
              </FlutterCupertinoButton>
            </div>

            {/* Destructive Action */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Destructive Action</div>
              <FlutterCupertinoButton variant="filled" onClick={showDestructiveAlert}>
                Show Destructive Alert
              </FlutterCupertinoButton>
            </div>

            {/* Default Button */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Default Button</div>
              <FlutterCupertinoButton variant="filled" onClick={showDefaultButtonAlert}>
                Show Default Button Alert
              </FlutterCupertinoButton>
            </div>
          </div>
      </WebFListView>

      {/* Alert Components */}
      <FlutterCupertinoAlert
        ref={basicAlertRef}
        title="This is a Basic Alert"
        confirmText="Got it"
      />

      <FlutterCupertinoAlert 
        ref={confirmAlertRef}
        title="Are you sure you want to proceed?"
        cancelText="Cancel"
        confirmText="Confirm"
        onCancel={onCancel}
        onConfirm={onConfirm}
      />

      <FlutterCupertinoAlert 
        ref={customAlertRef}
        title="Operation Notice"
        message="This is an important notice, please read carefully"
        confirmText="Got it"
      />

      <FlutterCupertinoAlert
        ref={destructiveAlertRef}
        title="Delete Confirmation"
        message="Data cannot be recovered after deletion. Do you want to continue?"
        cancelText="Cancel"
        confirmText="Delete"
        confirmDestructive="true"
        onCancel={onCancel}
        onConfirm={onDelete}
      />

      <FlutterCupertinoAlert
        ref={defaultButtonAlertRef}
        title="Choose Action"
        message="Please select the action to perform"
        cancelText="Later"
        confirmText="Update Now"
        cancelDefault="true"
        onCancel={onLater}
        onConfirm={onUpdate}
      />
    </div>
  );
};
