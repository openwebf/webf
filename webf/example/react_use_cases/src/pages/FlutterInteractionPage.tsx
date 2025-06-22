import React, { useState } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './FlutterInteractionPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});


export const FlutterInteractionPage: React.FC = () => {
  const [results, setResults] = useState<{[key: string]: string}>({});
  const [isProcessing, setIsProcessing] = useState<{[key: string]: boolean}>({});
  // const fileInputRef = useRef<HTMLInputElement>(null); // Removed unused ref

  const updateResult = (key: string, result: string) => {
    setResults(prev => ({...prev, [key]: result}));
  };

  const setProcessing = (key: string, processing: boolean) => {
    setIsProcessing(prev => ({...prev, [key]: processing}));
  };

  // Test basic method channel communication
  const testBasicCommunication = async () => {
    setProcessing('basic', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const testData = {
        message: 'Hello from React!',
        timestamp: Date.now(),
        data: [1, 2, 3, 4, 5]
      };

      const result = await window.webf.methodChannel.invokeMethod('testEcho', testData) as any;
      
      // Format the echo result for better display
      if (typeof result === 'object' && result?.success) {
        const formatted = [
          `✅ Echo successful!`,
          `📝 Message: "${result.message}"`,
          `⏰ Sent at: ${new Date(testData.timestamp).toLocaleTimeString()}`,
          `🕐 Received at: ${new Date(result.timestamp).toLocaleTimeString()}`,
          `📊 Data echoed: [${result.receivedData?.join(', ')}]`,
          `🔄 Processed by: ${result.processedBy}`
        ].join('\n');
        updateResult('basic', formatted);
      } else {
        updateResult('basic', `Echo response: ${JSON.stringify(result)}`);
      }
    } catch (error) {
      updateResult('basic', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('basic', false);
    }
  };

  // Test device information retrieval
  const getDeviceInfo = async () => {
    setProcessing('device', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const result = await window.webf.methodChannel.invokeMethod('getDeviceInfo') as any;
      updateResult('device', `Device info: ${JSON.stringify(result, null, 2)}`);
    } catch (error) {
      updateResult('device', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('device', false);
    }
  };

  // Test Flutter dialog
  const showFlutterDialog = async () => {
    setProcessing('dialog', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const result = await window.webf.methodChannel.invokeMethod('showDialog', {
        title: 'Hello from React',
        message: 'This dialog is shown using Flutter widgets from React code!',
        buttons: ['OK', 'Cancel']
      }) as any;
      updateResult('dialog', `Dialog result: ${JSON.stringify(result)}`);
    } catch (error) {
      updateResult('dialog', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('dialog', false);
    }
  };

  // Test Flutter snackbar
  const showFlutterSnackbar = async () => {
    setProcessing('snackbar', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const result = await window.webf.methodChannel.invokeMethod('showSnackbar', {
        message: 'Snackbar triggered from React!',
        duration: 3000,
        action: 'Undo'
      }) as any;
      updateResult('snackbar', `Snackbar shown: ${JSON.stringify(result)}`);
    } catch (error) {
      updateResult('snackbar', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('snackbar', false);
    }
  };

  // Test file picker
  const openFilePicker = async () => {
    setProcessing('filePicker', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const result = await window.webf.methodChannel.invokeMethod('pickFile', {
        type: 'image',
        allowMultiple: false
      }) as any;
      updateResult('filePicker', `File picked: ${JSON.stringify(result)}`);
    } catch (error) {
      updateResult('filePicker', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('filePicker', false);
    }
  };

  // Test camera
  const openCamera = async () => {
    setProcessing('camera', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const result = await window.webf.methodChannel.invokeMethod('openCamera', {
        quality: 0.8,
        maxWidth: 1024,
        maxHeight: 1024
      }) as any;
      
      // Format camera result for better display
      if (typeof result === 'object' && result?.success && result?.image) {
        const formatted = [
          `📷 ${result.note ? 'Image Selected' : 'Photo Captured'} Successfully!`,
          `📁 File: ${result.image.name}`,
          `📍 Path: ${result.image.path}`,
          `🗂️ Type: ${result.image.mimeType}`,
          `⏰ Time: ${new Date(result.timestamp).toLocaleString()}`,
          `💻 Platform: ${result.platform}`,
          result.note ? `ℹ️ Note: ${result.note}` : ''
        ].filter(line => line).join('\n');
        updateResult('camera', formatted);
      } else if (typeof result === 'object' && result?.cancelled) {
        updateResult('camera', `📷 ${result.platform === 'macOS' ? 'Image selection' : 'Camera'} cancelled by user\nPlatform: ${result.platform}`);
      } else {
        updateResult('camera', `Camera result: ${JSON.stringify(result)}`);
      }
    } catch (error) {
      updateResult('camera', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('camera', false);
    }
  };

  // Test preferences
  const testPreferences = async () => {
    setProcessing('preferences', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      // Set a preference
      await window.webf.methodChannel.invokeMethod('setPreference', {
        key: 'user_setting',
        value: 'React WebF Demo Setting'
      });

      // Get the preference back
      const result = await window.webf.methodChannel.invokeMethod('getPreference', {
        key: 'user_setting'
      }) as any;

      updateResult('preferences', `Preference value: ${JSON.stringify(result)}`);
    } catch (error) {
      updateResult('preferences', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('preferences', false);
    }
  };

  // Test vibration
  const testVibration = async () => {
    setProcessing('vibration', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const result = await window.webf.methodChannel.invokeMethod('vibrate', {
        duration: 500,
        pattern: [100, 200, 100, 200]
      }) as any;
      updateResult('vibration', `Vibration triggered: ${JSON.stringify(result)}`);
    } catch (error) {
      updateResult('vibration', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('vibration', false);
    }
  };

  // Test clipboard
  const testClipboard = async () => {
    setProcessing('clipboard', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const textToClip = 'Hello from WebF React Demo! This text was copied to clipboard via Flutter.';
      
      await window.webf.methodChannel.invokeMethod('copyToClipboard', {
        text: textToClip
      });

      const result = await window.webf.methodChannel.invokeMethod('getFromClipboard') as any;
      updateResult('clipboard', `Clipboard content: ${JSON.stringify(result)}`);
    } catch (error) {
      updateResult('clipboard', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('clipboard', false);
    }
  };

  // Test sending data to Flutter
  const sendDataToFlutter = async () => {
    setProcessing('dataTransfer', true);
    try {
      if (!window.webf?.methodChannel) {
        throw new Error('WebF method channel not available');
      }

      const complexData = {
        user: {
          id: 12345,
          name: 'John Doe',
          email: 'john@example.com'
        },
        settings: {
          theme: 'dark',
          notifications: true,
          language: 'en'
        },
        metrics: {
          pageViews: 1250,
          clickThrough: 0.075,
          performance: [
            { metric: 'loadTime', value: 1.2 },
            { metric: 'renderTime', value: 0.8 },
            { metric: 'interactivity', value: 2.1 }
          ]
        }
      };

      const result = await window.webf.methodChannel.invokeMethod('processComplexData', complexData) as any;
      
      // Format the result for better display
      if (typeof result === 'object' && result?.success && result?.analysis) {
        const formatted = [
          `✅ Data processed successfully by ${result.platform}`,
          `⏱️ Processing time: ${result.processingTime}`,
          `📊 Analysis Results:`,
          result.analysis.userStats ? `  👤 User: ${result.analysis.userStats.name} (${result.analysis.userStats.domain})` : '  👤 No user data',
          result.analysis.settingsAnalysis ? `  ⚙️ Settings: ${result.analysis.settingsAnalysis.theme} theme, ${result.analysis.settingsAnalysis.totalSettings} configs` : '  ⚙️ No settings',
          result.analysis.metricsAnalysis ? `  📈 Metrics: ${result.analysis.metricsAnalysis.pageViews} views, ${result.analysis.metricsAnalysis.avgPerformance.toFixed(2)}s avg performance` : '  📈 No metrics',
          `💡 Recommendations:`,
          ...result.recommendations?.map((rec: string) => `  • ${rec}`) || []
        ].join('\n');
        updateResult('dataTransfer', formatted);
      } else {
        updateResult('dataTransfer', `Data processed: ${JSON.stringify(result)}`);
      }
    } catch (error) {
      updateResult('dataTransfer', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setProcessing('dataTransfer', false);
    }
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Flutter Interaction Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Communication */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Method Channel Communication</div>
              <div className={styles.itemDesc}>Test basic bidirectional communication between React and Flutter</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isProcessing.basic ? styles.processing : ''}`}
                  onClick={testBasicCommunication}
                  disabled={isProcessing.basic}
                >
                  {isProcessing.basic ? 'Testing...' : 'Test Echo Communication'}
                </button>
                {results.basic && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Result:</div>
                    <div className={styles.resultText}>{results.basic}</div>
                  </div>
                )}
              </div>
            </div>

            {/* Device Information */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Device Information</div>
              <div className={styles.itemDesc}>Retrieve device information from Flutter platform APIs</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isProcessing.device ? styles.processing : ''}`}
                  onClick={getDeviceInfo}
                  disabled={isProcessing.device}
                >
                  {isProcessing.device ? 'Getting Info...' : 'Get Device Info'}
                </button>
                {results.device && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Device Information:</div>
                    <pre className={styles.resultText}>{results.device}</pre>
                  </div>
                )}
              </div>
            </div>

            {/* Flutter UI Components */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Flutter UI Components</div>
              <div className={styles.itemDesc}>Trigger native Flutter dialogs and snackbars from React</div>
              <div className={styles.actionContainer}>
                <div className={styles.buttonGroup}>
                  <button 
                    className={`${styles.actionButton} ${isProcessing.dialog ? styles.processing : ''}`}
                    onClick={showFlutterDialog}
                    disabled={isProcessing.dialog}
                  >
                    {isProcessing.dialog ? 'Showing...' : 'Show Flutter Dialog'}
                  </button>
                  <button 
                    className={`${styles.actionButton} ${styles.secondaryButton} ${isProcessing.snackbar ? styles.processing : ''}`}
                    onClick={showFlutterSnackbar}
                    disabled={isProcessing.snackbar}
                  >
                    {isProcessing.snackbar ? 'Showing...' : 'Show Snackbar'}
                  </button>
                </div>
                {(results.dialog || results.snackbar) && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>UI Component Results:</div>
                    {results.dialog && <div className={styles.resultText}>Dialog: {results.dialog}</div>}
                    {results.snackbar && <div className={styles.resultText}>Snackbar: {results.snackbar}</div>}
                  </div>
                )}
              </div>
            </div>

            {/* File and Camera Access */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>File System & Camera Access</div>
              <div className={styles.itemDesc}>Access device file system and camera through Flutter</div>
              <div className={styles.actionContainer}>
                <div className={styles.buttonGroup}>
                  <button 
                    className={`${styles.actionButton} ${isProcessing.filePicker ? styles.processing : ''}`}
                    onClick={openFilePicker}
                    disabled={isProcessing.filePicker}
                  >
                    {isProcessing.filePicker ? 'Opening...' : 'Pick File'}
                  </button>
                  <button 
                    className={`${styles.actionButton} ${styles.secondaryButton} ${isProcessing.camera ? styles.processing : ''}`}
                    onClick={openCamera}
                    disabled={isProcessing.camera}
                  >
                    {isProcessing.camera ? 'Opening...' : 'Open Camera'}
                  </button>
                </div>
                {(results.filePicker || results.camera) && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>File/Camera Results:</div>
                    {results.filePicker && <div className={styles.resultText}>File Picker: {results.filePicker}</div>}
                    {results.camera && <div className={styles.resultText}>Camera: {results.camera}</div>}
                  </div>
                )}
              </div>
            </div>

            {/* Device Features */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Device Features</div>
              <div className={styles.itemDesc}>Access device-specific features like vibration and clipboard</div>
              <div className={styles.actionContainer}>
                <div className={styles.buttonGroup}>
                  <button 
                    className={`${styles.actionButton} ${isProcessing.vibration ? styles.processing : ''}`}
                    onClick={testVibration}
                    disabled={isProcessing.vibration}
                  >
                    {isProcessing.vibration ? 'Vibrating...' : 'Test Vibration'}
                  </button>
                  <button 
                    className={`${styles.actionButton} ${styles.secondaryButton} ${isProcessing.clipboard ? styles.processing : ''}`}
                    onClick={testClipboard}
                    disabled={isProcessing.clipboard}
                  >
                    {isProcessing.clipboard ? 'Processing...' : 'Test Clipboard'}
                  </button>
                </div>
                {(results.vibration || results.clipboard) && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Device Feature Results:</div>
                    {results.vibration && <div className={styles.resultText}>Vibration: {results.vibration}</div>}
                    {results.clipboard && <div className={styles.resultText}>Clipboard: {results.clipboard}</div>}
                  </div>
                )}
              </div>
            </div>

            {/* Data Storage */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Data Storage & Preferences</div>
              <div className={styles.itemDesc}>Store and retrieve data using Flutter's shared preferences</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isProcessing.preferences ? styles.processing : ''}`}
                  onClick={testPreferences}
                  disabled={isProcessing.preferences}
                >
                  {isProcessing.preferences ? 'Processing...' : 'Test Preferences'}
                </button>
                {results.preferences && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Preferences Result:</div>
                    <div className={styles.resultText}>{results.preferences}</div>
                  </div>
                )}
              </div>
            </div>

            {/* Complex Data Transfer */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Complex Data Transfer</div>
              <div className={styles.itemDesc}>Send complex nested data structures to Flutter for processing</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isProcessing.dataTransfer ? styles.processing : ''}`}
                  onClick={sendDataToFlutter}
                  disabled={isProcessing.dataTransfer}
                >
                  {isProcessing.dataTransfer ? 'Sending...' : 'Send Complex Data'}
                </button>
                {results.dataTransfer && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Data Transfer Result:</div>
                    <div className={styles.resultText}>{results.dataTransfer}</div>
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