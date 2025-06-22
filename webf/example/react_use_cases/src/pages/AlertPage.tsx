import React, { useRef } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './AlertPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

const FlutterCupertinoButton = createComponent({
  tagName: 'flutter-cupertino-button',
  displayName: 'FlutterCupertinoButton'
});

const FlutterCupertinoAlert = createComponent({
  tagName: 'flutter-cupertino-alert',
  displayName: 'FlutterCupertinoAlert',
  events: {
    onCancel: 'cancel',
    onConfirm: 'confirm'
  }
});

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
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Alert</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Usage */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Usage</div>
              <FlutterCupertinoButton variant="filled" onClick={showBasicAlert}>
                Show Basic Alert
              </FlutterCupertinoButton>
            </div>

            {/* With Title and Buttons */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>With Title and Buttons</div>
              <FlutterCupertinoButton variant="filled" onClick={showConfirmAlert}>
                Show Confirm Alert
              </FlutterCupertinoButton>
            </div>

            {/* With Title and Message */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>With Title and Message</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomAlert}>
                Show Title and Message
              </FlutterCupertinoButton>
            </div>

            {/* Destructive Action */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Destructive Action</div>
              <FlutterCupertinoButton variant="filled" onClick={showDestructiveAlert}>
                Show Destructive Alert
              </FlutterCupertinoButton>
            </div>

            {/* Default Button */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Default Button</div>
              <FlutterCupertinoButton variant="filled" onClick={showDefaultButtonAlert}>
                Show Default Button Alert
              </FlutterCupertinoButton>
            </div>
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