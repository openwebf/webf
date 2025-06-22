import React, { useRef, useState } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './NativeInteractionPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});


export const NativeInteractionPage: React.FC = () => {
  const [screenshotResult, setScreenshotResult] = useState<string>('');
  const [shareResult, setShareResult] = useState<string>('');
  const [shareImage, setShareImage] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState<{[key: string]: boolean}>({});
  const screenshotTargetRef = useRef<HTMLDivElement>(null);
  const shareTargetRef = useRef<HTMLDivElement>(null);

  // Helper function to create displayable URL from blob
  const createDisplayableUrl = async (blob: Blob, fallbackPrefix = 'preview'): Promise<string> => {
    if (typeof URL !== 'undefined' && URL.createObjectURL) {
      return URL.createObjectURL(blob);
    } else if (typeof FileReader !== 'undefined') {
      // Fallback: convert blob to base64 data URL using FileReader
      return new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result as string);
        reader.readAsDataURL(blob);
      });
    } else {
      // Last resort: save to native and get file path
      console.warn('URL.createObjectURL and FileReader not available, trying native save for preview');
      try {
        const arrayBuffer = await blob.arrayBuffer();
        if (window.webf?.invokeModuleAsync) {
          const result = await window.webf.invokeModuleAsync(
            'Screenshot',
            'saveForPreview',
            arrayBuffer,
            `${fallbackPrefix}_${Date.now()}`
          ) as { filePath?: string };
          if (result && result.filePath) {
            return result.filePath;
          } else {
            console.log('Image saved but no preview path returned');
            return '';
          }
        }
        return '';
      } catch (error) {
        console.error('Failed to save image for preview:', error);
        return '';
      }
    }
  };



  const saveScreenshotToLocal = async (targetRef: React.RefObject<HTMLDivElement | null>, resultSetter: (result: string) => void) => {
    setIsProcessing(prev => ({...prev, saveScreenshot: true}));
    
    // Add a small delay to ensure UI is ready
    await new Promise(resolve => setTimeout(resolve, 200));
    
    try {
      if (!targetRef.current) {
        throw new Error('Target element not found');
      }

      // Get the element for screenshot
      const element = targetRef.current;
      
      // Convert element to blob with device pixel ratio
      if (typeof (element as any).toBlob !== 'function') {
        throw new Error('toBlob method not available on this element');
      }

      const blob = await (element as any).toBlob(window.devicePixelRatio || 1.0);
      
      // Convert to arrayBuffer for native method
      const arrayBuffer = await blob.arrayBuffer();

      // Check if WebF and invokeModuleAsync are available
      if (!window.webf?.invokeModuleAsync) {
        throw new Error('WebF native module not available');
      }

      const filename = 'Screenshot_' + Date.now();
      
      // Call native screenshot save module
      const result = await window.webf.invokeModuleAsync(
        'Share',
        'save',
        arrayBuffer,
        filename
      ) as { success?: string; filePath?: string; message?: string } | boolean;

      console.log('Save screenshot result:', result);
      
      if (result === true || (typeof result === 'object' && result.success === 'true')) {
        if (typeof result === 'object' && result.filePath) {
          resultSetter(`Screenshot saved successfully!\nPath: ${result.filePath}`);
        } else {
          resultSetter(`Screenshot saved successfully as: ${filename}.png`);
        }
      } else {
        const errorMsg = typeof result === 'object' && result.message 
          ? result.message 
          : 'Failed to save screenshot to device';
        resultSetter(errorMsg);
      }
    } catch (error) {
      console.error('Save screenshot failed:', error);
      resultSetter(`Save screenshot failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsProcessing(prev => ({...prev, saveScreenshot: false}));
    }
  };

  const shareContent = async (targetRef: React.RefObject<HTMLDivElement | null>, resultSetter: (result: string) => void) => {
    setIsProcessing(prev => ({...prev, share: true}));
    // Clear previous results
    setShareResult('');
    setShareImage('');
    
    // Add a small delay to ensure UI is ready
    await new Promise(resolve => setTimeout(resolve, 200));
    
    try {
      if (!targetRef.current) {
        throw new Error('Target element not found');
      }

      // Get the element for sharing
      const element = targetRef.current;
      
      // Convert element to blob with device pixel ratio
      if (typeof (element as any).toBlob !== 'function') {
        throw new Error('toBlob method not available on this element');
      }

      const blob = await (element as any).toBlob(window.devicePixelRatio || 1.0);
      
      // Create a URL for the blob to display it
      const blobUrl = await createDisplayableUrl(blob, 'share');
      setShareImage(blobUrl);
      
      // Convert to arrayBuffer for native method
      const arrayBuffer = await blob.arrayBuffer();

      // Check if WebF and invokeModuleAsync are available
      if (!window.webf?.invokeModuleAsync) {
        // If no native module, show the image
        resultSetter('Image captured for sharing (displayed below)');
        return;
      }

      const title = 'WebF React Demo';
      const subject = 'Check out this awesome WebF demo! Built with React and WebF for seamless native integration.';
      
      // Call native share module
      const result = await window.webf.invokeModuleAsync(
        'Share',
        'share',
        arrayBuffer,
        title,
        subject
      );

      console.log('Share result:', result);
      resultSetter('Content shared successfully');
    } catch (error) {
      console.error('Share failed:', error);
      resultSetter(`Share failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsProcessing(prev => ({...prev, share: false}));
    }
  };

  const shareTextOnly = async () => {
    setIsProcessing(prev => ({...prev, textShare: true}));
    try {
      if (!window.webf?.invokeModuleAsync) {
        throw new Error('WebF native module not available');
      }

      const title = 'WebF React Demo';
      const text = 'This is a text-only share from the WebF React demo application. WebF enables seamless integration between React and Flutter native capabilities. Visit: https://github.com/openwebf/webf';
      
      const result = await window.webf.invokeModuleAsync(
        'Share',
        'shareText',
        title,
        text
      );

      console.log('Text share result:', result);
      if (result) {
        setShareResult('Text shared successfully');
      } else {
        setShareResult('Failed to share text');
      }
    } catch (error) {
      console.error('Text share failed:', error);
      setShareResult(`Text share failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsProcessing(prev => ({...prev, textShare: false}));
    }
  };



  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Native Interaction Showcase</div>
          <div className={styles.componentBlock}>
            


            {/* Screenshot Save Demo */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Save Screenshot to Device</div>
              <div className={styles.itemDesc}>Capture and save DOM elements directly to device storage</div>
              <div className={styles.actionContainer}>
                <div ref={screenshotTargetRef} className={styles.screenshotTarget}>
                  <div className={styles.targetContent}>
                    <h3>📸 Screenshot Target Area</h3>
                    <p>This is the content that will be captured and saved to your device.</p>
                    <div className={styles.sampleContent}>
                      <div className={styles.colorBox} style={{backgroundColor: '#ff6b6b'}}>Red</div>
                      <div className={styles.colorBox} style={{backgroundColor: '#4ecdc4'}}>Teal</div>
                      <div className={styles.colorBox} style={{backgroundColor: '#45b7d1'}}>Blue</div>
                      <div className={styles.colorBox} style={{backgroundColor: '#96ceb4'}}>Green</div>
                    </div>
                    <p>Timestamp: {new Date().toLocaleString()}</p>
                  </div>
                </div>
                <button 
                  className={`${styles.actionButton} ${isProcessing.saveScreenshot ? styles.processing : ''}`}
                  onClick={() => saveScreenshotToLocal(screenshotTargetRef, setScreenshotResult)}
                  disabled={isProcessing.saveScreenshot}
                >
                  {isProcessing.saveScreenshot ? 'Saving...' : 'Save to Device'}
                </button>
                {screenshotResult && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Save Result:</div>
                    <div className={styles.resultText}>{screenshotResult}</div>
                  </div>
                )}
              </div>
            </div>

            {/* Share with Screenshot Demo */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Share with Screenshot</div>
              <div className={styles.itemDesc}>Share DOM element content as image through native share functionality</div>
              <div className={styles.actionContainer}>
                <div ref={shareTargetRef} className={styles.shareTarget}>
                  <div className={styles.targetContent}>
                    <h3>🚀 WebF React Demo</h3>
                    <p>Demonstrating seamless integration between React and Flutter native capabilities.</p>
                    <div className={styles.featureGrid}>
                      <div className={styles.featureItem}>
                        <span className={styles.featureIcon}>⚡</span>
                        <span>Fast Performance</span>
                      </div>
                      <div className={styles.featureItem}>
                        <span className={styles.featureIcon}>🔄</span>
                        <span>Native Integration</span>
                      </div>
                      <div className={styles.featureItem}>
                        <span className={styles.featureIcon}>📱</span>
                        <span>Cross Platform</span>
                      </div>
                      <div className={styles.featureItem}>
                        <span className={styles.featureIcon}>🎨</span>
                        <span>Rich UI</span>
                      </div>
                    </div>
                    <p className={styles.shareNote}>Share this awesome demo!</p>
                  </div>
                </div>
                <div className={styles.buttonGroup}>
                  <button 
                    className={`${styles.actionButton} ${isProcessing.share ? styles.processing : ''}`}
                    onClick={() => shareContent(shareTargetRef, setShareResult)}
                    disabled={isProcessing.share}
                  >
                    {isProcessing.share ? 'Sharing...' : 'Share as Image'}
                  </button>
                  <button 
                    className={`${styles.actionButton} ${styles.secondaryButton} ${isProcessing.textShare ? styles.processing : ''}`}
                    onClick={shareTextOnly}
                    disabled={isProcessing.textShare}
                  >
                    {isProcessing.textShare ? 'Sharing...' : 'Share Text Only'}
                  </button>
                </div>
                {(shareResult || shareImage) && (
                  <div className={styles.resultContainer}>
                    {shareResult && (
                      <>
                        <div className={styles.resultLabel}>Status:</div>
                        <div className={styles.resultText}>{shareResult}</div>
                      </>
                    )}
                    {shareImage && (
                      <>
                        <div className={styles.resultLabel}>Image to Share:</div>
                        <div className={styles.imagePreview}>
                          <img 
                            src={shareImage} 
                            alt="Share preview" 
                            className={styles.previewImage}
                          />
                        </div>
                      </>
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};