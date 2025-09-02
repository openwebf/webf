import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './DOMBoundingRectPage.module.css';

interface RectData {
  x: number;
  y: number;
  width: number;
  height: number;
  top: number;
  right: number;
  bottom: number;
  left: number;
}

export const DOMBoundingRectPage: React.FC = () => {
  const [currentRect, setCurrentRect] = useState<RectData | null>(null);
  const [currentElement, setCurrentElement] = useState<string>('');
  
  // Target element refs
  const boxRef = useRef<HTMLDivElement>(null);
  const textRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);
  
  // Dynamic positioning state
  const [boxPosition, setBoxPosition] = useState({ x: 50, y: 120 });

  const measureElement = (ref: React.RefObject<HTMLElement | null>, elementName: string) => {
    if (ref?.current) {
      const rect = ref.current.getBoundingClientRect();
      setCurrentRect({
        x: Math.round(rect.x * 100) / 100,
        y: Math.round(rect.y * 100) / 100,
        width: Math.round(rect.width * 100) / 100,
        height: Math.round(rect.height * 100) / 100,
        top: Math.round(rect.top * 100) / 100,
        right: Math.round(rect.right * 100) / 100,
        bottom: Math.round(rect.bottom * 100) / 100,
        left: Math.round(rect.left * 100) / 100
      });
      setCurrentElement(elementName);
    }
  };

  const moveBox = (direction: string) => {
    setBoxPosition(prev => {
      const step = 30;
      switch (direction) {
        case 'up': return { ...prev, y: Math.max(80, prev.y - step) };
        case 'down': return { ...prev, y: Math.min(200, prev.y + step) };
        case 'left': return { ...prev, x: Math.max(0, prev.x - step) };
        case 'right': return { ...prev, x: Math.min(300, prev.x + step) };
        default: return prev;
      }
    });
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>getBoundingClientRect API</div>
          <div className={styles.componentBlock}>
            
            {/* Interactive Elements */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Click Elements to Measure</div>
              <div className={styles.itemDesc}>Click on any element below to see its getBoundingClientRect() result</div>
              
              <div className={styles.playground}>
                {/* Moving Box */}
                <div className={styles.movingContainer}>
                  <div className={styles.controlGroup}>
                    <span className={styles.controlLabel}>Moving Box</span>
                    <div className={styles.controls}>
                      <button className={styles.miniButton} onClick={() => moveBox('up')}>↑</button>
                      <button className={styles.miniButton} onClick={() => moveBox('down')}>↓</button>
                      <button className={styles.miniButton} onClick={() => moveBox('left')}>←</button>
                      <button className={styles.miniButton} onClick={() => moveBox('right')}>→</button>
                    </div>
                  </div>
                  <div 
                    ref={boxRef}
                    className={styles.movingBox}
                    style={{ 
                      left: boxPosition.x,
                      top: boxPosition.y
                    }}
                    onClick={() => measureElement(boxRef, 'Moving Box')}
                  >
                    <div className={styles.boxContent}>
                      Click to measure
                    </div>
                  </div>
                </div>

                {/* Other Elements */}
                <div className={styles.otherElements}>
                  <div 
                    ref={textRef}
                    className={styles.textContent}
                    onClick={() => measureElement(textRef, 'Text Content')}
                  >
                    Click to measure this text element
                  </div>
                  
                  <img 
                    ref={imageRef}
                    src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIwIiBoZWlnaHQ9IjgwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iNjAiIGZpbGw9IiM0Q0FGNTB0Ii8+PHRleHQgeD0iNjAiIHk9IjQwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSI+SW1hZ2U8L3RleHQ+PC9zdmc+"
                    alt="Sample"
                    className={styles.sampleImage}
                    onClick={() => measureElement(imageRef, 'Sample Image')}
                  />
                </div>
              </div>
            </div>

            {/* Current Measurement */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Current Measurement</div>
              <div className={styles.itemDesc}>getBoundingClientRect() result for the last clicked element</div>
              {currentRect ? (
                <div className={styles.currentMeasurement}>
                  <div className={styles.measurementHeader}>
                    <span className={styles.elementName}>{currentElement}</span>
                  </div>
                  <div className={styles.measurementGrid}>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>X</span>
                      <span className={styles.measurementValue}>{currentRect.x}</span>
                    </div>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>Y</span>
                      <span className={styles.measurementValue}>{currentRect.y}</span>
                    </div>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>Width</span>
                      <span className={styles.measurementValue}>{currentRect.width}</span>
                    </div>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>Height</span>
                      <span className={styles.measurementValue}>{currentRect.height}</span>
                    </div>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>Top</span>
                      <span className={styles.measurementValue}>{currentRect.top}</span>
                    </div>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>Right</span>
                      <span className={styles.measurementValue}>{currentRect.right}</span>
                    </div>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>Bottom</span>
                      <span className={styles.measurementValue}>{currentRect.bottom}</span>
                    </div>
                    <div className={styles.measurementItem}>
                      <span className={styles.measurementLabel}>Left</span>
                      <span className={styles.measurementValue}>{currentRect.left}</span>
                    </div>
                  </div>
                </div>
              ) : (
                <div className={styles.logEmpty}>Click on an element above to see its measurements</div>
              )}
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};