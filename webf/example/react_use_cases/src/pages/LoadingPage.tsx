import React, { useRef } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './LoadingPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

const FlutterCupertinoButton = createComponent({
  tagName: 'flutter-cupertino-button',
  displayName: 'FlutterCupertinoButton'
});

const FlutterCupertinoLoading = createComponent({
  tagName: 'flutter-cupertino-loading',
  displayName: 'FlutterCupertinoLoading',
  events: {
    onClose: 'close'
  }
});

export const LoadingPage: React.FC = () => {
  const basicLoadingRef = useRef<any>(null);
  const textLoadingRef = useRef<any>(null);
  const autoHideLoadingRef = useRef<any>(null);
  const maskClosableLoadingRef = useRef<any>(null);

  const showBasicLoading = () => {
    basicLoadingRef.current?.show();
    setTimeout(() => {
      basicLoadingRef.current?.hide();
    }, 1000);
  };

  const showLoadingWithText = () => {
    textLoadingRef.current?.show({
      text: 'Loading...'
    });
    setTimeout(() => {
      textLoadingRef.current?.hide();
    }, 1000);
  };

  const showAutoHideLoading = () => {
    autoHideLoadingRef.current?.show({
      text: 'Processing...'
    });
    setTimeout(() => {
      autoHideLoadingRef.current?.hide();
    }, 2000);
  };

  const showMaskClosableLoading = () => {
    maskClosableLoadingRef.current?.show({
      text: 'Click mask to close'
    });
  };

  const handleLoadingClose = () => {
    console.log('Loading closed by mask click');
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Loading</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Usage */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Usage</div>
              <FlutterCupertinoButton variant="filled" onClick={showBasicLoading}>
                Show Loading
              </FlutterCupertinoButton>
            </div>

            {/* With Text */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>With Text</div>
              <FlutterCupertinoButton variant="filled" onClick={showLoadingWithText}>
                Show Loading
              </FlutterCupertinoButton>
            </div>

            {/* Auto Hide */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Auto Hide</div>
              <FlutterCupertinoButton variant="filled" onClick={showAutoHideLoading}>
                Show Loading (Auto hide in 2s)
              </FlutterCupertinoButton>
            </div>

            {/* Mask Closable */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Mask Closable</div>
              <FlutterCupertinoButton variant="filled" onClick={showMaskClosableLoading}>
                Show Loading (Click mask to close)
              </FlutterCupertinoButton>
            </div>
          </div>
        </div>

        {/* Loading Components */}
        <FlutterCupertinoLoading ref={basicLoadingRef} />
        <FlutterCupertinoLoading ref={textLoadingRef} />
        <FlutterCupertinoLoading ref={autoHideLoadingRef} />
        <FlutterCupertinoLoading ref={maskClosableLoadingRef} maskClosable onClose={handleLoadingClose} />
      </WebFListView>
    </div>
  );
};