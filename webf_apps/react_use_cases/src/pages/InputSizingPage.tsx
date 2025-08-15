import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './InputSizingPage.module.css';

export const InputSizingPage: React.FC = () => {
  const [testValue, setTestValue] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setTestValue(e.target.value);
  };

  return (
    <div className={styles.pageContainer}>
      <WebFListView>
        <h1 className={styles.pageTitle}>Input Sizing Showcase</h1>
        <p className={styles.pageDescription}>
          Demonstrating flexible and intelligent input sizing with IntrinsicWidth in WebF
        </p>

        {/* Example 1: Auto-sizing input */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Auto-sizing Input</h3>
          <div className={styles.wideContainer}>
            <input
              type="text"
              value={testValue}
              onChange={handleChange}
              placeholder="Short"
              className={styles.noWidthInput}
            />
            <span className={styles.containerInfo}>Adapts to content width</span>
          </div>
          <div className={styles.expected}>
            Input automatically sizes based on its content, not expanding to fill the entire container.
          </div>
        </div>

        {/* Example 2: Content-aware sizing */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Content-aware Sizing</h3>
          <div className={styles.wideContainer}>
            <input
              type="text"
              placeholder="This is a very long placeholder text that determines the input width"
              className={styles.noWidthInput}
            />
            <span className={styles.containerInfo}>Expands to fit content</span>
          </div>
          <div className={styles.expected}>
            Input width intelligently adjusts to accommodate longer placeholder text.
          </div>
        </div>

        {/* Example 3: Fixed width override */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Fixed Width (200px)</h3>
          <div className={styles.wideContainer}>
            <input
              type="text"
              placeholder="Fixed width input"
              className={styles.fixedWidthInput}
            />
            <span className={styles.containerInfo}>Respects CSS width</span>
          </div>
          <div className={styles.expected}>
            When a specific width is set via CSS, it takes precedence over intrinsic sizing.
          </div>
        </div>

        {/* Example 4: Flexible layout */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Flexible Layout with Multiple Inputs</h3>
          <div className={styles.flexContainer}>
            <input
              type="text"
              placeholder="First"
              className={styles.noWidthInput}
            />
            <input
              type="text"
              placeholder="Second input here"
              className={styles.noWidthInput}
            />
            <input
              type="text"
              placeholder="Third"
              className={styles.noWidthInput}
            />
          </div>
          <div className={styles.expected}>
            Each input maintains its optimal width based on individual content, creating a natural layout.
          </div>
        </div>

        {/* Example 5: Percentage-based width */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Responsive Width (50%)</h3>
          <div className={styles.wideContainer}>
            <input
              type="text"
              placeholder="50% width"
              className={styles.percentWidthInput}
            />
            <span className={styles.containerInfo}>Half of container</span>
          </div>
          <div className={styles.expected}>
            Percentage widths work seamlessly for responsive designs.
          </div>
        </div>

        {/* Example 6: Minimal width */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Minimal Width Input</h3>
          <div className={styles.wideContainer}>
            <input
              type="text"
              className={styles.noWidthInput}
            />
            <span className={styles.containerInfo}>Compact when empty</span>
          </div>
          <div className={styles.expected}>
            Empty inputs maintain a sensible minimum width, staying compact and efficient.
          </div>
        </div>

        {/* Example 7: Interactive input */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Interactive Input</h3>
          <div className={styles.wideContainer}>
            <input
              type="text"
              value={testValue}
              onChange={handleChange}
              placeholder="Type here..."
              className={styles.noWidthInput}
            />
            <span className={styles.containerInfo}>Try typing!</span>
          </div>
          <div className={styles.expected}>
            Input width is determined by placeholder text, providing consistent layout regardless of user input.
          </div>
        </div>

        {/* Example 8: Custom height */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>Custom Height (100px)</h3>
          <div className={styles.wideContainer}>
            <input
              type="text"
              placeholder="Custom height input"
              className={styles.heightTestInput}
            />
            <span className={styles.containerInfo}>100px tall</span>
          </div>
          <div className={styles.expected}>
            Height constraints work independently, allowing for various input sizes and styles.
          </div>
        </div>

        {/* Current value display */}
        <div className={styles.valueDisplay}>
          <strong>Interactive value:</strong> "{testValue}"
        </div>

        {/* Key Features */}
        <div className={styles.instructions}>
          <h3>Key Features</h3>
          <ul>
            <li><strong>Smart Sizing:</strong> Inputs automatically size based on their content</li>
            <li><strong>No Overflow:</strong> Inputs don't unnecessarily expand to fill containers</li>
            <li><strong>CSS Compatibility:</strong> Explicit widths (px, %, etc.) are fully respected</li>
            <li><strong>Natural Layouts:</strong> Multiple inputs in flex containers maintain optimal sizes</li>
            <li><strong>Web Standards:</strong> Behavior matches native HTML input elements</li>
          </ul>
        </div>
      </WebFListView>
    </div>
  );
};