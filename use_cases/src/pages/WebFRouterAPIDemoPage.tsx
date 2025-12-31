import React, { useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { WebFRouter } from '../router';

export const WebFRouterAPIDemoPage: React.FC = () => {
  const [isNavigating, setIsNavigating] = useState<{[key: string]: boolean}>({});
  const [routingStack, setRoutingStack] = useState<any[]>([]);
  const [currentPath, setCurrentPath] = useState('');
  const [canPopResult, setCanPopResult] = useState<boolean | null>(null);

  useEffect(() => {
    updateRoutingState();
    const handlePopState = () => {
      updateRoutingState();
    };
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const updateRoutingState = () => {
    setRoutingStack(WebFRouter.stack || []);
    setCurrentPath(WebFRouter.path || '');
  };

  // Basic Navigation Functions
  const goBack = async () => {
    setIsNavigating(prev => ({...prev, back: true}));
    try {
      WebFRouter.back();
      setTimeout(updateRoutingState, 100);
    } finally {
      setIsNavigating(prev => ({...prev, back: false}));
    }
  };

  const goForward = async () => {
    setIsNavigating(prev => ({...prev, forward: true}));
    try {
      WebFRouter.pushState({ source: 'forward_demo' }, '/css/animation');
      setTimeout(updateRoutingState, 100);
    } finally {
      setIsNavigating(prev => ({...prev, forward: false}));
    }
  };

  const navigateWithPush = (path: string, params: any = {}) => {
    console.log('navigate with push');
    WebFRouter.pushState({ ...params, timestamp: Date.now() }, path);
    setTimeout(updateRoutingState, 100);
  };

  const navigateWithReplace = (path: string, params: any = {}) => {
    WebFRouter.replaceState({ ...params, timestamp: Date.now() }, path);
    setTimeout(updateRoutingState, 100);
  };

  // Advanced Navigation Functions
  const testPush = async () => {
    setIsNavigating(prev => ({...prev, advPush: true}));
    try {
      await WebFRouter.push('/native-interaction', { source: 'routing_demo' });
      setTimeout(updateRoutingState, 100);
    } finally {
      setIsNavigating(prev => ({...prev, advPush: false}));
    }
  };

  const testReplace = async () => {
    setIsNavigating(prev => ({...prev, advReplace: true}));
    try {
      await WebFRouter.replace('/network', { source: 'routing_demo' });
      setTimeout(updateRoutingState, 100);
    } finally {
      setIsNavigating(prev => ({...prev, advReplace: false}));
    }
  };

  const testPopAndPushNamed = async () => {
    setIsNavigating(prev => ({...prev, popPush: true}));
    try {
      await WebFRouter.popAndPushNamed('/video', { source: 'routing_demo' });
      setTimeout(updateRoutingState, 100);
    } finally {
      setIsNavigating(prev => ({...prev, popPush: false}));
    }
  };

  const testCanPop = () => {
    const result = WebFRouter.canPop();
    setCanPopResult(result);
    updateRoutingState();
  };

  const testMaybePop = () => {
    const didPop = WebFRouter.maybePop({ cancelled: false });
    console.log('maybePop result:', didPop);
    setTimeout(updateRoutingState, 100);
  };

  const testRestorablePopAndPush = async () => {
    setIsNavigating(prev => ({...prev, restorable: true}));
    try {
      await WebFRouter.restorablePopAndPushNamed('/image', { source: 'routing_demo' });
      setTimeout(updateRoutingState, 100);
    } finally {
      setIsNavigating(prev => ({...prev, restorable: false}));
    }
  };

  return (
    <div id="main">
      <WebFListView className="flex-1 p-0 m-0">
        <div className="p-5 bg-gray-100 dark:bg-gray-900 min-h-screen max-w-7xl mx-auto">
          <div className="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">
            WebFRouter Navigation API Showcase
          </div>

          {/* Current Routing State */}
          <div className="bg-blue-50 dark:bg-blue-900/30 border border-blue-200 dark:border-blue-700 rounded-xl p-4 mb-6">
            <div className="text-sm font-semibold text-blue-800 dark:text-blue-300 mb-3">Current Routing State</div>

            {/* Current Path */}
            <div className="mb-4">
              <div className="text-xs font-semibold text-blue-700 dark:text-blue-400 mb-1">Current Path</div>
              <code className="text-sm text-blue-900 dark:text-blue-200 block bg-white dark:bg-gray-800 p-3 rounded-lg font-mono">
                {currentPath || '/'}
              </code>
            </div>

            {/* Routing Stack */}
            <div>
              <div className="text-xs font-semibold text-blue-700 dark:text-blue-400 mb-2">
                Navigation Stack ({routingStack.length} {routingStack.length === 1 ? 'entry' : 'entries'})
              </div>
              <div className="space-y-2 max-h-[300px] overflow-y-auto">
                {routingStack.length > 0 ? (
                  routingStack.map((entry, index) => (
                    <div key={index} className="bg-white dark:bg-gray-800 p-3 rounded-lg border border-blue-200 dark:border-blue-700">
                      <div className="flex items-center gap-2 mb-2">
                        <span className={`text-xs font-bold px-2 py-1 rounded ${index === routingStack.length - 1 ? 'bg-green-500 text-white' : 'bg-gray-300 dark:bg-gray-600 text-gray-700 dark:text-gray-300'}`}>
                          {index === routingStack.length - 1 ? 'CURRENT' : `#${index}`}
                        </span>
                        <code className="text-sm font-mono text-blue-900 dark:text-blue-200 flex-1">
                          {entry.path}
                        </code>
                      </div>
                      {entry.state && Object.keys(entry.state).length > 0 && (
                        <div className="text-xs text-gray-600 dark:text-gray-400 bg-gray-50 dark:bg-gray-700 p-2 rounded font-mono">
                          State: {JSON.stringify(entry.state, null, 2)}
                        </div>
                      )}
                    </div>
                  ))
                ) : (
                  <div className="text-sm text-gray-600 dark:text-gray-400 italic">No routing stack available</div>
                )}
              </div>
            </div>
          </div>

          <div className="flex flex-col">

            {/* Basic History Navigation */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">History Navigation</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Navigate through browser history using back() and forward navigation
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-wrap gap-3">
                  <button
                    onClick={goBack}
                    disabled={isNavigating.back}
                    className="flex-1 min-w-[140px] bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
                  >
                    {isNavigating.back ? 'Going Back...' : '← Back'}
                  </button>
                  <button
                    onClick={goForward}
                    disabled={isNavigating.forward}
                    className="flex-1 min-w-[140px] bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
                  >
                    {isNavigating.forward ? 'Going Forward...' : 'Forward →'}
                  </button>
                </div>
              </div>
            </div>

            {/* pushState vs replaceState */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">pushState vs replaceState</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Push adds to history stack, Replace modifies current entry without adding new history
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-4">
                  {/* Animation Page */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">Animation Page</div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded">
                        /css/animation
                      </code>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => navigateWithPush('/css/animation', { source: 'routing_demo' })}
                        className="flex-1 bg-green-600 hover:bg-green-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Push
                      </button>
                      <button
                        onClick={() => navigateWithReplace('/css/animation', { source: 'routing_demo' })}
                        className="flex-1 bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Replace
                      </button>
                    </div>
                  </div>

                  {/* Typography Page */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">Typography Page</div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded">
                        /typography
                      </code>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => navigateWithPush('/typography', { source: 'routing_demo' })}
                        className="flex-1 bg-green-600 hover:bg-green-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Push
                      </button>
                      <button
                        onClick={() => navigateWithReplace('/typography', { source: 'routing_demo' })}
                        className="flex-1 bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Replace
                      </button>
                    </div>
                  </div>

                  {/* Image Gallery */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">Image Gallery</div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded">
                        /image
                      </code>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => navigateWithPush('/image', { source: 'routing_demo' })}
                        className="flex-1 bg-green-600 hover:bg-green-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Push
                      </button>
                      <button
                        onClick={() => navigateWithReplace('/image', { source: 'routing_demo' })}
                        className="flex-1 bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Replace
                      </button>
                    </div>
                  </div>

                  {/* SVG Page */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">SVG via img</div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded">
                        /svg-image
                      </code>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => navigateWithPush('/svg-image', { source: 'routing_demo' })}
                        className="flex-1 bg-green-600 hover:bg-green-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Push
                      </button>
                      <button
                        onClick={() => navigateWithReplace('/svg-image', { source: 'routing_demo' })}
                        className="flex-1 bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                      >
                        Replace
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Advanced Navigation Methods */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Advanced Navigation Methods</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Flutter-style navigation methods with named routes and state management
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-4">
                  {/* push() */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">push()</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Push a new route onto the navigation stack
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        await WebFRouter.push(path, state)
                      </code>
                    </div>
                    <button
                      onClick={testPush}
                      disabled={isNavigating.advPush}
                      className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-400 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      {isNavigating.advPush ? 'Pushing...' : 'Test push()'}
                    </button>
                  </div>

                  {/* replace() */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">replace()</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Replace current route without adding to history
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        await WebFRouter.replace(path, state)
                      </code>
                    </div>
                    <button
                      onClick={testReplace}
                      disabled={isNavigating.advReplace}
                      className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-400 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      {isNavigating.advReplace ? 'Replacing...' : 'Test replace()'}
                    </button>
                  </div>

                  {/* popAndPushNamed() */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">popAndPushNamed()</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Pop current route and push a new one atomically
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        await WebFRouter.popAndPushNamed(path, state)
                      </code>
                    </div>
                    <button
                      onClick={testPopAndPushNamed}
                      disabled={isNavigating.popPush}
                      className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-400 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      {isNavigating.popPush ? 'Navigating...' : 'Test popAndPushNamed()'}
                    </button>
                  </div>

                  {/* restorablePopAndPushNamed() */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">restorablePopAndPushNamed()</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Pop and push with state restoration support
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        await WebFRouter.restorablePopAndPushNamed(path)
                      </code>
                    </div>
                    <button
                      onClick={testRestorablePopAndPush}
                      disabled={isNavigating.restorable}
                      className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-400 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      {isNavigating.restorable ? 'Creating...' : 'Test restorablePopAndPushNamed()'}
                    </button>
                  </div>
                </div>
              </div>
            </div>

            {/* Pop Detection Methods */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Pop Detection Methods</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Check if navigation can go back and conditionally pop routes
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-4">
                  {/* canPop() */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">canPop()</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Check if there are previous routes in the stack
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block mb-3">
                        const canPop = WebFRouter.canPop()
                      </code>
                    </div>
                    <button
                      onClick={testCanPop}
                      className="w-full bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors mb-2"
                    >
                      Test canPop()
                    </button>
                    {canPopResult !== null && (
                      <div className={`text-sm font-semibold p-2 rounded text-center ${canPopResult ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'}`}>
                        Result: {canPopResult ? 'Can pop' : 'Cannot pop'}
                      </div>
                    )}
                  </div>

                  {/* maybePop() */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">maybePop()</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Conditionally pop the current route if possible
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        WebFRouter.maybePop(result)
                      </code>
                    </div>
                    <button
                      onClick={testMaybePop}
                      className="w-full bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      Test maybePop()
                    </button>
                  </div>
                </div>
              </div>
            </div>

            {/* Dynamic Routes */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Dynamic Routes with Parameters</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Navigate to routes with dynamic parameters and complex state objects
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="space-y-4">
                  {/* User Details */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">User Details Page</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Dynamic route with user ID parameter
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        /user/:id → /user/123
                      </code>
                    </div>
                    <button
                      onClick={() => {
                        const userId = Math.floor(Math.random() * 1000);
                        navigateWithPush(`/user/${userId}`, { userId, userType: 'premium' });
                      }}
                      className="w-full bg-cyan-600 hover:bg-cyan-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      Navigate to Random User
                    </button>
                  </div>

                  {/* Report Details */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">Report Details Page</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Complex route with multiple nested parameters
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        /dashboard/:year/:month/reports/:id
                      </code>
                    </div>
                    <button
                      onClick={() => {
                        const year = new Date().getFullYear();
                        const month = String(new Date().getMonth() + 1).padStart(2, '0');
                        const reportId = `report-${Math.floor(Math.random() * 1000)}`;
                        navigateWithPush(`/dashboard/${year}/${month}/reports/${reportId}`, {
                          year,
                          month,
                          reportId,
                          department: 'sales',
                          format: 'pdf'
                        });
                      }}
                      className="w-full bg-cyan-600 hover:bg-cyan-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      Navigate to Report
                    </button>
                  </div>

                  {/* Profile Edit */}
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <div className="mb-3">
                      <div className="font-semibold text-gray-800 dark:text-white mb-1">Profile Edit Page</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        Navigate with complex state object including nested data
                      </div>
                      <code className="text-xs text-gray-600 dark:text-gray-400 bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded block">
                        /profile/edit
                      </code>
                    </div>
                    <button
                      onClick={() => {
                        navigateWithPush('/profile/edit', {
                          formData: {
                            name: 'John Doe',
                            email: 'john@example.com',
                            preferences: { theme: 'dark', language: 'en' }
                          },
                          scrollPosition: 250,
                          editMode: true
                        });
                      }}
                      className="w-full bg-cyan-600 hover:bg-cyan-700 text-white text-sm font-semibold py-2 px-4 rounded-lg transition-colors"
                    >
                      Navigate to Profile Edit
                    </button>
                  </div>
                </div>
              </div>
            </div>

            {/* API Reference */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">WebFRouter API Reference</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Complete list of available navigation methods
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="space-y-3">
                  {[
                    { method: 'WebFRouter.pushState(state, path)', desc: 'Add new entry to history stack' },
                    { method: 'WebFRouter.replaceState(state, path)', desc: 'Replace current history entry' },
                    { method: 'WebFRouter.back()', desc: 'Navigate to previous history entry' },
                    { method: 'WebFRouter.push(path, state)', desc: 'Push route onto navigation stack (async)' },
                    { method: 'WebFRouter.replace(path, state)', desc: 'Replace current route (async)' },
                    { method: 'WebFRouter.popAndPushNamed(path, state)', desc: 'Pop current and push new route' },
                    { method: 'WebFRouter.restorablePopAndPushNamed(path, state)', desc: 'Pop and push with restoration ID' },
                    { method: 'WebFRouter.canPop()', desc: 'Check if navigation can go back' },
                    { method: 'WebFRouter.maybePop(result)', desc: 'Conditionally pop if possible' },
                  ].map((api, index) => (
                    <div key={index} className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                      <code className="text-sm font-mono text-blue-600 dark:text-blue-400 block mb-2">
                        {api.method}
                      </code>
                      <div className="text-xs text-gray-600 dark:text-gray-400">
                        {api.desc}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};
