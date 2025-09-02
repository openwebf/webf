import React, { useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './ThemeTogglePage.module.css';

export const ThemeTogglePage: React.FC = () => {
  const [currentTheme, setCurrentTheme] = useState<'light' | 'dark'>('light');
  const [isToggling, setIsToggling] = useState(false);
  const [toggleResult, setToggleResult] = useState<string>('');

  useEffect(() => {
    // Get current theme from Flutter on component mount
    getCurrentThemeFromFlutter();
  }, []);

  const getCurrentThemeFromFlutter = async () => {
    try {
      if (window.webf?.methodChannel?.invokeMethod) {
        const result = await window.webf.methodChannel.invokeMethod('getCurrentTheme') as any;
        
        if (result.success) {
          setCurrentTheme(result.currentTheme);
        }
      }
    } catch (error) {
      console.error('Failed to get current theme:', error);
      // Fallback to light theme if unable to get from Flutter
      setCurrentTheme('light');
    }
  };

  const toggleTheme = async () => {
    setIsToggling(true);
    setToggleResult('');

    try {
      const result = await window.webf.methodChannel.invokeMethod('toggleTheme', {
        targetTheme: currentTheme === 'light' ? 'dark' : 'light'
      });
      
      setToggleResult(`Theme toggled via methodChannel: ${JSON.stringify(result)}`);
      
      // Get updated theme from Flutter to ensure sync
      await getCurrentThemeFromFlutter();
    } catch (error) {
      console.error('Theme toggle failed:', error);
      setToggleResult(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsToggling(false);
    }
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Theme Toggle Demo</div>
          <div className={styles.sectionDescription}>
            Demonstrate WebF application's theme switching capabilities: toggling between dark and light modes
          </div>
          <div className={styles.componentBlock}>
            
            {/* Current Theme Display */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Current Theme</div>
              <div className={styles.itemDesc}>Display the currently active theme mode</div>
              <div className={styles.themeContainer}>
                <div className={styles.themeDisplay}>
                  <div className={styles.themeIcon}>
                    {currentTheme === 'light' ? '☀️' : '🌙'}
                  </div>
                  <div className={styles.themeInfo}>
                    <div className={styles.themeName}>
                      {currentTheme === 'light' ? 'Light Mode' : 'Dark Mode'}
                    </div>
                    <div className={styles.themeDesc}>
                      {currentTheme === 'light' 
                        ? 'Bright theme for daytime use' 
                        : 'Dark theme for nighttime use'
                      }
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Theme Toggle Button */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Theme Toggle Control</div>
              <div className={styles.itemDesc}>
                Switch between light and dark themes
              </div>
              <div className={styles.toggleContainer}>
                <button 
                  className={`${styles.toggleButton} ${styles[currentTheme]} ${isToggling ? styles.toggling : ''}`}
                  onClick={toggleTheme}
                  disabled={isToggling}
                >
                  <div className={styles.buttonContent}>
                    <span className={styles.buttonIcon}>
                      {isToggling ? '🔄' : currentTheme === 'light' ? '🌙' : '☀️'}
                    </span>
                    <span className={styles.buttonText}>
                      {isToggling 
                        ? 'Switching...' 
                        : `Switch to ${currentTheme === 'light' ? 'Dark' : 'Light'} Mode`
                      }
                    </span>
                  </div>
                </button>

                {toggleResult && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Toggle Result:</div>
                    <div className={styles.resultText}>{toggleResult}</div>
                  </div>
                )}
              </div>
            </div>

            {/* Theme Preview */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Theme Preview</div>
              <div className={styles.itemDesc}>
                Visual demonstration of how different UI elements appear in the current theme
              </div>
              <div className={styles.previewContainer}>
                <div className={styles.previewCard}>
                  <div className={styles.previewHeader}>Sample Card</div>
                  <div className={styles.previewContent}>
                    <p>This is how text appears in {currentTheme} mode.</p>
                    <button className={styles.previewButton}>Sample Button</button>
                  </div>
                </div>
                
                <div className={styles.colorPalette}>
                  <div className={styles.paletteTitle}>Color Palette</div>
                  <div className={styles.colorGrid}>
                    <div className={styles.colorItem}>
                      <div className={styles.colorSwatch} style={{backgroundColor: 'var(--primary-color, #007aff)'}}></div>
                      <span>Primary</span>
                    </div>
                    <div className={styles.colorItem}>
                      <div className={styles.colorSwatch} style={{backgroundColor: 'var(--background-color, #ffffff)'}}></div>
                      <span>Background</span>
                    </div>
                    <div className={styles.colorItem}>
                      <div className={styles.colorSwatch} style={{backgroundColor: 'var(--text-color, #333333)'}}></div>
                      <span>Text</span>
                    </div>
                    <div className={styles.colorItem}>
                      <div className={styles.colorSwatch} style={{backgroundColor: 'var(--border-color, #e5e5e5)'}}></div>
                      <span>Border</span>
                    </div>
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