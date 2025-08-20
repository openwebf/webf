import React from 'react';
import { WebFRouter } from '@openwebf/react-router';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './CSSShowcasePage.module.css';

export const CSSShowcasePage: React.FC = () => {
  const navigateTo = (path: string) => {
    WebFRouter.pushState({}, path);
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.headerSection}>
          <div className={styles.header}>
            <h1 className={styles.title}>CSS Showcase</h1>
            <p className={styles.description}>
              Some examples show how to use different CSS properties
            </p>
          </div>
        </div>

        <div className={styles.componentSection}>
          {/* Background Examples */}
          <div className={styles.sectionTitle}>Background Examples</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/bg')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Background</div>
                <div className={styles.itemDesc}>Basic background examples and patterns.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/bg-gradient')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Background Gradient</div>
                <div className={styles.itemDesc}>Linear gradient backgrounds with various directions.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/bg-radial')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Background Radial</div>
                <div className={styles.itemDesc}>Radial gradient patterns and effects.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/bg-image')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Background Image</div>
                <div className={styles.itemDesc}>Background image positioning and sizing.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Border & Shadow Effects */}
          <div className={styles.sectionTitle}>Border & Shadow Effects</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/border')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Border</div>
                <div className={styles.itemDesc}>Border styles and configurations.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/border-radius')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Border Radius</div>
                <div className={styles.itemDesc}>Rounded corners and border radius effects.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/box-shadow')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Box Shadow</div>
                <div className={styles.itemDesc}>Shadow effects and depth illusions.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/border-background-shadow')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Border Background Shadow</div>
                <div className={styles.itemDesc}>Combined border, background and shadow effects.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Layout Systems */}
          <div className={styles.sectionTitle}>Layout Systems</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/flex-layout')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Flex Layout</div>
                <div className={styles.itemDesc}>Flexible box layout demonstrations.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Advanced Effects */}
          <div className={styles.sectionTitle}>Advanced Effects</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/keyframes')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Keyframes</div>
                <div className={styles.itemDesc}>CSS keyframe animations.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/filter')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Filter</div>
                <div className={styles.itemDesc}>CSS filter effects.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/clip-path')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Clip Path</div>
                <div className={styles.itemDesc}>Clip path shapes.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* CSS Guides & Selectors */}
          <div className={styles.sectionTitle}>CSS Guides & Selectors</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/descendant-selectors-theme')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Descendant Selectors Theme</div>
                <div className={styles.itemDesc}>Descendant selector patterns for theming.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/class-guide')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Class Guide</div>
                <div className={styles.itemDesc}>CSS class usage patterns.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css/cascade-guide')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Cascade Guide</div>
                <div className={styles.itemDesc}>Understanding CSS cascade rules.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};