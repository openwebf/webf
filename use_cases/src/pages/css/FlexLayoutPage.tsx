import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './FlexLayoutPage.module.css';

export const FlexLayoutPage: React.FC = () => {
  const [wrapDemoHeight, setWrapDemoHeight] = useState<'auto' | '50%'>('auto');
  return (
    <div id="main">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
        <div className={styles.wrapper}>
          <div className={`${styles.headerTitle} ${styles.colorWidth}`}>
            Flex layout
          </div>
          <div className={styles.main}>
            The flexible box layout module (usually referred to as flexbox) is a one-dimensional layout model for
            distributing space between items and includes numerous alignment capabilities. This article gives an outline
            of the main features of flexbox, which we will explore in more detail in the rest of these guides.
          </div>
          <div className={`${styles.aside} ${styles.aside1}`}>
            flex: 1 0 0
          </div>
          <div className={`${styles.aside} ${styles.aside2}`}>
            flex: 2 0 0
          </div>
          <div className={styles.footer}>
            Footer -- flex: 1 100%
          </div>
        </div>

        {/* Verified behaviors in integration tests */}
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>Verified Behaviors (from integration tests)</h2>
          <ul className={styles.bulletList}>
            <li>Parent containers with <code>display: flex</code> lay out children correctly.</li>
            <li>Row/column direction via <code>flex-direction</code> are supported.</li>
            <li><code>align-items: stretch</code> stretches auto-height children on the cross-axis.</li>
            <li>Percentage heights resolve inside flex containers (row and column).</li>
            <li>Late style changes (e.g., setting <code>height: 50%</code> after mount) update layout.</li>
            <li>Nesting flex containers computes constraints correctly with padding and borders.</li>
          </ul>
        </div>

        {/* Demo 1: Column flex container with padding/margin/border */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Column Flex Container</h3>
          <div
            style={{
              width: 300,
              height: 200,
              padding: 10,
              margin: 15,
              border: '5px solid black',
              display: 'flex',
              flexDirection: 'column',
              background: '#fafafa',
            }}
          >
            <div style={{ width: '100%', background: 'lightblue', padding: 10 }}>
              Text inside flex container
            </div>
          </div>
          <div className={styles.note}>Matches test setup: 300×200 container with padding, margin, border, column flow.</div>
        </div>

        {/* Demo 2: Nested flex containers */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Nested Flex Containers</h3>
          <div
            style={{
              width: 400,
              height: 300,
              padding: 20,
              border: '5px solid black',
              display: 'flex',
              background: '#fff',
            }}
          >
            <div
              style={{
                width: '80%',
                padding: 15,
                border: '3px solid red',
                display: 'flex',
                background: '#fff',
              }}
            >
              <div style={{ background: 'lightgreen', padding: 10 }}>Deeply nested text widget</div>
            </div>
          </div>
          <div className={styles.note}>Matches test setup: parent(400×300, padding/border) → child(80% width, padding/border) → content.</div>
        </div>

        {/* Demo 3: align-items: stretch with mixed child heights (row) */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Align Items: Stretch (Row)</h3>
          <div
            style={{
              width: 200,
              height: 200,
              display: 'flex',
              background: '#666',
              flexDirection: 'row',
              alignItems: 'stretch',
              gap: 6,
              padding: 4,
            }}
          >
            <div style={{ width: 50, background: 'blue', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12 }}>no height</div>
            <div style={{ width: 50, height: 100, background: 'red' }} />
            <div style={{ width: 50, height: 50, background: 'green' }} />
          </div>
          <div className={styles.note}>Matches test: parent flex row with align-items: stretch; first child grows to container cross-axis.</div>
        </div>

        {/* Demo 4: Percentage heights in flex (row) */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Percentage Heights (Row)</h3>
          <div
            style={{
              display: 'flex',
              width: 200,
              height: 200,
              background: 'green',
              position: 'relative',
              gap: 6,
              padding: 4,
            }}
          >
            <div style={{ height: '50%', width: 100, background: 'yellow' }} />
            <div style={{ height: '50%', width: '100%', background: 'blue', display: 'flex' }}>
              <div style={{ height: '100%', width: 100, background: 'red' }} />
            </div>
          </div>
          <div className={styles.note}>Verified: percent heights resolve against flex container size (row direction).</div>
        </div>

        {/* Demo 5: Percentage heights in flex (column) */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Percentage Heights (Column)</h3>
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              width: 200,
              height: 200,
              background: 'green',
              position: 'relative',
              gap: 6,
              padding: 4,
            }}
          >
            <div style={{ height: '50%', width: 100, background: 'yellow' }} />
            <div style={{ height: '50%', width: '100%', background: 'blue', display: 'flex' }}>
              <div style={{ height: '100%', width: 100, background: 'red' }} />
            </div>
          </div>
          <div className={styles.note}>Verified: percent heights resolve with column direction as well.</div>
        </div>

        {/* Demo 6: Flex-wrap with dynamic percentage after attach */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Flex Wrap + Late Percentage Height</h3>
          <div
            style={{
              display: 'flex',
              flexWrap: 'wrap',
              width: 200,
              height: 200,
              background: 'green',
              position: 'relative',
              padding: 4,
              gap: 6,
            }}
          >
            <div style={{ width: 100, height: wrapDemoHeight, background: 'yellow' }} />
          </div>
          <div className={styles.note}>Test parity: setting child height to 50% after mount updates layout.</div>
          <button className={styles.btn} onClick={() => setWrapDemoHeight('50%')}>Set height to 50%</button>
        </div>

        {/* Demo 7: Row center alignment */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Justify/Align Center (Row)</h3>
          <div
            style={{
              width: '100%',
              height: 100,
              border: '1px solid #000',
              background: '#fff',
              display: 'flex',
              flexDirection: 'row',
              justifyContent: 'center',
              alignItems: 'center',
              gap: 12,
            }}
          >
            <div style={{ width: 120, height: 40, background: '#0ea5e9' }} />
            <div style={{ width: 120, height: 40, background: '#f97316' }} />
          </div>
          <div className={styles.note}>Based on test: custom elements read flex styles with center alignment.</div>
        </div>

        {/* Demo 8: inline-flex containers */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Inline Flex</h3>
          <div className={styles.note}>Inline-level flex containers participate in inline flow.</div>
          <div>
            <span
              className={styles.demoContainer}
              style={{ display: 'inline-flex', gap: 6, padding: 6, marginRight: 8 }}
            >
              <span className={`${styles.demoItem}`} style={{ width: 40, height: 30 }}>A</span>
              <span className={`${styles.demoItem} ${styles.alt1}`} style={{ width: 40, height: 30 }}>B</span>
            </span>
            <span
              className={styles.demoContainer}
              style={{ display: 'inline-flex', gap: 6, padding: 6 }}
            >
              <span className={`${styles.demoItem} ${styles.alt2}`} style={{ width: 40, height: 30 }}>C</span>
              <span className={`${styles.demoItem} ${styles.alt3}`} style={{ width: 40, height: 30 }}>D</span>
            </span>
            <span className={styles.note}>Text flows around inline flex containers.</span>
          </div>
        </div>

        {/* Demo 9: Flex grow/shrink */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Flex Grow/Shrink</h3>
          <div className={styles.variantTitle}>Shrink within constrained width</div>
          <div className={styles.demoContainer} style={{ display: 'flex', width: 320, gap: 8 }}>
            <div className={styles.demoItem} style={{ width: 200, flexShrink: 1, height: 36 }}>shrink:1, w200</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ width: 200, flexShrink: 1, height: 36 }}>shrink:1, w200</div>
          </div>
          <div className={styles.variantTitle}>Grow to fill leftover space</div>
          <div className={styles.demoContainer} style={{ display: 'flex', width: 420, gap: 8 }}>
            <div className={styles.demoItem} style={{ flex: 1, minWidth: 60, height: 36 }}>flex:1</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ flex: 2, minWidth: 60, height: 36 }}>flex:2</div>
            <div className={`${styles.demoItem} ${styles.alt3}`} style={{ flex: 3, minWidth: 60, height: 36 }}>flex:3</div>
          </div>
        </div>

        {/* Demo 10: justify-content variants */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>justify-content Variants</h3>
          <div className={styles.variantTitle}>space-between</div>
          <div className={styles.demoContainer} style={{ display: 'flex', justifyContent: 'space-between', gap: 0 }}>
            <div className={styles.demoItem} style={{ width: 60, height: 30 }}>A</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ width: 60, height: 30 }}>B</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ width: 60, height: 30 }}>C</div>
          </div>
          <div className={styles.variantTitle}>space-around</div>
          <div className={styles.demoContainer} style={{ display: 'flex', justifyContent: 'space-around' }}>
            <div className={styles.demoItem} style={{ width: 60, height: 30 }}>A</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ width: 60, height: 30 }}>B</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ width: 60, height: 30 }}>C</div>
          </div>
          <div className={styles.variantTitle}>space-evenly</div>
          <div className={styles.demoContainer} style={{ display: 'flex', justifyContent: 'space-evenly' }}>
            <div className={styles.demoItem} style={{ width: 60, height: 30 }}>A</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ width: 60, height: 30 }}>B</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ width: 60, height: 30 }}>C</div>
          </div>
        </div>

        {/* Demo 11: align-content and wrap */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>align-content (with wrap)</h3>
          <div className={styles.variantTitle}>start</div>
          <div className={styles.demoContainer} style={{ display: 'flex', flexWrap: 'wrap', alignContent: 'flex-start', height: 120, gap: 6 }}>
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={`ac-start-${i}`} className={styles.demoItem} style={{ width: 60, height: 30 }}>{i + 1}</div>
            ))}
          </div>
          <div className={styles.variantTitle}>center</div>
          <div className={styles.demoContainer} style={{ display: 'flex', flexWrap: 'wrap', alignContent: 'center', height: 120, gap: 6 }}>
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={`ac-center-${i}`} className={`${styles.demoItem} ${i % 2 ? styles.alt1 : ''}`} style={{ width: 60, height: 30 }}>{i + 1}</div>
            ))}
          </div>
          <div className={styles.variantTitle}>space-between</div>
          <div className={styles.demoContainer} style={{ display: 'flex', flexWrap: 'wrap', alignContent: 'space-between', height: 120, gap: 6 }}>
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={`ac-between-${i}`} className={`${styles.demoItem} ${i % 3 === 0 ? styles.alt2 : ''}`} style={{ width: 60, height: 30 }}>{i + 1}</div>
            ))}
          </div>
        </div>

        {/* Demo 12: align-self overrides */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>align-self</h3>
          <div className={styles.demoContainer} style={{ display: 'flex', alignItems: 'flex-start', height: 100, gap: 8 }}>
            <div className={styles.demoItem} style={{ width: 60, height: 30 }}>start (inherited)</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ width: 60, height: 30, alignSelf: 'center' }}>center</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ width: 60, height: 30, alignSelf: 'flex-end' }}>end</div>
          </div>
        </div>

        {/* Demo 13: order */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>order</h3>
          <div className={styles.demoContainer} style={{ display: 'flex', gap: 8 }}>
            <div className={styles.demoItem} style={{ width: 60, height: 30, order: 3 }}>1 (3)</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ width: 60, height: 30, order: 1 }}>2 (1)</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ width: 60, height: 30, order: 2 }}>3 (2)</div>
          </div>
          <div className={styles.note}>Numbers in parentheses are the applied order values.</div>
        </div>

        {/* Demo 14: flex-basis */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>flex-basis</h3>
          <div className={styles.demoContainer} style={{ display: 'flex', width: 520, gap: 8 }}>
            <div className={styles.demoItem} style={{ flex: '0 0 100px', height: 36 }}>basis 100</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ flex: '0 0 150px', height: 36 }}>basis 150</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ flex: '0 0 200px', height: 36 }}>basis 200</div>
          </div>
          <div className={styles.variantTitle}>basis + grow</div>
          <div className={styles.demoContainer} style={{ display: 'flex', width: 520, gap: 8 }}>
            <div className={styles.demoItem} style={{ flex: '1 1 100px', height: 36 }}>1 1 100</div>
            <div className={`${styles.demoItem} ${styles.alt1}`} style={{ flex: '2 1 100px', height: 36 }}>2 1 100</div>
            <div className={`${styles.demoItem} ${styles.alt2}`} style={{ flex: '3 1 100px', height: 36 }}>3 1 100</div>
          </div>
        </div>

        {/* Demo 15: gap / row-gap / column-gap */}
        <div className={styles.section}>
          <h3 className={styles.sectionSubTitle}>Gaps (gap, row-gap, column-gap)</h3>
          <div className={styles.variantTitle}>gap: 12px</div>
          <div className={styles.demoContainer} style={{ display: 'flex', flexWrap: 'wrap', gap: 12, width: 320 }}>
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={`gap-${i}`} className={styles.demoItem} style={{ width: 80, height: 30 }}>{i + 1}</div>
            ))}
          </div>
          <div className={styles.variantTitle}>row-gap: 16px; column-gap: 6px</div>
          <div className={styles.demoContainer} style={{ display: 'flex', flexWrap: 'wrap', rowGap: 16, columnGap: 6, width: 320 }}>
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={`rg-${i}`} className={`${styles.demoItem} ${i % 2 ? styles.alt1 : ''}`} style={{ width: 80, height: 30 }}>{i + 1}</div>
            ))}
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
