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
        <h1 className={styles.pageTitle}>Input Type=Text Sizing Test Cases</h1>
        <p className={styles.pageDescription}>
          Comprehensive test cases covering all common input sizing scenarios
        </p>

        {/* Test 1: Default input (no CSS styling) */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>1. Default Input (No Styling)</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="Default input" />
            <span className={styles.containerInfo}>Browser defaults</span>
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Default browser width (~140px) and height (~32px with default font-size)
          </div>
        </div>

        {/* Test 2: Fixed width only */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>2. Fixed Width Only</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="Fixed width" className={styles.fixedWidthInput} />
            <span className={styles.containerInfo}>width: 200px</span>
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Width = 200px, height = default
          </div>
        </div>

        {/* Test 3: Fixed height only */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>3. Fixed Height Only</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="Fixed height" className={styles.heightTestInput} />
            <span className={styles.containerInfo}>height: 100px</span>
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Height = 100px, width = default, text vertically centered
          </div>
        </div>

        {/* Test 4: Both width and height fixed */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>4. Both Width and Height Fixed</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="Fixed both" className={styles.fixedBothInput} />
            <span className={styles.containerInfo}>200px × 80px</span>
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Width = 200px, height = 80px, text centered
          </div>
        </div>

        {/* Test 5: Percentage width */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>5. Percentage Width</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="50% width" className={styles.percentWidthInput} />
            <span className={styles.containerInfo}>width: 50%</span>
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Width = 50% of container, height = default
          </div>
        </div>

        {/* Test 6: Padding effects */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>6. Padding Effects</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="Big padding" className={styles.bigPaddingInput} />
            <span className={styles.containerInfo}>padding: 20px</span>
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Larger visual size due to padding, text remains readable
          </div>
        </div>

        {/* Test 7: Different font sizes */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>7. Font Size Variations</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="Small" className={styles.smallFontInput} />
            <input type="text" placeholder="Normal" className={styles.normalFontInput} />
            <input type="text" placeholder="Large" className={styles.largeFontInput} />
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Different font sizes (12px, 16px, 24px), heights adapt accordingly
          </div>
        </div>


        {/* Test 8: Min/max width */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>8. Min/Max Width Constraints</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="min-width: 300px" className={styles.minWidthInput} />
            <input type="text" placeholder="max-width: 100px" className={styles.maxWidthInput} />
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> First input at least 300px wide, second at most 100px wide
          </div>
        </div>

        {/* Test 9: Complex styling combinations */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>9. Complex Combination</h3>
          <div className={styles.wideContainer}>
            <input 
              type="text" 
              placeholder="Complex styling" 
              className={styles.complexInput}
            />
            <span className={styles.containerInfo}>height: 120px, padding: 15px, font-size: 18px</span>
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Large input with proper text centering and spacing
          </div>
        </div>

        {/* Test 10: Flex layout behavior */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>10. Flex Container Behavior</h3>
          <div className={styles.flexContainer}>
            <input type="text" placeholder="Flex item 1" className={styles.flexItemInput} />
            <input type="text" placeholder="Flex item 2" className={styles.flexItemInput} />
            <input type="text" placeholder="Flex item 3" className={styles.flexItemInput} />
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Inputs in flex layout, equal widths or natural sizing
          </div>
        </div>


        {/* Test 11: Edge cases */}
        <div className={styles.testCase}>
          <h3 className={styles.testTitle}>11. Edge Cases</h3>
          <div className={styles.wideContainer}>
            <input type="text" placeholder="Very very very very very very long placeholder text that should test text overflow behavior" className={styles.longPlaceholderInput} />
          </div>
          <div className={styles.expected}>
            <strong>Expected:</strong> Long placeholder handles overflow correctly (truncate or scroll)
          </div>
        </div>

        {/* Test Results Summary */}
        <div className={styles.instructions}>
          <h3>Test Coverage Summary</h3>
          <ul>
            <li><strong>Default behavior:</strong> Browser default sizing</li>
            <li><strong>CSS dimensions:</strong> width, height, min/max constraints</li>
            <li><strong>Box model:</strong> padding, border, box-sizing effects</li>
            <li><strong>Typography:</strong> font-size, line-height interactions</li>
            <li><strong>Layout contexts:</strong> flex, percentage, responsive behavior</li>
            <li><strong>Edge cases:</strong> long text, complex combinations</li>
            <li><strong>Interactivity:</strong> actual text input and display</li>
          </ul>
        </div>
      </WebFListView>
    </div>
  );
};