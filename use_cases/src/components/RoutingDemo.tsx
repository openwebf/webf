import React, { useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { WebFRouter } from '../router';
import TabBarManager from '../utils/tabBarManager';
import styles from './RoutingDemo.module.css';

interface RouteState {
  path: string;
  title: string;
  params: {[key: string]: any};
  timestamp: number;
}

export const RoutingDemo: React.FC = () => {
  const [isNavigating, setIsNavigating] = useState<{[key: string]: boolean}>({});
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
    console.log('updateCurrentRoute', url);
    const urlObj = new URL(url);
    const params: {[key: string]: any} = {};

    urlObj.searchParams.forEach((value, key) => {
      params[key] = value;
    });


  };

  const navigateToRoute = async (path: string, params?: {[key: string]: any}, options?: {replace?: boolean}) => {
    setIsNavigating(prev => ({...prev, navigate: true}));
    try {
      const newState: RouteState = {
        path,
        title: `WebF Demo - ${path}`,
        params: params || {},
        timestamp: Date.now()
      };

      if (options?.replace) {
        WebFRouter.replaceState(newState, path);
      } else {
        WebFRouter.pushState(newState, path);
      }
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, navigate: false}));
    }
  };

  const goBack = async () => {
    setIsNavigating(prev => ({...prev, back: true}));
    try {
      WebFRouter.back();
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, back: false}));
    }
  };

  const goForward = async () => {
    setIsNavigating(prev => ({...prev, forward: true}));
    try {
      // Navigate to animation page as a forward example
      const forwardState = {
        source: 'forward_demo',
        timestamp: Date.now()
      };
      WebFRouter.pushState(forwardState, '/css/animation');

      // Update local route state for display
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, forward: false}));
    }
  };

  const goToHistoryDelta = async (delta: number) => {
    setIsNavigating(prev => ({...prev, delta: true}));
    try {
      if (delta < 0) {
        const stepsToGo = Math.abs(delta);
        if (stepsToGo === 0) {
          return;
        }
        for (let i = 0; i < stepsToGo; i++) {
          WebFRouter.back();
        }
      } else if (delta > 0) {
        // Navigate to showcase and animation pages as forward examples
        const forwardPages = ['/show_case', '/css/animation'];
        const pagesToVisit = Math.min(delta, forwardPages.length);

        for (let i = 0; i < pagesToVisit; i++) {
          const stateParams = {
            source: 'delta_navigation',
            step: i + 1,
            timestamp: Date.now()
          };
          WebFRouter.pushState(stateParams, forwardPages[i]);
        }
      }
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, delta: false}));
    }
  };

  // Advanced Hybrid History functions
  const testPushNamed = async () => {
    setIsNavigating(prev => ({...prev, pushNamed: true}));
    try {
      const stateParams = {
        source: 'routing_demo',
        timestamp: Date.now()
      };
      await WebFRouter.push('/flutter-interaction', stateParams);
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, pushNamed: false}));
    }
  };

  const testPushReplacementNamed = async () => {
    setIsNavigating(prev => ({...prev, pushReplacement: true}));
    try {
      const stateParams = {
        source: 'routing_demo',
        timestamp: Date.now()
      };
      await WebFRouter.replace('/network', stateParams);
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, pushReplacement: false}));
    }
  };

  const testPopAndPushNamed = async () => {
    setIsNavigating(prev => ({...prev, popAndPush: true}));
    try {
      const stateParams = {
        source: 'routing_demo',
        timestamp: Date.now()
      };
      await WebFRouter.popAndPushNamed('/video', stateParams);
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, popAndPush: false}));
    }
  };

  const testCanPopAndMaybePop = async () => {
    setIsNavigating(prev => ({...prev, canPop: true}));
    try {
      const canPop = WebFRouter.canPop();
      console.log('canPop', canPop);
      const didPop = WebFRouter.maybePop({ cancelled: false });
      console.log('didPop', didPop);
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, canPop: false}));
    }
  };

  const testRestorablePopAndPush = async () => {
    setIsNavigating(prev => ({...prev, restorable: true}));
    try {
      const stateParams = {
        source: 'routing_demo',
        timestamp: Date.now()
      };
      const restorationId = await WebFRouter.restorablePopAndPushNamed('/image', stateParams);
      setHybridHistoryState(prev => ({...prev, lastRestorationId: restorationId}));
    } catch (error) {
    } finally {
      setIsNavigating(prev => ({...prev, restorable: false}));
    }
  };

  const demoRoutes = [
    {
      path: '/css/animation',
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
      <WebFListView className={`${styles.list} ${styles.componentSection}`}>
        <div className={styles.sectionTitle}>Routing & Navigation Showcase</div>
        <div className={styles.componentBlock}>

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

            {/* TabBar Integration Demo */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>TabBar Integration</div>
              <div className={styles.itemDesc}>Test TabBar switching from within the routing demo</div>

              <div className={styles.tabBarDemo}>
                <div className={styles.tabBarControls}>
                  <button
                    className={styles.tabButton}
                    onClick={() => {
                      TabBarManager.switchTab('/search');
                    }}
                  >
                    Switch to Search Tab
                  </button>

                  <button
                    className={styles.tabButton}
                    onClick={() => {
                      console.log('Demo page: Switching to My tab');
                      TabBarManager.switchTab('/my');
                    }}
                  >
                    Switch to My Tab
                  </button>

                  <button
                    className={`${styles.tabButton} ${styles.navigateButton}`}
                    onClick={() => {
                      console.log('Demo page: Navigating to TabBar with My tab');
                      TabBarManager.navigateToTab('/my');
                    }}
                  >
                    Navigate to My Tab (from outside)
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
      </WebFListView>
    </div>
  );
};
