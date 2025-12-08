import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BGImagePage.module.css';

export const BGImagePage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={`${styles.list} ${styles.fixedArea}`}>
          <div
            className={`${styles.container} ${styles.image1}`}
            style={{
              backgroundOrigin: "content-box",
              backgroundPosition: "left top",
              backgroundRepeat: "no-repeat",
            }}
          >
          </div>

          <div
            className={`${styles.container} ${styles.image1}`}
            style={{
              backgroundOrigin: "padding-box",
              backgroundPosition: "50% 50%",
              backgroundRepeat: "repeat-x",
            }}
          >
          </div>

          <div
            className={`${styles.container} ${styles.image1}`}
            style={{
              backgroundOrigin: "border-box",
              backgroundPosition: "30px 40px",
              backgroundRepeat: "repeat",
            }}
          >
          </div>

          <div
            className={`${styles.container} ${styles.image2}`}
            style={{
              backgroundOrigin: "content-box, border-box",
              backgroundPosition: "50% 40px, right bottom",
              backgroundRepeat: "repeat-y, repeat-x",
            }}
          >
          </div>
      </WebFListView>
    </div>
  );
};