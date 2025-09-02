import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './FilterPage.module.css';

export const FilterPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.container}>
          <div className={styles.grey}>
            <div
              style={{
                backgroundImage: "linear-gradient(black,pink)",
                width: "300px",
                height: "300px",
              }}
            />
          </div>
        </div>
      </WebFListView>
    </div>
  );
};