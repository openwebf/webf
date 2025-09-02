import React, { useRef, useEffect, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './ResizeObserverPage.module.css';

interface ResizeInfo {
  width: number;
  height: number;
  contentBoxSize?: ResizeObserverSize;
  borderBoxSize?: ResizeObserverSize;
  devicePixelContentBoxSize?: ResizeObserverSize;
}

export const ResizeObserverPage: React.FC = () => {
  const [resizeableInfo, setResizeableInfo] = useState<ResizeInfo>({ width: 0, height: 0 });
  const [textareaInfo, setTextareaInfo] = useState<ResizeInfo>({ width: 0, height: 0 });
  const [observerEntries, setObserverEntries] = useState<string[]>([]);
  
  const resizeableRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    const resizeObserver = new ResizeObserver((entries) => {
      const newEntries: string[] = [];
      
      entries.forEach((entry) => {
        const { target, contentRect, contentBoxSize, borderBoxSize, devicePixelContentBoxSize } = entry;
        const resizeInfo: ResizeInfo = {
          width: Math.round(contentRect.width),
          height: Math.round(contentRect.height),
          contentBoxSize: Array.isArray(contentBoxSize) ? contentBoxSize[0] : contentBoxSize,
          borderBoxSize: Array.isArray(borderBoxSize) ? borderBoxSize[0] : borderBoxSize,
          devicePixelContentBoxSize: Array.isArray(devicePixelContentBoxSize) ? devicePixelContentBoxSize[0] : devicePixelContentBoxSize,
        };

        newEntries.push(`${target.className || target.tagName}: ${resizeInfo.width}×${resizeInfo.height}`);

        if (target === resizeableRef.current) {
          setResizeableInfo(resizeInfo);
        } else if (target === textareaRef.current) {
          setTextareaInfo(resizeInfo);
        }
      });

      setObserverEntries(prev => [...newEntries, ...prev].slice(0, 20));
    });

    // Observe multiple elements
    const elements = [resizeableRef.current, textareaRef.current];
    elements.forEach(el => el && resizeObserver.observe(el));

    return () => resizeObserver.disconnect();
  }, []);

  const renderSizeDetails = (info: ResizeInfo, title: string) => (
    <div className={styles.sizeDetails}>
      <div className={styles.sizeTitle}>{title}</div>
      <div className={styles.sizeGrid}>
        <div className={styles.sizeItem}>
          <span className={styles.sizeLabel}>Content Rect:</span>
          <span className={styles.sizeValue}>{info.width} × {info.height}</span>
        </div>
        {info.contentBoxSize && (
          <div className={styles.sizeItem}>
            <span className={styles.sizeLabel}>Content Box:</span>
            <span className={styles.sizeValue}>
              {Math.round(info.contentBoxSize.inlineSize)} × {Math.round(info.contentBoxSize.blockSize)}
            </span>
          </div>
        )}
        {info.borderBoxSize && (
          <div className={styles.sizeItem}>
            <span className={styles.sizeLabel}>Border Box:</span>
            <span className={styles.sizeValue}>
              {Math.round(info.borderBoxSize.inlineSize)} × {Math.round(info.borderBoxSize.blockSize)}
            </span>
          </div>
        )}
        {info.devicePixelContentBoxSize && (
          <div className={styles.sizeItem}>
            <span className={styles.sizeLabel}>Device Pixel:</span>
            <span className={styles.sizeValue}>
              {Math.round(info.devicePixelContentBoxSize.inlineSize)} × {Math.round(info.devicePixelContentBoxSize.blockSize)}
            </span>
          </div>
        )}
      </div>
    </div>
  );

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>ResizeObserver API</div>
          <div className={styles.componentBlock}>
            
            {/* Resizeable Container */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Resizeable Container</div>
              <div className={styles.itemDesc}>Drag the bottom-right corner to resize</div>
              <div
                ref={resizeableRef}
                className={styles.resizeableContainer}
              >
                <div className={styles.resizeHandle}></div>
                <div className={styles.containerContent}>
                  <div className={styles.dynamicText}>
                    Current Size: {resizeableInfo.width} × {resizeableInfo.height} px
                  </div>
                  <div className={styles.aspectRatio}>
                    Aspect Ratio: {resizeableInfo.width && resizeableInfo.height 
                      ? (resizeableInfo.width / resizeableInfo.height).toFixed(2) 
                      : '1.00'}
                  </div>
                </div>
              </div>
              {renderSizeDetails(resizeableInfo, 'Resizeable Container Details')}
            </div>

            {/* Resizeable Textarea */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Resizeable Textarea</div>
              <div className={styles.itemDesc}>Textarea with resize handle - observe dimension changes</div>
              <textarea
                ref={textareaRef}
                className={styles.resizeableTextarea}
                placeholder="Resize me by dragging the corner..."
                defaultValue="This textarea can be resized by the user. The ResizeObserver tracks its dimension changes in real-time."
              />
              {renderSizeDetails(textareaInfo, 'Textarea Details')}
            </div>

            {/* Observer Activity Log */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Observer Activity</div>
              <div className={styles.itemDesc}>Real-time log of resize events (last 20 entries)</div>
              <div className={styles.activityLog}>
                {observerEntries.map((entry, index) => (
                  <div key={index} className={styles.logEntry}>
                    <span className={styles.logTime}>
                      {new Date().toLocaleTimeString()}
                    </span>
                    <span className={styles.logMessage}>{entry}</span>
                  </div>
                ))}
                {observerEntries.length === 0 && (
                  <div className={styles.logEmpty}>Resize any element above to see activity...</div>
                )}
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};