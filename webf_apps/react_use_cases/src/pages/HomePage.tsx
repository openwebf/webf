import React from 'react';
import { WebFRouter } from '@openwebf/react-router';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './HomePage.module.css';

export const HomePage: React.FC = () => {
  const navigateTo = (path: string) => {
    WebFRouter.pushState({}, path);
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          {/* Basic Components */}
          <div className={styles.sectionTitle}>Basic Components</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/listview')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Custom Listview</div>
                <div className={styles.itemDesc}>Custom listview component with scroll and refresh capabilities.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/form')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Form Validation</div>
                <div className={styles.itemDesc}>Advanced form validation with Flutter components, layout switching, and error handling.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/basic-form-elements')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Basic Form Elements</div>
                <div className={styles.itemDesc}>Basic HTML form elements: text input, radio buttons, and checkboxes.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/advanced-form')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Advanced Forms</div>
                <div className={styles.itemDesc}>Advanced form with react-hook-form.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/image')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Image Gallery</div>
                <div className={styles.itemDesc}>Support for various image formats: SVG, GIF, PNG, WebP.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/show_case')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Show Case</div>
                <div className={styles.itemDesc}>Highlight and guide users through UI elements step by step.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/table')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Tables</div>
                <div className={styles.itemDesc}>Rich table components with sticky headers, custom alignment, and flexible layouts.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* UI & Styling */}
          <div className={styles.sectionTitle}>UI & Styling</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/typography')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Typography</div>
                <div className={styles.itemDesc}>Text layouts with multilingual support and image wrapping.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/theme-toggle')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Theme Toggle</div>
                <div className={styles.itemDesc}>Dark/light mode switching with Flutter integration.</div>
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

          {/* Media & Performance */}
          <div className={styles.sectionTitle}>Media & Performance</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/video')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Video Player</div>
                <div className={styles.itemDesc}>HTML5 video player with custom controls and multiple formats.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/qrcode')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>QR Code Generator</div>
                <div className={styles.itemDesc}>Generate and customize QR codes with various data types and styling options.</div>
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
            <div className={styles.componentItem} onClick={() => navigateTo('/network')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Network Requests</div>
                <div className={styles.itemDesc}>HTTP requests: GET, POST, PUT, DELETE, FormData, and file uploads.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Native Integration */}
          <div className={styles.sectionTitle}>Native Integration</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/flutter-interaction')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Flutter Interaction</div>
                <div className={styles.itemDesc}>Method channel communication between WebF and Flutter.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/native-interaction')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Native Modules</div>
                <div className={styles.itemDesc}>Screenshot capture and sharing capabilities with native modules.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/routing')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Routing & Navigation</div>
                <div className={styles.itemDesc}>Multi-route scenarios using WebF hybrid history API.</div>
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
            <div className={styles.componentItem} onClick={() => navigateTo('/gesture')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Gesture Detection</div>
                <div className={styles.itemDesc}>Flutter gesture capabilities: tap, pan, scale, rotate, and swipe gestures.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* Advanced Web APIs */}
          <div className={styles.sectionTitle}>Advanced Web APIs</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/resize-observer')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>ResizeObserver API</div>
                <div className={styles.itemDesc}>Monitor element size changes with responsive canvas drawing and real-time dimension tracking.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/mutation-observer')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>MutationObserver API</div>
                <div className={styles.itemDesc}>Track DOM tree changes including attributes, child nodes, and character data mutations.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/web-storage')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>Web Storage API</div>
                <div className={styles.itemDesc}>Manage localStorage and sessionStorage with JSON data handling and storage analytics.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/dom-bounding-rect')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>DOM Measurements API</div>
                <div className={styles.itemDesc}>Real-time element positioning and size tracking with getBoundingClientRect() demonstrations.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>

          {/* CSS Showcase */}
          <div className={styles.sectionTitle}>CSS Showcase</div>
          <div className={`${styles.componentBlock} ${styles.categoryBlock}`}>
            <div className={styles.componentItem} onClick={() => navigateTo('/animation')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>CSS Animations</div>
                <div className={styles.itemDesc}>CSS animations: fade, slide, scale, rotate, bounce, and pulse effects.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
            <div className={styles.componentItem} onClick={() => navigateTo('/css-showcase')}>
              <div className={styles.itemContent}>
                <div className={styles.itemTitle}>CSS Demonstrations</div>
                <div className={styles.itemDesc}>Comprehensive CSS showcase with layouts, animations, and advanced styling techniques.</div>
              </div>
              <div className={styles.itemArrow}>&gt;</div>
            </div>
          </div>
        </div> {/* End of main component-section */}
      </WebFListView>
    </div>
  );
};