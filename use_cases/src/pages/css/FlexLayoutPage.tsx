import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './FlexLayoutPage.module.css';

export const FlexLayoutPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.wrapper}>
          <div className={`${styles.headerTitle} ${styles.colorWidth}`}>
            Flex layout
          </div>
          <div className={styles.main}>
            The flexible box layout module (usually referred to as flexbox) is a one-dimensional layout model for
            distributing space between items and includes numerous alignment capabilities. This article gives an outline
            of the main features of flexbox, which we will explore in more detail in the rest of these guides.
          </div>
          <div className={`${styles.aside} ${styles.aside1}`}>
            flex: 1 0 0
          </div>
          <div className={`${styles.aside} ${styles.aside2}`}>
            flex: 2 0 0
          </div>
          <div className={styles.footer}>
            Footer -- flex: 1 100%
          </div>
        </div>
      </WebFListView>
    </div>
  );
};