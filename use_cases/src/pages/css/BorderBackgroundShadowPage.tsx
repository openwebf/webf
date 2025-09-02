import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BorderBackgroundShadowPage.module.css';

export const BorderBackgroundShadowPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.container}>
          <div className={styles.combinedShape}>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};