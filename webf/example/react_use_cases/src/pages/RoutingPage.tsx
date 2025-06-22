import React, { useState, useEffect } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './RoutingPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});


interface RouteState {
  path: string;
  title: string;
  params: {[key: string]: any};
  timestamp: number;
}

interface HistoryEntry {
  index: number;
  state: RouteState;
  url: string;
  action: string;
  timestamp: string;
}

export const RoutingPage: React.FC = () => {
  const [currentRoute, setCurrentRoute] = useState<RouteState>({
    path: '/routing',
    title: 'Routing Demo',
    params: {},
    timestamp: Date.now()
  });
  const [historyStack, setHistoryStack] = useState<HistoryEntry[]>([]);
  const [isNavigating, setIsNavigating] = useState<{[key: string]: boolean}>({});
  const [routeResult, setRouteResult] = useState<string>('');
  const [currentTabIndex, setCurrentTabIndex] = useState<number>(0);
  const [hybridHistoryState, setHybridHistoryState] = useState<{[key: string]: any}>({});

  useEffect(() => {
    // Initialize current route state
    updateCurrentRoute();
    
    // Listen for history changes (if supported)
    const handlePopState = () => {
      updateCurrentRoute();
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const updateCurrentRoute = () => {
    const url = window.location.href;
    const urlObj = new URL(url);
    const params: {[key: string]: any} = {};
    
    urlObj.searchParams.forEach((value, key) => {
      params[key] = value;
    });

    setCurrentRoute({
      path: urlObj.pathname,
      title: document.title || 'WebF Use Cases Demo',
      params,
      timestamp: Date.now()
    });
  };

  const addHistoryEntry = (action: string, state?: any, path?: string) => {
    const entry: HistoryEntry = {
      index: historyStack.length,
      state: state || currentRoute,
      url: path ? `${window.location.origin}${path}` : window.location.href,
      action,
      timestamp: new Date().toLocaleTimeString()
    };

    setHistoryStack(prev => [...prev, entry].slice(-10)); // Keep last 10 entries
  };

  const navigateToRoute = async (path: string, params?: {[key: string]: any}, options?: {replace?: boolean}) => {
    setIsNavigating(prev => ({...prev, navigate: true}));
    try {
      const searchParams = new URLSearchParams(params);
      const fullUrl = `${window.location.origin}${path}${searchParams.toString() ? `?${searchParams.toString()}` : ''}`;
      
      const newState: RouteState = {
        path,
        title: `WebF Demo - ${path}`,
        params: params || {},
        timestamp: Date.now()
      };

      if (window.webf?.hybridHistory) {
        if (options?.replace) {
          window.webf.hybridHistory.replaceState(newState, path);
          addHistoryEntry('replaceState', newState, path);
        } else {
          window.webf.hybridHistory.pushState(newState, path);
          addHistoryEntry('pushState', newState, path);
        }
      } else {
        // Fallback to regular history API
        if (options?.replace) {
          window.history.replaceState(newState, newState.title, fullUrl);
          addHistoryEntry('replaceState', newState);
        } else {
          window.history.pushState(newState, newState.title, fullUrl);
          addHistoryEntry('pushState', newState);
        }
      }

      setCurrentRoute(newState);
      setRouteResult(`Navigated to ${path} successfully`);
    } catch (error) {
      setRouteResult(`Error navigating: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, navigate: false}));
    }
  };

  const goBack = async () => {
    setIsNavigating(prev => ({...prev, back: true}));
    try {
      if (window.webf?.hybridHistory) {
        window.webf.hybridHistory.back();
      } else {
        window.history.back();
      }
      addHistoryEntry('back');
      setRouteResult('Navigated back in history');
    } catch (error) {
      setRouteResult(`Error going back: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, back: false}));
    }
  };

  const goForward = async () => {
    setIsNavigating(prev => ({...prev, forward: true}));
    try {
      if (window.webf?.hybridHistory) {
        // Navigate to animation page as a forward example
        const forwardState = {
          source: 'forward_demo',
          timestamp: Date.now()
        };
        window.webf.hybridHistory.pushState(forwardState, '/animation');
        
        // Update local route state for display
        setCurrentRoute({
          path: '/animation',
          title: 'Animation Page - Forward Navigation',
          params: forwardState,
          timestamp: Date.now()
        });
        addHistoryEntry('forward', forwardState, '/animation');
      } else {
        window.history.forward();
        addHistoryEntry('forward');
      }
      setRouteResult('Navigated forward to Animation page');
    } catch (error) {
      setRouteResult(`Error going forward: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, forward: false}));
    }
  };

  const goToHistoryDelta = async (delta: number) => {
    setIsNavigating(prev => ({...prev, delta: true}));
    try {
      if (window.webf?.hybridHistory) {
        if (delta < 0) {
          // Check if we have enough history to go back
          const stepsToGo = Math.min(Math.abs(delta), historyStack.length);
          if (stepsToGo === 0) {
            setRouteResult('Cannot go back: No history available');
            return;
          }
          for (let i = 0; i < stepsToGo; i++) {
            window.webf.hybridHistory.back();
          }
          setRouteResult(`Went back ${stepsToGo} steps (requested ${Math.abs(delta)})`);
        } else if (delta > 0) {
          // Navigate to showcase and animation pages as forward examples
          const forwardPages = ['/show_case', '/animation'];
          const pagesToVisit = Math.min(delta, forwardPages.length);
          
          for (let i = 0; i < pagesToVisit; i++) {
            const stateParams = { 
              source: 'delta_navigation', 
              step: i + 1,
              timestamp: Date.now()
            };
            window.webf.hybridHistory.pushState(stateParams, forwardPages[i]);
            
            // Update local route state for display
            setCurrentRoute({
              path: forwardPages[i],
              title: `${forwardPages[i].slice(1)} Page`,
              params: stateParams,
              timestamp: Date.now()
            });
            addHistoryEntry(`go(${delta})`, stateParams, forwardPages[i]);
          }
          setRouteResult(`Navigated forward ${pagesToVisit} steps to existing pages`);
        }
      } else {
        window.history.go(delta);
        setRouteResult(`Navigated ${delta} steps in history`);
      }
      addHistoryEntry(`go(${delta})`);
    } catch (error) {
      setRouteResult(`Error navigating: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, delta: false}));
    }
  };

  // TabBar functionality
  const simulateTabSwitch = (index: number) => {
    setCurrentTabIndex(index);
    const tabNames = ['Home', 'Search', 'Publish', 'Messages', 'Profile'];
    setRouteResult(`Switched to tab ${index}: ${tabNames[index]}`);
  };

  const testTabBarNavigation = async (targetIndex: number) => {
    setIsNavigating(prev => ({...prev, tabBar: true}));
    try {
      if (window.webf?.methodChannel) {
        // Use method channel for real tab navigation
        const result = await window.webf.methodChannel.invokeMethod('switchTab', {
          tabIndex: targetIndex,
          tabName: ['home', 'search', 'publish', 'messages', 'profile'][targetIndex],
          preserveState: true,
          animated: true
        });
        setRouteResult(`TabBar navigation result: ${JSON.stringify(result)}`);
      } else {
        // Fallback to simulation
        simulateTabSwitch(targetIndex);
      }
    } catch (error) {
      setRouteResult(`TabBar navigation error: ${error instanceof Error ? error.message : 'Unknown error'}`);
      // Fallback to simulation on error
      simulateTabSwitch(targetIndex);
    } finally {
      setIsNavigating(prev => ({...prev, tabBar: false}));
    }
  };

  // Advanced Hybrid History functions
  const testPushNamed = async () => {
    setIsNavigating(prev => ({...prev, pushNamed: true}));
    try {
      if (window.webf?.hybridHistory) {
        const stateParams = {
          userId: '12345',
          source: 'routing_demo',
          editMode: true
        };
        window.webf.hybridHistory.pushNamed('/settings/profile', { arguments: stateParams });
        addHistoryEntry('pushNamed', stateParams, '/settings/profile');
        setRouteResult('Successfully pushed named route: /settings/profile');
      } else {
        throw new Error('WebF hybrid history not available');
      }
    } catch (error) {
      setRouteResult(`Push named error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, pushNamed: false}));
    }
  };

  const testPushReplacementNamed = async () => {
    setIsNavigating(prev => ({...prev, pushReplacement: true}));
    try {
      if (window.webf?.hybridHistory) {
        const stateParams = {
          resetState: true,
          source: 'routing_demo'
        };
        window.webf.hybridHistory.pushReplacementNamed('/dashboard', { arguments: stateParams });
        addHistoryEntry('pushReplacementNamed', stateParams, '/dashboard');
        setRouteResult('Successfully replaced with named route: /dashboard');
      } else {
        throw new Error('WebF hybrid history not available');
      }
    } catch (error) {
      setRouteResult(`Push replacement error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, pushReplacement: false}));
    }
  };

  const testPopAndPushNamed = async () => {
    setIsNavigating(prev => ({...prev, popAndPush: true}));
    try {
      if (window.webf?.hybridHistory) {
        const stateParams = {
          showAll: true,
          source: 'routing_demo'
        };
        window.webf.hybridHistory.popAndPushNamed('/notifications', { arguments: stateParams });
        addHistoryEntry('popAndPushNamed', stateParams, '/notifications');
        setRouteResult('Successfully popped and pushed named route: /notifications');
      } else {
        throw new Error('WebF hybrid history not available');
      }
    } catch (error) {
      setRouteResult(`Pop and push error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, popAndPush: false}));
    }
  };

  const testCanPopAndMaybePop = async () => {
    setIsNavigating(prev => ({...prev, canPop: true}));
    try {
      if (window.webf?.hybridHistory) {
        const canPop = window.webf.hybridHistory.canPop();
        const didPop = window.webf.hybridHistory.maybePop({ cancelled: false });
        
        addHistoryEntry('canPop/maybePop');
        setRouteResult(`Can pop: ${canPop}, Did pop: ${didPop}`);
      } else {
        throw new Error('WebF hybrid history not available');
      }
    } catch (error) {
      setRouteResult(`Can pop/maybe pop error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, canPop: false}));
    }
  };

  const testRestorablePopAndPush = async () => {
    setIsNavigating(prev => ({...prev, restorable: true}));
    try {
      if (window.webf?.hybridHistory) {
        const stateParams = {
          temporary: true,
          source: 'routing_demo'
        };
        const restorationId = window.webf.hybridHistory.restorablePopAndPushNamed('/temp-screen', { arguments: stateParams });
        
        addHistoryEntry('restorablePopAndPushNamed', stateParams, '/temp-screen');
        setRouteResult(`Restorable navigation completed. Restoration ID: ${restorationId}`);
        setHybridHistoryState(prev => ({...prev, lastRestorationId: restorationId}));
      } else {
        throw new Error('WebF hybrid history not available');
      }
    } catch (error) {
      setRouteResult(`Restorable navigation error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsNavigating(prev => ({...prev, restorable: false}));
    }
  };

  const demoRoutes = [
    {
      path: '/animation',
      title: 'Animation Page',
      description: 'Navigate to the animation page',
      params: { source: 'routing_demo' }
    },
    {
      path: '/show_case',
      title: 'Showcase',
      description: 'View component showcase',
      params: { category: 'all' }
    }
  ];

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Routing & Navigation Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Current Route State */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Current Route State</div>
              <div className={styles.itemDesc}>View current route information and history state</div>
              <div className={styles.routeContainer}>
                <div className={styles.routeInfo}>
                  <div className={styles.routeSection}>
                    <div className={styles.routeLabel}>Current Path:</div>
                    <div className={styles.routeValue}>{currentRoute.path}</div>
                  </div>
                  <div className={styles.routeSection}>
                    <div className={styles.routeLabel}>Page Title:</div>
                    <div className={styles.routeValue}>{currentRoute.title}</div>
                  </div>
                  <div className={styles.routeSection}>
                    <div className={styles.routeLabel}>History Length:</div>
                    <div className={styles.routeValue}>{historyStack.length}</div>
                  </div>
                  <div className={styles.routeSection}>
                    <div className={styles.routeLabel}>Timestamp:</div>
                    <div className={styles.routeValue}>{new Date(currentRoute.timestamp).toLocaleString()}</div>
                  </div>
                </div>

                {Object.keys(currentRoute.params).length > 0 && (
                  <div className={styles.paramsContainer}>
                    <div className={styles.paramsLabel}>URL Parameters:</div>
                    <div className={styles.paramsGrid}>
                      {Object.entries(currentRoute.params).map(([key, value]) => (
                        <div key={key} className={styles.paramItem}>
                          <span className={styles.paramKey}>{key}:</span>
                          <span className={styles.paramValue}>{value}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* History Navigation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>History Navigation</div>
              <div className={styles.itemDesc}>Navigate through browser history using WebF hybrid history API</div>
              <div className={styles.historyContainer}>
                <div className={styles.historyControls}>
                  <button 
                    className={`${styles.historyButton} ${isNavigating.back ? styles.loading : ''}`}
                    onClick={goBack}
                    disabled={isNavigating.back}
                  >
                    {isNavigating.back ? 'Going Back...' : '← Back'}
                  </button>
                  <button 
                    className={`${styles.historyButton} ${isNavigating.forward ? styles.loading : ''}`}
                    onClick={goForward}
                    disabled={isNavigating.forward}
                  >
                    {isNavigating.forward ? 'Going Forward...' : 'Forward →'}
                  </button>
                  <button 
                    className={`${styles.historyButton} ${styles.deltaButton} ${isNavigating.delta ? styles.loading : ''}`}
                    onClick={() => goToHistoryDelta(-2)}
                    disabled={isNavigating.delta}
                  >
                    {isNavigating.delta ? 'Navigating...' : 'Go Back 2 Steps'}
                  </button>
                  <button 
                    className={`${styles.historyButton} ${styles.deltaButton} ${isNavigating.delta ? styles.loading : ''}`}
                    onClick={() => goToHistoryDelta(2)}
                    disabled={isNavigating.delta}
                  >
                    {isNavigating.delta ? 'Navigating...' : 'Go Forward 2 Steps'}
                  </button>
                </div>

                {historyStack.length > 0 && (
                  <div className={styles.historyStack}>
                    <div className={styles.stackLabel}>Recent Navigation History:</div>
                    <div className={styles.stackList}>
                      {historyStack.slice(-5).reverse().map((entry) => (
                        <div key={entry.index} className={styles.stackItem}>
                          <div className={styles.stackHeader}>
                            <span className={styles.stackAction}>{entry.action}</span>
                            <span className={styles.stackTime}>{entry.timestamp}</span>
                          </div>
                          <div className={styles.stackUrl}>{entry.url}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Route Navigation */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Route Navigation</div>
              <div className={styles.itemDesc}>Navigate to different routes with parameters</div>
              <div className={styles.routesContainer}>
                {demoRoutes.map((route, index) => (
                  <div key={index} className={styles.routeCard}>
                    <div className={styles.routeHeader}>
                      <div className={styles.routeTitle}>{route.title}</div>
                      <div className={styles.routeDesc}>{route.description}</div>
                    </div>
                    <div className={styles.routePath}>{route.path}</div>
                    <div className={styles.routeParams}>
                      {Object.entries(route.params).map(([key, value]) => (
                        <span key={key} className={styles.paramChip}>
                          {key}={value}
                        </span>
                      ))}
                    </div>
                    <div className={styles.routeActions}>
                      <button 
                        className={`${styles.routeButton} ${isNavigating.navigate ? styles.loading : ''}`}
                        onClick={() => navigateToRoute(route.path, route.params)}
                        disabled={isNavigating.navigate}
                      >
                        {isNavigating.navigate ? 'Navigating...' : 'Push State'}
                      </button>
                      <button 
                        className={`${styles.routeButton} ${styles.replaceButton} ${isNavigating.navigate ? styles.loading : ''}`}
                        onClick={() => navigateToRoute(route.path, route.params, {replace: true})}
                        disabled={isNavigating.navigate}
                      >
                        {isNavigating.navigate ? 'Replacing...' : 'Replace State'}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* TabBar Navigation Demo */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>TabBar Navigation Demo</div>
              <div className={styles.itemDesc}>Interactive TabBar component with navigation functionality</div>
              
              <div className={styles.tabBarDemo}>
                <div className={styles.tabBarTitle}>Simulated App TabBar</div>
                <div className={styles.tabBarContainer}>
                  {['🏠', '🔍', '➕', '💬', '👤'].map((icon, index) => {
                    const labels = ['Home', 'Search', 'Publish', 'Messages', 'Profile'];
                    return (
                      <button
                        key={index}
                        className={`${styles.tabBarItem} ${currentTabIndex === index ? styles.active : ''}`}
                        onClick={() => testTabBarNavigation(index)}
                        disabled={isNavigating.tabBar}
                      >
                        <span className={styles.tabBarIcon}>{icon}</span>
                        <span className={styles.tabBarLabel}>{labels[index]}</span>
                      </button>
                    );
                  })}
                </div>
                
                <div className={styles.tabBarControls}>
                  <button 
                    className={`${styles.tabBarButton} ${isNavigating.tabBar ? styles.loading : ''}`}
                    onClick={() => testTabBarNavigation(0)}
                    disabled={isNavigating.tabBar}
                  >
                    {isNavigating.tabBar ? 'Switching...' : 'Go to Home'}
                  </button>
                  <button 
                    className={`${styles.tabBarButton} ${isNavigating.tabBar ? styles.loading : ''}`}
                    onClick={() => testTabBarNavigation(2)}
                    disabled={isNavigating.tabBar}
                  >
                    {isNavigating.tabBar ? 'Switching...' : 'Go to Publish'}
                  </button>
                  <button 
                    className={`${styles.tabBarButton} ${isNavigating.tabBar ? styles.loading : ''}`}
                    onClick={() => testTabBarNavigation(4)}
                    disabled={isNavigating.tabBar}
                  >
                    {isNavigating.tabBar ? 'Switching...' : 'Go to Profile'}
                  </button>
                </div>
              </div>
            </div>

            {/* Advanced Hybrid History */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Advanced Hybrid History</div>
              <div className={styles.itemDesc}>Flutter-style navigation methods with named routes and state management</div>
              
              <div className={styles.hybridDemo}>
                <div className={styles.hybridControls}>
                  <button 
                    className={`${styles.hybridButton} ${isNavigating.pushNamed ? styles.loading : ''}`}
                    onClick={testPushNamed}
                    disabled={isNavigating.pushNamed}
                  >
                    {isNavigating.pushNamed ? 'Pushing...' : 'Push Named Route'}
                  </button>
                  
                  <button 
                    className={`${styles.hybridButton} ${isNavigating.pushReplacement ? styles.loading : ''}`}
                    onClick={testPushReplacementNamed}
                    disabled={isNavigating.pushReplacement}
                  >
                    {isNavigating.pushReplacement ? 'Replacing...' : 'Push Replacement'}
                  </button>
                  
                  <button 
                    className={`${styles.hybridButton} ${isNavigating.popAndPush ? styles.loading : ''}`}
                    onClick={testPopAndPushNamed}
                    disabled={isNavigating.popAndPush}
                  >
                    {isNavigating.popAndPush ? 'Navigating...' : 'Pop and Push'}
                  </button>
                  
                  <button 
                    className={`${styles.hybridButton} ${isNavigating.canPop ? styles.loading : ''}`}
                    onClick={testCanPopAndMaybePop}
                    disabled={isNavigating.canPop}
                  >
                    {isNavigating.canPop ? 'Checking...' : 'Can Pop / Maybe Pop'}
                  </button>
                  
                  <button 
                    className={`${styles.hybridButton} ${isNavigating.restorable ? styles.loading : ''}`}
                    onClick={testRestorablePopAndPush}
                    disabled={isNavigating.restorable}
                  >
                    {isNavigating.restorable ? 'Creating...' : 'Restorable Navigation'}
                  </button>
                </div>
                
                {hybridHistoryState.lastRestorationId && (
                  <div className={styles.resultContainer}>
                    <div className={styles.resultText}>
                      Last Restoration ID: {hybridHistoryState.lastRestorationId}
                    </div>
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