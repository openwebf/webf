import React, { useState, useEffect } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './DeepLinkPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});


export const DeepLinkPage: React.FC = () => {
  const [currentUrl, setCurrentUrl] = useState<string>('');
  const [deepLinkHistory, setDeepLinkHistory] = useState<string[]>([]);
  const [customSchemeResult, setCustomSchemeResult] = useState<string>('');
  const [registerResult, setRegisterResult] = useState<string>('');
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

    window.addEventListener('popstate', handleURLChange);
    return () => window.removeEventListener('popstate', handleURLChange);
  }, []);

  const generateDeepLink = (path: string, params?: {[key: string]: string}) => {
    const baseUrl = window.location.origin;
    const searchParams = new URLSearchParams(params);
    const queryString = searchParams.toString();
    return `${baseUrl}${path}${queryString ? `?${queryString}` : ''}`;
  };

  const testWebLink = (url: string) => {
    setIsProcessing(prev => ({...prev, webLink: true}));
    try {
      // In WebF, use hybridHistory for navigation instead of window.location
      if ((window as any).webf?.hybridHistory) {
        // Extract path and params from the URL manually (WebF doesn't support searchParams.entries)
        const urlObj = new URL(url);
        const path = urlObj.pathname;
        
        // Parse query parameters manually
        const params: {[key: string]: string} = {};
        const queryString = urlObj.search.slice(1); // Remove the '?' prefix
        if (queryString) {
          const pairs = queryString.split('&');
          pairs.forEach(pair => {
            const [key, value] = pair.split('=');
            if (key) {
              params[decodeURIComponent(key)] = value ? decodeURIComponent(value) : '';
            }
          });
        }
        
        console.log('Navigating to path:', path, 'with params:', params);
        // Navigate using hybridHistory
        (window as any).webf.hybridHistory.pushState(params, path);
      } else {
        console.error('WebF hybrid history not available');
      }
    } catch (error) {
      console.error('Failed to navigate to:', url, error);
    } finally {
      setTimeout(() => setIsProcessing(prev => ({...prev, webLink: false})), 1000);
    }
  };

  const testCustomScheme = async (scheme: string) => {
    setIsProcessing(prev => ({...prev, customScheme: true}));
    try {
      if (!window.webf?.invokeModuleAsync) {
        throw new Error('WebF native module not available');
      }

      const result = await window.webf.invokeModuleAsync(
        'DeepLink',
        'openDeepLink',
        {
          url: scheme,
          fallbackUrl: window.location.href
        }
      );
      
      console.log('Open deep link result:', result);
      setCustomSchemeResult(`Custom scheme result: ${JSON.stringify(result)}`);
    } catch (error) {
      console.error('Test custom scheme failed:', error);
      setCustomSchemeResult(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsProcessing(prev => ({...prev, customScheme: false}));
    }
  };

  const shareDeepLink = async (link: string) => {
    setIsProcessing(prev => ({...prev, share: true}));
    try {
      if (!window.webf?.invokeModuleAsync) {
        throw new Error('WebF native module not available');
      }

      const title = 'WebF Deep Link Demo';
      const text = `Check out this WebF demo: ${link}`;
      
      const result = await window.webf.invokeModuleAsync(
        'Share',
        'shareText',
        title,
        text
      );
      
      console.log('Share result:', result);
      if (result) {
        console.log('Deep link shared successfully');
      } else {
        console.log('Failed to share deep link');
      }
    } catch (error) {
      console.error('Failed to share deep link:', error);
    } finally {
      setIsProcessing(prev => ({...prev, share: false}));
    }
  };

  const registerDeepLinkHandler = async () => {
    setIsProcessing(prev => ({...prev, register: true}));
    try {
      if (!window.webf?.invokeModuleAsync) {
        throw new Error('WebF native module not available');
      }

      const result = await window.webf.invokeModuleAsync(
        'DeepLink',
        'registerDeepLinkHandler',
        {
          scheme: 'webfdemo',
          host: 'app'
        }
      );
      
      console.log('Register result:', result);
      setRegisterResult(`Registration result: ${JSON.stringify(result)}`);
    } catch (error) {
      console.error('Failed to register deep link handler:', error);
      setRegisterResult(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsProcessing(prev => ({...prev, register: false}));
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

  const demoLinks = [
    {
      title: 'Home Page',
      description: 'Navigate to the main home page',
      url: generateDeepLink('/', {source: 'deeplink', campaign: 'demo'})
    },
    {
      title: 'Animation Demo',
      description: 'Direct link to animation showcase',
      url: generateDeepLink('/animation', {feature: 'animations', from: 'deeplink'})
    },
    {
      title: 'Video Player',
      description: 'Link to video player functionality',
      url: generateDeepLink('/video', {autoplay: 'true', quality: 'hd'})
    },
    {
      title: 'Typography Showcase',
      description: 'Typography with specific language',
      url: generateDeepLink('/typography', {lang: 'multilingual', demo: 'text'})
    }
  ];

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
          <div className={styles.sectionTitle}>Deep Link Showcase</div>
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

            {/* Web Deep Links */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Web Deep Links</div>
              <div className={styles.itemDesc}>Navigate to different sections with URL parameters</div>
              <div className={styles.linksContainer}>
                {demoLinks.map((link, index) => (
                  <div key={index} className={styles.linkCard}>
                    <div className={styles.linkHeader}>
                      <div className={styles.linkTitle}>{link.title}</div>
                      <div className={styles.linkDesc}>{link.description}</div>
                    </div>
                    <div className={styles.linkUrl}>{link.url}</div>
                    <div className={styles.linkActions}>
                      <button 
                        className={`${styles.linkButton} ${isProcessing.webLink ? styles.processing : ''}`}
                        onClick={() => testWebLink(link.url)}
                        disabled={isProcessing.webLink}
                      >
                        {isProcessing.webLink ? 'Navigating...' : 'Open Link'}
                      </button>
                      <button 
                        className={`${styles.linkButton} ${styles.secondaryButton} ${isProcessing.share ? styles.processing : ''}`}
                        onClick={() => shareDeepLink(link.url)}
                        disabled={isProcessing.share}
                      >
                        {isProcessing.share ? 'Sharing...' : 'Share'}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Custom URL Schemes */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom URL Schemes</div>
              <div className={styles.itemDesc}>Test integration with system apps and services</div>
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

            {/* Deep Link Registration */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Deep Link Handler Registration</div>
              <div className={styles.itemDesc}>Register custom scheme handlers for the application</div>
              <div className={styles.registrationContainer}>
                <div className={styles.registrationInfo}>
                  <div className={styles.infoTitle}>Custom Scheme: webfdemo://</div>
                  <div className={styles.infoDesc}>
                    Register a custom URL scheme that can be used to open this app from external sources.
                  </div>
                  <div className={styles.exampleSchemes}>
                    <div className={styles.exampleItem}>
                      <code>webfdemo://app/home</code>
                      <div className={styles.exampleDesc}>Open home page</div>
                    </div>
                    <div className={styles.exampleItem}>
                      <code>webfdemo://app/video?id=123</code>
                      <div className={styles.exampleDesc}>Open specific video</div>
                    </div>
                    <div className={styles.exampleItem}>
                      <code>webfdemo://app/share?url=example.com</code>
                      <div className={styles.exampleDesc}>Share URL</div>
                    </div>
                  </div>
                </div>
                <button 
                  className={`${styles.registerButton} ${isProcessing.register ? styles.processing : ''}`}
                  onClick={registerDeepLinkHandler}
                  disabled={isProcessing.register}
                >
                  {isProcessing.register ? 'Registering...' : 'Register Handler'}
                </button>
                
                {registerResult && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultLabel}>Registration Result:</div>
                    <div className={styles.resultText}>{registerResult}</div>
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