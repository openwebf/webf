import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './FontFacePage.module.css';

export const FontFacePage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Custom Font Face Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Google Fonts Examples */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Google Fonts Integration</div>
              <div className={styles.itemDesc}>Examples of popular Google Fonts loaded via CSS @font-face</div>
              <div className={styles.fontContainer}>
                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Roboto</div>
                  <div className={`${styles.fontSample} ${styles.roboto}`}>
                    The quick brown fox jumps over the lazy dog. 1234567890
                  </div>
                  <div className={styles.fontDetails}>
                    Sans-serif • Modern • Readable • Google Font
                  </div>
                </div>

                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Open Sans</div>
                  <div className={`${styles.fontSample} ${styles.openSans}`}>
                    The quick brown fox jumps over the lazy dog. 1234567890
                  </div>
                  <div className={styles.fontDetails}>
                    Sans-serif • Humanist • Friendly • Google Font
                  </div>
                </div>

                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Lato</div>
                  <div className={`${styles.fontSample} ${styles.lato}`}>
                    The quick brown fox jumps over the lazy dog. 1234567890
                  </div>
                  <div className={styles.fontDetails}>
                    Sans-serif • Contemporary • Warm • Google Font
                  </div>
                </div>

                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Montserrat</div>
                  <div className={`${styles.fontSample} ${styles.montserrat}`}>
                    The quick brown fox jumps over the lazy dog. 1234567890
                  </div>
                  <div className={styles.fontDetails}>
                    Sans-serif • Geometric • Urban • Google Font
                  </div>
                </div>
              </div>
            </div>

            {/* Serif Fonts */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Serif Font Families</div>
              <div className={styles.itemDesc}>Traditional serif fonts for formal and readable text</div>
              <div className={styles.fontContainer}>
                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Playfair Display</div>
                  <div className={`${styles.fontSample} ${styles.playfairDisplay}`}>
                    The quick brown fox jumps over the lazy dog. 1234567890
                  </div>
                  <div className={styles.fontDetails}>
                    Serif • Elegant • High-contrast • Display font
                  </div>
                </div>

                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Merriweather</div>
                  <div className={`${styles.fontSample} ${styles.merriweather}`}>
                    The quick brown fox jumps over the lazy dog. 1234567890
                  </div>
                  <div className={styles.fontDetails}>
                    Serif • Readable • Screen-optimized • Text font
                  </div>
                </div>

                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Crimson Text</div>
                  <div className={`${styles.fontSample} ${styles.crimsonText}`}>
                    The quick brown fox jumps over the lazy dog. 1234567890
                  </div>
                  <div className={styles.fontDetails}>
                    Serif • Academic • Book-style • Reading font
                  </div>
                </div>
              </div>
            </div>

            {/* Monospace Fonts */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Monospace Fonts</div>
              <div className={styles.itemDesc}>Fixed-width fonts perfect for code and technical content</div>
              <div className={styles.fontContainer}>
                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Fira Code</div>
                  <div className={`${styles.fontSample} ${styles.firaCode}`}>
                    const example = () =&gt; &#123; return 'Hello World'; &#125;
                  </div>
                  <div className={styles.fontDetails}>
                    Monospace • Programming ligatures • Code font
                  </div>
                </div>

                <div className={styles.fontExample}>
                  <div className={styles.fontName}>Source Code Pro</div>
                  <div className={`${styles.fontSample} ${styles.sourceCodePro}`}>
                    function calculate(a, b) &#123; return a + b; &#125;
                  </div>
                  <div className={styles.fontDetails}>
                    Monospace • Adobe • Clean • Developer-friendly
                  </div>
                </div>

                <div className={styles.fontExample}>
                  <div className={styles.fontName}>JetBrains Mono</div>
                  <div className={`${styles.fontSample} ${styles.jetbrainsMono}`}>
                    class Example &#123; constructor() &#123; this.value = 42; &#125; &#125;
                  </div>
                  <div className={styles.fontDetails}>
                    Monospace • IDE-optimized • Modern • Developer font
                  </div>
                </div>
              </div>
            </div>

            {/* Font Weight Variations */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Font Weight Variations</div>
              <div className={styles.itemDesc}>Different weights of the same font family</div>
              <div className={styles.fontContainer}>
                <div className={styles.weightExample}>
                  <div className={styles.fontName}>Roboto Font Weights</div>
                  <div className={`${styles.weightSample} ${styles.roboto} ${styles.weight100}`}>
                    Thin (100): The quick brown fox jumps over the lazy dog
                  </div>
                  <div className={`${styles.weightSample} ${styles.roboto} ${styles.weight300}`}>
                    Light (300): The quick brown fox jumps over the lazy dog
                  </div>
                  <div className={`${styles.weightSample} ${styles.roboto} ${styles.weight400}`}>
                    Regular (400): The quick brown fox jumps over the lazy dog
                  </div>
                  <div className={`${styles.weightSample} ${styles.roboto} ${styles.weight500}`}>
                    Medium (500): The quick brown fox jumps over the lazy dog
                  </div>
                  <div className={`${styles.weightSample} ${styles.roboto} ${styles.weight700}`}>
                    Bold (700): The quick brown fox jumps over the lazy dog
                  </div>
                  <div className={`${styles.weightSample} ${styles.roboto} ${styles.weight900}`}>
                    Black (900): The quick brown fox jumps over the lazy dog
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};