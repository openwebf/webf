import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BGRadialPage.module.css';

export const BGRadialPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.fixedArea}>
          <div className={`${styles.container} ${styles.radialGradient1}`}></div>
          <div className={`${styles.container} ${styles.radialGradient2}`}></div>
          <div className={`${styles.container} ${styles.radialGradient3}`}></div>
          <div className={`${styles.container} ${styles.radialGradient4}`}></div>
          <div className={`${styles.container} ${styles.radialGradient5}`}></div>
          <div className={`${styles.container} ${styles.radialGradient6}`}></div>
          <div className={`${styles.container} ${styles.radialGradient7}`}></div>
        </div>
      </WebFListView>
    </div>
  );
};