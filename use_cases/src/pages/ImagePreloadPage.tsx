import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './ImagePreloadPage.module.css';

export const ImagePreloadPage: React.FC = () => {
  // Generate 100 small image URLs
  const generateImageUrls = () => {
    const urls: { url: string; isPreloaded: boolean; id: number }[] = [];
    
    // 50 preloaded images (using image ID 1-50)
    for (let i = 1; i <= 50; i++) {
      urls.push({
        id: i,
        url: `https://picsum.photos/80/80?image=${i}`,
        isPreloaded: true
      });
    }
    
    // 50 normal loading images (using image ID 51-100)
    for (let i = 51; i <= 100; i++) {
      urls.push({
        id: i,
        url: `https://picsum.photos/80/80?image=${i}`,
        isPreloaded: false
      });
    }
    
    return urls;
  };

  const imageUrls = generateImageUrls();

  return (
    <div id="main">
      <WebFListView className={`${styles.list} ${styles.container}`}>
          <h1 className={styles.title}>Image Preload Performance Test</h1>
          
          <div className={styles.description}>
            <p>100 images loading comparison demo - Observe the loading speed difference between left and right sides</p>
            <p>Left half: Preloaded images (1-50) | Right half: Normal loading images (51-100)</p>
          </div>

          <div className={styles.imageDisplay}>
            <div className={styles.imageSection}>
              <h3 className={styles.sectionTitle}>Preloaded (1-50)</h3>
              <WebFListView className={`${styles.scrollContainer} ${styles.imageGrid}`}>
                  {imageUrls
                    .filter(img => img.isPreloaded)
                    .map(img => (
                      <div key={img.id} className={styles.imageItem}>
                        <img 
                          src={img.url}
                          alt={`Preloaded ${img.id}`}
                          className={styles.testImage}
                        />
                        <span className={styles.imageNumber}>{img.id}</span>
                      </div>
                    ))
                  }
              </WebFListView>
            </div>

            <div className={styles.imageSection}>
              <h3 className={styles.sectionTitle}>Normal Loading (51-100)</h3>
              <WebFListView className={`${styles.scrollContainer} ${styles.imageGrid}`}>
                  {imageUrls
                    .filter(img => !img.isPreloaded)
                    .map(img => (
                      <div key={img.id} className={styles.imageItem}>
                        <img 
                          src={img.url}
                          alt={`Normal ${img.id}`}
                          className={styles.testImage}
                        />
                        <span className={styles.imageNumber}>{img.id}</span>
                      </div>
                    ))
                  }
              </WebFListView>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};