import React, { useRef } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './ActionSheetPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

const FlutterCupertinoButton = createComponent({
  tagName: 'flutter-cupertino-button',
  displayName: 'FlutterCupertinoButton'
});

const FlutterCupertinoActionSheet = createComponent({
  tagName: 'flutter-cupertino-action-sheet',
  displayName: 'FlutterCupertinoActionSheet',
  events: {
    onAction: 'action',
    onCancel: 'cancel'
  }
});


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

  const handleCancel = () => {
    console.log('Action sheet cancelled');
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Action Sheet Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Action Sheet */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Action Sheet</div>
              <div className={styles.itemDesc}>Simple action sheet with multiple options and cancel button</div>
              <div className={styles.actionContainer}>
                <FlutterCupertinoButton variant="filled" onClick={showBasicActionSheet}>
                  Show Basic Action Sheet
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={basicActionSheetRef}
                  onAction={handleAction}
                  onCancel={handleCancel}
                />
              </div>
            </div>

            {/* Destructive Action Sheet */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Destructive Action Sheet</div>
              <div className={styles.itemDesc}>Action sheet with destructive actions highlighted in red</div>
              <div className={styles.actionContainer}>
                <FlutterCupertinoButton variant="filled" onClick={showDestructiveActionSheet}>
                  Show Destructive Actions
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={destructiveActionSheetRef}
                  onAction={handleAction}
                  onCancel={handleCancel}
                />
              </div>
            </div>

            {/* Custom Action Sheet */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Action Sheet</div>
              <div className={styles.itemDesc}>Action sheet with icons and custom styling</div>
              <div className={styles.actionContainer}>
                <FlutterCupertinoButton variant="filled" onClick={showCustomActionSheet}>
                  Show Custom Action Sheet
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={customActionSheetRef}
                  onAction={handleAction}
                  onCancel={handleCancel}
                />
              </div>
            </div>

            {/* Long List Action Sheet */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Long List Action Sheet</div>
              <div className={styles.itemDesc}>Action sheet with many options that can scroll</div>
              <div className={styles.actionContainer}>
                <FlutterCupertinoButton variant="filled" onClick={showLongListActionSheet}>
                  Show Long List
                </FlutterCupertinoButton>
                
                <FlutterCupertinoActionSheet 
                  ref={longListActionSheetRef}
                  onAction={handleAction}
                  onCancel={handleCancel}
                />
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};