import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BorderRadiusPage.module.css';

export const BorderRadiusPage: React.FC = () => {
  const radiusStyles = [
    ["2em", "2em / 5em"],
    ["2em 1em 4em / 0.5em 3em", "15px 50px"],
    ["15px 50px 30px 5px", "1em 2em 4em 4em / 1em 2em 2em 8em"],
    ["100px 200px", "100px 30px / 10px"],
    ["100em / 200em", "2px 0px 2em / 0em 100px"],
  ];

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.fixedArea}>
          {radiusStyles.map((styleGroup, index) => (
            <div key={index}>
              <div className={styles.row}>
                {styleGroup.map((item, idx) => (
                  <div
                    key={idx}
                    className={`${styles.box} ${styles.size0} ${styles[`styleDiff${idx}`]} ${styles.colorWidthSame}`}
                    style={{ borderRadius: item }}
                  >
                    <div className={styles.text}></div>
                  </div>
                ))}
              </div>
            </div>
          ))}

          {radiusStyles.map((styleGroup, index) => (
            <div key={index}>
              <div className={styles.row}>
                {styleGroup.map((item, idx) => (
                  <div
                    key={idx}
                    className={`${styles.box} ${styles.size0} ${styles[`colorWidthDiff${idx}`]}`}
                    style={{ borderRadius: item }}
                  >
                    <div className={styles.text}></div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </WebFListView>
    </div>
  );
};