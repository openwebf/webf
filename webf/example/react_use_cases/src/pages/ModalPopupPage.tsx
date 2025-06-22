import React, { useRef } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './ModalPopupPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

const FlutterCupertinoButton = createComponent({
  tagName: 'flutter-cupertino-button',
  displayName: 'FlutterCupertinoButton'
});

const FlutterCupertinoModalPopup = createComponent({
  tagName: 'flutter-cupertino-modal-popup',
  displayName: 'FlutterCupertinoModalPopup',
  events: {
    onClose: 'close'
  }
});

export const ModalPopupPage: React.FC = () => {
  const basicPopupRef = useRef<any>(null);
  const customPopupRef = useRef<any>(null);
  const heightPopupRef = useRef<any>(null);
  const noMaskClosePopupRef = useRef<any>(null);
  const customStylePopupRef = useRef<any>(null);

  const shareItems = [
    { icon: 'pencil', label: 'Message' },
    { icon: 'mail_fill', label: 'Email' },
    { icon: 'link', label: 'Copy Link' },
    { icon: 'share', label: 'More' },
  ];

  const showBasicPopup = () => {
    basicPopupRef.current?.show();
  };

  const showCustomPopup = () => {
    customPopupRef.current?.show();
  };

  const showHeightPopup = () => {
    heightPopupRef.current?.show();
  };

  const showNoMaskClosePopup = () => {
    noMaskClosePopupRef.current?.show();
  };

  const hideNoMaskClosePopup = () => {
    noMaskClosePopupRef.current?.hide();
  };

  const showCustomStylePopup = () => {
    customStylePopupRef.current?.show();
  };

  const onPopupClose = () => {
    console.log('Popup closed');
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Modal Popup</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Usage */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Usage</div>
              <FlutterCupertinoButton variant="filled" onClick={showBasicPopup}>
                Show Basic Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Content */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Content</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomPopup}>
                Show Custom Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Height */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Height</div>
              <FlutterCupertinoButton variant="filled" onClick={showHeightPopup}>
                Show 400px Height Popup
              </FlutterCupertinoButton>
            </div>

            {/* Disable Mask Close */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Disable Mask Close</div>
              <FlutterCupertinoButton variant="filled" onClick={showNoMaskClosePopup}>
                Show Non-maskClosable Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Style */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Style</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomStylePopup}>
                Show Custom Style Popup
              </FlutterCupertinoButton>
            </div>
          </div>
        </div>

        {/* Basic Popup */}
        <FlutterCupertinoModalPopup
          ref={basicPopupRef}
          height="200"
          onClose={onPopupClose}
        >
          <div className={styles.popupContent}>
            <div className={styles.popupTitle}>Basic Popup</div>
            <div className={styles.popupText}>This is a basic popup example</div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* Custom Popup */}
        <FlutterCupertinoModalPopup
          ref={customPopupRef}
          height="300"
          onClose={onPopupClose}
        >
          <div className={styles.popupContent}>
            <div className={styles.popupTitle}>Share to</div>
            <div className={styles.shareGrid}>
              {shareItems.map((item) => (
                <div key={item.icon} className={styles.shareItem}>
                  <div className={styles.shareLabel}>{item.label}</div>
                </div>
              ))}
            </div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* Height Popup */}
        <FlutterCupertinoModalPopup
          ref={heightPopupRef}
          height="400"
          onClose={onPopupClose}
        >
          <div className={styles.popupContent}>
            <div className={styles.popupTitle}>Custom Height</div>
            <div className={styles.popupText}>This popup has a height of 400px</div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* No Mask Close Popup */}
        <FlutterCupertinoModalPopup
          ref={noMaskClosePopupRef}
          height="250"
          maskClosable="false"
          backgroundOpacity="0.6"
          onClose={onPopupClose}
        >
          <div className={styles.popupContent}>
            <div className={styles.popupTitle}>Disable Mask Close</div>
            <div className={styles.popupText}>
              This popup has disabled mask close functionality, can only be closed by other means
            </div>
            <div className={styles.popupFooter}>
              <FlutterCupertinoButton variant="filled" onClick={hideNoMaskClosePopup}>
                Close
              </FlutterCupertinoButton>
            </div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* Custom Style Popup */}
        <FlutterCupertinoModalPopup
          ref={customStylePopupRef}
          height="250"
          surfacePainted="false"
          backgroundOpacity="0.2"
          onClose={onPopupClose}
        >
          <div className={`${styles.popupContent} ${styles.customStyle}`}>
            <div className={styles.popupTitle}>Custom Style</div>
            <div className={styles.popupText}>
              This is a custom styled popup example with disabled background and semi-transparent mask
            </div>
          </div>
        </FlutterCupertinoModalPopup>
      </WebFListView>
    </div>
  );
};