import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './KeyframesPage.module.css';

export const KeyframesPage: React.FC = () => {
  const transProperties = ["translateX", "translateY", "translateZ"];
  const rotateProperties = ["rotateX", "rotateY", "rotateZ"];
  const scaleProperties = ["scaleX", "scaleY", "scaleXY"];
  const flipProperties = ["flipX", "flipY", "flipXY"];
  const otherProperties = ["background-color", "opacity"];

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        {/* Keyframes Animation Title */}
        <h2 className={styles.mainTitle}>keyframes animation</h2>
        <div className={styles.separator}></div>

        {/* Translate Animations */}
        <div className={styles.group}>
          <h3 className={styles.sectionTitle}>translate animation</h3>
          <div className={styles.animationRow}>
            {transProperties.map((item, index) => (
              <div key={index} className={styles.animationItem}>
                <div className={styles.animationLabel}>{item}</div>
                <div
                  className={`${styles.animationBox} ${styles[`${item}Animation`]}`}
                >
                  🦁
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className={styles.separator}></div>

        {/* Rotate Animations */}
        <div className={styles.group}>
          <h3 className={styles.sectionTitle}>rotate animation</h3>
          <div className={styles.animationRow}>
            {rotateProperties.map((item, index) => (
              <div key={index} className={styles.animationItem}>
                <div className={styles.animationLabel}>{item}</div>
                <div
                  className={`${styles.animationBox} ${styles[`${item}Animation`]}`}
                >
                  🦁
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className={styles.separator}></div>

        {/* Scale Animations */}
        <div className={styles.group}>
          <h3 className={styles.sectionTitle}>scale animation</h3>
          <div className={styles.animationRow}>
            {scaleProperties.map((item, index) => (
              <div key={index} className={styles.animationItem}>
                <div className={styles.animationLabel}>{item}</div>
                <div
                  className={`${styles.animationBox} ${styles[`${item}Animation`]}`}
                >
                  🦁
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className={styles.separator}></div>

        {/* Flip Animations */}
        <div className={styles.group}>
          <h3 className={styles.sectionTitle}>flip animation</h3>
          <div className={styles.animationRow}>
            {flipProperties.map((item, index) => (
              <div key={index} className={styles.animationItem}>
                <div className={styles.animationLabel}>{item}</div>
                <div
                  className={`${styles.animationBox} ${styles[`${item}Animation`]}`}
                >
                  🦁
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className={styles.separator}></div>

        {/* Background color and opacity Animations */}
        <div className={styles.group}>
          <h3 className={styles.sectionTitle}>bg-color opacity</h3>
          <div className={styles.animationRow}>
            {otherProperties.map((item, index) => (
              <div key={index} className={styles.animationItem}>
                <div className={styles.animationLabel}>{item}</div>
                <div
                  className={`${styles.colorBox} ${styles[`${item.replace('-', '')}Animation`]}`}
                />
              </div>
            ))}
          </div>
        </div>
        <div className={styles.separator}></div>
      </WebFListView>
    </div>
  );
};