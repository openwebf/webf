import React, { useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { WebFDeepLink } from '@openwebf/webf-deeplink';
import styles from './DeepLinkPage.module.css';

export const DeepLinkPage: React.FC = () => {
  const [currentUrl, setCurrentUrl] = useState<string>('');
  const [deepLinkHistory, setDeepLinkHistory] = useState<string[]>([]);
  const [customSchemeResult, setCustomSchemeResult] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState<{[key: string]: boolean}>({});

  useEffect(() => {
    // Get current URL
    setCurrentUrl(window.location.href);
    
    // Listen for URL changes (if supported)
    const handleURLChange = () => {
      const newUrl = window.location.href;
      setCurrentUrl(newUrl);
      setDeepLinkHistory(prev => [...prev, newUrl].slice(-5)); // Keep last 5 URLs
    };

    // FIXME
    window.addEventListener('popstate', handleURLChange);
    return () => window.removeEventListener('popstate', handleURLChange);
  }, []);


  const testCustomScheme = async (scheme: string) => {
    setIsProcessing(prev => ({...prev, customScheme: true}));
    try {
      if (!WebFDeepLink.isAvailable()) {
        return;
      }
      const result = await WebFDeepLink.openDeepLink({
        url: scheme,
        fallbackUrl: window.location.href
      });
      
      console.log('Open deep link result:', result);
      setCustomSchemeResult(`Custom scheme result: ${JSON.stringify(result)}`);
    } catch (error) {
      console.error('Test custom scheme failed:', error);
      setCustomSchemeResult(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsProcessing(prev => ({...prev, customScheme: false}));
    }
  };



  const parseUrlParams = (url: string) => {
    try {
      const urlObj = new URL(url);
      const params: {[key: string]: string} = {};
      urlObj.searchParams.forEach((value, key) => {
        params[key] = value;
      });
      return params;
    } catch {
      return {};
    }
  };

  const currentParams = parseUrlParams(currentUrl);

  const customSchemes = [
    {
      title: 'App Store',
      description: 'Open App Store (iOS)',
      scheme: 'itms-apps://itunes.apple.com/app/id123456789'
    },
    {
      title: 'Google Maps',
      description: 'Open location in Maps',
      scheme: 'geo:37.7749,-122.4194?q=San+Francisco'
    },
    {
      title: 'Email Client',
      description: 'Open email composition',
      scheme: 'mailto:demo@example.com?subject=WebF%20Demo&body=Hello%20from%20WebF!'
    },
    {
      title: 'Phone Dialer',
      description: 'Open phone dialer',
      scheme: 'tel:+1234567890'
    },
    {
      title: 'SMS',
      description: 'Open SMS application',
      scheme: 'sms:+1234567890?body=Hello%20from%20WebF%20Demo!'
    }
  ];

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Deep Link Integration Demo</div>
          <div className={styles.sectionDescription}>
            Demonstrate WebF application's deep link capabilities: launching external apps and registering custom URL schemes
          </div>
          <div className={styles.componentBlock}>
            
            {/* Current URL Info */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Current URL Information</div>
              <div className={styles.itemDesc}>View current URL and extracted parameters</div>
              <div className={styles.urlContainer}>
                <div className={styles.urlSection}>
                  <div className={styles.urlLabel}>Current URL:</div>
                  <div className={styles.urlValue}>{currentUrl}</div>
                </div>
                
                {Object.keys(currentParams).length > 0 && (
                  <div className={styles.urlSection}>
                    <div className={styles.urlLabel}>URL Parameters:</div>
                    <div className={styles.paramsGrid}>
                      {Object.entries(currentParams).map(([key, value]) => (
                        <div key={key} className={styles.paramItem}>
                          <span className={styles.paramKey}>{key}:</span>
                          <span className={styles.paramValue}>{value}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {deepLinkHistory.length > 0 && (
                  <div className={styles.urlSection}>
                    <div className={styles.urlLabel}>Navigation History:</div>
                    <div className={styles.historyList}>
                      {deepLinkHistory.map((url, index) => (
                        <div key={index} className={styles.historyItem}>
                          {index + 1}. {url}
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>


            {/* Custom URL Schemes */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Launch External Apps</div>
              <div className={styles.itemDesc}>Test opening external applications using custom URL schemes</div>
              <div className={styles.schemesContainer}>
                {customSchemes.map((scheme, index) => (
                  <div key={index} className={styles.schemeCard}>
                    <div className={styles.schemeHeader}>
                      <div className={styles.schemeTitle}>{scheme.title}</div>
                      <div className={styles.schemeDesc}>{scheme.description}</div>
                    </div>
                    <div className={styles.schemeUrl}>{scheme.scheme}</div>
                    <button 
                      className={`${styles.schemeButton} ${isProcessing.customScheme ? styles.processing : ''}`}
                      onClick={() => testCustomScheme(scheme.scheme)}
                      disabled={isProcessing.customScheme}
                    >
                      {isProcessing.customScheme ? 'Opening...' : 'Test Scheme'}
                    </button>
                  </div>
                ))}
                
                {customSchemeResult && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Custom Scheme Result:</div>
                    <div className={styles.resultText}>{customSchemeResult}</div>
                  </div>
                )}
              </div>
            </div>

            {/* Deep Link Examples */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Deep Link Examples</div>
              <div className={styles.itemDesc}>Examples of deep links that can open this application</div>
              <div className={styles.platformSupport}>
                <strong>Configured on: macOS and iOS</strong> 
              </div>
              <div className={styles.registrationContainer}>
                <div className={styles.registrationInfo}>
                  <div className={styles.infoTitle}>Custom Scheme: webfdemo://</div>
                  <div className={styles.infoDesc}>
                    This application is registered to handle webfdemo:// URLs. You can test these from Terminal or other applications.
                  </div>
                  <div className={styles.exampleSchemes}>
                    <div className={styles.exampleItem}>
                      <code>webfdemo://app/react_use_cases?page=deeplink</code>
                      <div className={styles.exampleDesc}>Open Deep Link demo page</div>
                    </div>
                    <div className={styles.exampleItem}>
                      <code>webfdemo://app/react_use_cases?page=animation</code>
                      <div className={styles.exampleDesc}>Open Animation demo</div>
                    </div>
                    <div className={styles.exampleItem}>
                      <code>webfdemo://app/react_use_cases?page=video</code>
                      <div className={styles.exampleDesc}>Open Video demo</div>
                    </div>
                    <div className={styles.exampleItem}>
                      <code>webfdemo://app/react_use_cases?page=network</code>
                      <div className={styles.exampleDesc}>Open Network demo</div>
                    </div>
                  </div>
                  <div className={styles.terminalExample}>
                    <div className={styles.terminalTitle}>Terminal Test Example:</div>
                    <code className={styles.terminalCommand}>
                      open "webfdemo://app/react_use_cases?page=deeplink"
                    </code>
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