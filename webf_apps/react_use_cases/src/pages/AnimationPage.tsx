import React, { useState } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './AnimationPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

export const AnimationPage: React.FC = () => {
  const [isPlaying, setIsPlaying] = useState<{[key: string]: boolean}>({});

  const toggleAnimation = (animationType: string) => {
    setIsPlaying(prev => ({
      ...prev,
      [animationType]: !prev[animationType]
    }));
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>CSS Animations Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Fade Animation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Fade Animation</div>
              <div className={styles.itemDesc}>Simple fade in/out animation using opacity</div>
              <div className={styles.animationContainer}>
                <div 
                  className={`${styles.animationBox} ${styles.fadeBox} ${isPlaying.fade ? styles.fadeIn : styles.fadeOut}`}
                >
                  Fade
                </div>
                <button 
                  className={styles.controlButton}
                  onClick={() => toggleAnimation('fade')}
                >
                  {isPlaying.fade ? 'Fade Out' : 'Fade In'}
                </button>
              </div>
            </div>

            {/* Slide Animation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Slide Animation</div>
              <div className={styles.itemDesc}>Transform-based sliding animation</div>
              <div className={styles.animationContainer}>
                <div 
                  className={`${styles.animationBox} ${styles.slideBox} ${isPlaying.slide ? styles.slideIn : styles.slideOut}`}
                >
                  Slide
                </div>
                <button 
                  className={styles.controlButton}
                  onClick={() => toggleAnimation('slide')}
                >
                  {isPlaying.slide ? 'Slide Out' : 'Slide In'}
                </button>
              </div>
            </div>

            {/* Scale Animation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Scale Animation</div>
              <div className={styles.itemDesc}>Scale transformation with smooth transition</div>
              <div className={styles.animationContainer}>
                <div 
                  className={`${styles.animationBox} ${styles.scaleBox} ${isPlaying.scale ? styles.scaleUp : styles.scaleDown}`}
                >
                  Scale
                </div>
                <button 
                  className={styles.controlButton}
                  onClick={() => toggleAnimation('scale')}
                >
                  {isPlaying.scale ? 'Scale Down' : 'Scale Up'}
                </button>
              </div>
            </div>

            {/* Rotate Animation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Rotate Animation</div>
              <div className={styles.itemDesc}>Continuous rotation animation</div>
              <div className={styles.animationContainer}>
                <div 
                  className={`${styles.animationBox} ${styles.rotateBox} ${isPlaying.rotate ? styles.rotating : ''}`}
                >
                  Rotate
                </div>
                <button 
                  className={styles.controlButton}
                  onClick={() => toggleAnimation('rotate')}
                >
                  {isPlaying.rotate ? 'Stop' : 'Rotate'}
                </button>
              </div>
            </div>

            {/* Bounce Animation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Bounce Animation</div>
              <div className={styles.itemDesc}>Bouncing animation with keyframes</div>
              <div className={styles.animationContainer}>
                <div 
                  className={`${styles.animationBox} ${styles.bounceBox} ${isPlaying.bounce ? styles.bouncing : ''}`}
                >
                  Bounce
                </div>
                <button 
                  className={styles.controlButton}
                  onClick={() => toggleAnimation('bounce')}
                >
                  {isPlaying.bounce ? 'Stop' : 'Bounce'}
                </button>
              </div>
            </div>

            {/* Pulse Animation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Pulse Animation</div>
              <div className={styles.itemDesc}>Pulsing effect with scale and opacity</div>
              <div className={styles.animationContainer}>
                <div 
                  className={`${styles.animationBox} ${styles.pulseBox} ${isPlaying.pulse ? styles.pulsing : ''}`}
                >
                  Pulse
                </div>
                <button 
                  className={styles.controlButton}
                  onClick={() => toggleAnimation('pulse')}
                >
                  {isPlaying.pulse ? 'Stop' : 'Pulse'}
                </button>
              </div>
            </div>

            {/* Combined Animation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Combined Animation</div>
              <div className={styles.itemDesc}>Multiple transform properties combined</div>
              <div className={styles.animationContainer}>
                <div 
                  className={`${styles.animationBox} ${styles.combinedBox} ${isPlaying.combined ? styles.combined : ''}`}
                >
                  Combined
                </div>
                <button 
                  className={styles.controlButton}
                  onClick={() => toggleAnimation('combined')}
                >
                  {isPlaying.combined ? 'Reset' : 'Animate'}
                </button>
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};