import React, { useEffect, useState } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './ImagePreloadPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

export const ImagePreloadPage: React.FC = () => {
  const [loadTimes, setLoadTimes] = useState<{ preload: number | null; normal: number | null }>({
    preload: null,
    normal: null
  });

  // 预加载的图片（在 index.html 中配置的）
  const preloadedImageUrl = 'https://picsum.photos/800/600?image=1015';
  // 普通图片（没有预加载）
  const normalImageUrl = 'https://picsum.photos/800/600?image=1016';

  useEffect(() => {
    // 测试预加载图片的加载时间
    const startTime1 = performance.now();
    const img1 = new Image();
    img1.onload = () => {
      const endTime1 = performance.now();
      setLoadTimes(prev => ({ ...prev, preload: endTime1 - startTime1 }));
    };
    img1.src = preloadedImageUrl;

    // 测试普通图片的加载时间
    const startTime2 = performance.now();
    const img2 = new Image();
    img2.onload = () => {
      const endTime2 = performance.now();
      setLoadTimes(prev => ({ ...prev, normal: endTime2 - startTime2 }));
    };
    img2.src = normalImageUrl;
  }, []);

  const getDifference = () => {
    if (loadTimes.preload && loadTimes.normal) {
      const diff = loadTimes.normal - loadTimes.preload;
      return diff > 0 ? `${diff.toFixed(0)}ms faster` : 'No significant difference';
    }
    return 'Loading...';
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.container}>
          <h1 className={styles.title}>Image Preload Performance Test</h1>
          
          <div className={styles.description}>
            <p>This demo shows two similar images loading - one with preload, one without.</p>
            <p>The first image is preloaded in the HTML head, the second loads normally.</p>
          </div>

          <div className={styles.results}>
            <div className={styles.resultCard}>
              <h3>With Preload</h3>
              <p className={styles.resultDesc}>Preloaded in HTML head</p>
              <div className={styles.imageContainer}>
                <img 
                  src={preloadedImageUrl} 
                  className={styles.testImage}
                  alt="Preloaded image"
                />
              </div>
              <div className={styles.loadTime}>
                Load time: {loadTimes.preload ? `${loadTimes.preload.toFixed(0)}ms` : 'Loading...'}
              </div>
            </div>

            <div className={styles.resultCard}>
              <h3>Without Preload</h3>
              <p className={styles.resultDesc}>Normal loading</p>
              <div className={styles.imageContainer}>
                <img 
                  src={normalImageUrl} 
                  className={styles.testImage}
                  alt="Normal image"
                />
              </div>
              <div className={styles.loadTime}>
                Load time: {loadTimes.normal ? `${loadTimes.normal.toFixed(0)}ms` : 'Loading...'}
              </div>
            </div>
          </div>

          <div className={styles.comparison}>
            <h3>Result</h3>
            <p>Preload improvement: {getDifference()}</p>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};