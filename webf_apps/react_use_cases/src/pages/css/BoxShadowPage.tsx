import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BoxShadowPage.module.css';

export const BoxShadowPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div style={{ width: "100%", height: "100%", flexDirection: "column" }}>
          <div className={styles.example}>
            <div className={styles.box2}>
              <div>shadow</div>
            </div>
            <div className={styles.box3}>
              <div></div>
            </div>
          </div>

          <div className={styles.example}>
            <div className={`${styles.box} ${styles.shadowAi}`}>
              <div>ai</div>
            </div>
            <div className={`${styles.box} ${styles.shadowBi}`}>
              <div>bi</div>
            </div>
            <div className={`${styles.box} ${styles.shadowCi}`}>
              <div>ci</div>
            </div>
          </div>

          <div className={styles.example}>
            <div className={`${styles.box} ${styles.radius} ${styles.shadowDi}`}>
              <div>di</div>
            </div>
            <div className={`${styles.box} ${styles.radius} ${styles.shadowEi}`}>
              <div>ei</div>
            </div>
            <div className={`${styles.box} ${styles.radius} ${styles.shadowFi}`}>
              <div>fi</div>
            </div>
          </div>

          <div className={styles.example}>
            <div className={`${styles.box} ${styles.radius2} ${styles.shadowAi}`}>
              <div>ai</div>
            </div>
            <div className={`${styles.box} ${styles.radius2} ${styles.shadowBi}`}>
              <div>bi</div>
            </div>
            <div className={`${styles.box} ${styles.radius2} ${styles.shadowCi}`}>
              <div>ci</div>
            </div>
          </div>

          <div className={styles.example}>
            <div className={`${styles.box} ${styles.shadowA}`}>
              <div>a</div>
            </div>
            <div className={`${styles.box} ${styles.shadowB}`}>
              <div>b</div>
            </div>
            <div className={`${styles.box} ${styles.shadowC}`}>
              <div>c</div>
            </div>
          </div>

          <div className={styles.example}>
            <div className={`${styles.box} ${styles.radius} ${styles.shadowD}`}>
              <div>d</div>
            </div>
            <div className={`${styles.box} ${styles.radius} ${styles.shadowE}`}>
              <div>e</div>
            </div>
            <div className={`${styles.box} ${styles.radius} ${styles.shadowF}`}>
              <div>f</div>
            </div>
          </div>

          <div className={styles.example}>
            <div className={`${styles.box} ${styles.radius2} ${styles.shadowA}`}>
              <div>a</div>
            </div>
            <div className={`${styles.box} ${styles.radius2} ${styles.shadowB}`}>
              <div>b</div>
            </div>
            <div className={`${styles.box} ${styles.radius2} ${styles.shadowC}`}>
              <div>c</div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};