import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BGGradientPage.module.css';

export const BGGradientPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.fixedArea}>
          <div className={styles.container}>
            <div
              style={{
                width: "50%",
                backgroundImage: "linear-gradient(red, yellow)",
              }}
              className={styles.gradientBox}
            >
            </div>
          </div>

          <div className={styles.container}>
            <div
              style={{
                width: "50%",
                backgroundImage: "linear-gradient(green 40%, yellow 30%, blue 70%)",
              }}
              className={styles.gradientBox}
            />
            <div
              style={{
                width: "50%",
                backgroundImage: "linear-gradient(green 40%, yellow 40%, blue 70%)",
              }}
              className={styles.gradientBox}
            />
          </div>

          <div className={styles.container}>
            <div
              style={{
                width: "50%",
                backgroundImage: "radial-gradient(red, green)",
              }}
              className={styles.gradientBox}
            />
            <div
              style={{
                width: "50%",
                backgroundImage: "radial-gradient(circle at 100%, #333, #333 50%, #eee 75%, #333 75%)",
              }}
              className={styles.gradientBox}
            />
          </div>
        </div>
      </WebFListView>
    </div>
  );
};