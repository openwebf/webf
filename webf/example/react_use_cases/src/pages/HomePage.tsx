import React from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './HomePage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

export const HomePage: React.FC = () => {
  const navigateTo = (path: string) => {
    // Assuming window.webf.hybridHistory is the correct way to navigate
    if ((window as any).webf && (window as any).webf.hybridHistory) {
      (window as any).webf.hybridHistory.pushState({}, path);
    } else {
      console.error('Navigation object (window.webf.hybridHistory) not found.');
    }
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          {/* Common Category */}
          <div className={styles.sectionTitle}>Common</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            {/* Show Case */}
            <div className={styles.componentItem} onClick={() => navigateTo('/show_case')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Show Case</div>
                <div className={styles.itemDesc}>Highlight your elements step by step.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/listview')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Custom Listview</div>
                <div className={styles.itemDesc}>A custom listview component.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/form')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Basic Form</div>
                <div className={styles.itemDesc}>Simple form with basic validation using WebF components.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            {/* <div className={styles.componentItem} onClick={() => navigateTo('/form-advanced')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Advanced Form</div>
                <div className={styles.itemDesc}>Comprehensive form with React Hook Form, dynamic fields, and complex validation.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div> */}
            {/* <div className={styles.componentItem} onClick={() => navigateTo('/echarts')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>ECharts</div>
                <div className={styles.itemDesc}>Interactive charts including pie, bar, and line charts.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div> */}
            <div className={styles.componentItem} onClick={() => navigateTo('/image')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Image Gallery</div>
                <div className={styles.itemDesc}>Support for various image formats: SVG, GIF, PNG, WebP.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* UI & Animation Category */}
          <div className={styles.sectionTitle}>UI & Animation</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/animation')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>CSS Animations</div>
                <div className={styles.itemDesc}>Basic CSS animations: fade, slide, scale, rotate, bounce, and pulse.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/typography')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Typography</div>
                <div className={styles.itemDesc}>Text layouts with multilingual support and image wrapping.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Native UI Components Category */}
          <div className={styles.sectionTitle}>Native UI Components</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/actionsheet')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Action Sheets</div>
                <div className={styles.itemDesc}>iOS-style action sheets with various configurations and destructive actions.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/alert')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Alert Dialogs</div>
                <div className={styles.itemDesc}>Native alert dialogs with confirm/cancel buttons and destructive actions.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/contextmenu')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Context Menu</div>
                <div className={styles.itemDesc}>3D Touch-style context menus with haptic feedback and custom actions.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/modalpopup')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Modal Popup</div>
                <div className={styles.itemDesc}>Bottom sheet modal popups with custom content and styling options.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/loading')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Loading Indicators</div>
                <div className={styles.itemDesc}>Native loading spinners with text and mask-closable options.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Media & Fonts Category */}
          <div className={styles.sectionTitle}>Media & Fonts</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/video')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Video Player</div>
                <div className={styles.itemDesc}>HTML5 video player with custom controls and multiple formats.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/fontface')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Custom Fonts</div>
                <div className={styles.itemDesc}>CSS @font-face demonstrations with Google Fonts integration.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/image-preload')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Image Preload</div>
                <div className={styles.itemDesc}>Performance comparison of images with and without preload hints.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Advanced Features Category */}
          <div className={styles.sectionTitle}>Advanced Features</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/native-interaction')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Native Interaction</div>
                <div className={styles.itemDesc}>Screenshot capture and sharing capabilities with native modules.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/flutter-interaction')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Flutter Interaction</div>
                <div className={styles.itemDesc}>Method channel communication between WebF and Flutter.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/deep-link')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Deep Links</div>
                <div className={styles.itemDesc}>URL schemes and deep linking for navigation and sharing.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/network')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Network Requests</div>
                <div className={styles.itemDesc}>HTTP requests: GET, POST, PUT, DELETE, FormData, and file uploads.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/responsive')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Responsive Design</div>
                <div className={styles.itemDesc}>Adaptive layouts and responsive design patterns for all screen sizes.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            {/* <div className={styles.componentItem} onClick={() => navigateTo('/routing')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Routing & Navigation</div>
                <div className={styles.itemDesc}>Multi-route scenarios using WebF hybrid history API.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div> */}
          </div>
        </div> {/* End of main component-section */}
      </WebFListView>
    </div>
  );
};