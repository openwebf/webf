import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './ClipPathPage.module.css';

export const ClipPathPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={`${styles.list} ${styles.container}`}>
          <div className={styles.clipShape}>
            <div className={styles.text}>
              WEBF
            </div>
          </div>
      </WebFListView>
    </div>
  );
};