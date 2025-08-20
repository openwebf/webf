import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BorderPage.module.css';

export const BorderPage: React.FC = () => {
  const borderStyles = [
    ["thick double red", "thin dotted blue"],
    ["10px solid orange", "medium solid #0000ff"],
    ["5px groove rgba(0,255,0,0.6)", "10rpx ridge hsl(89,43%,51%)"],
    ["thick outset hsla(89,43%,51%,0.3)", "16px inset #ab0"],
  ];

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div
          className={styles.fixedArea}
        >
          {borderStyles.map((styleGroup, index) => (
            <div key={index} className={styles.row}>
              {styleGroup.map((item, idx) => (
                <div key={idx} className={styles.box} style={{ border: item }}>
                  <div className={styles.text}></div>
                </div>
              ))}
            </div>
          ))}

          {borderStyles.map((styleGroup, index) => (
            <div key={index} className={styles.row}>
              {styleGroup.map((item, idx) => (
                <div
                  key={idx}
                  className={`${styles.box} ${styles[`radiusStyle${index}`]}`}
                  style={{ border: item }}
                >
                  <div className={styles.text}></div>
                </div>
              ))}
            </div>
          ))}
        </div>
      </WebFListView>
    </div>
  );
};