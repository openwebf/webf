/*
 * Test file for global webf API typings
 * This file tests that the webf global object and its methods are properly typed
 */

/// <reference path="../index.d.ts" />

// Test global webf object exists
const webfInstance: webf.Webf = webf;

// Test webf properties
const doc: Document = webf.document;
const win: Window & typeof globalThis = webf.window;

// Test methodChannel API
webf.methodChannel.addMethodCallHandler('test', (args: any[]) => {
  console.log('Method called with args:', args);
});

webf.methodChannel.removeMethodCallHandler('test');
webf.methodChannel.clearMethodCallHandler();

// Test async method invocation
async function testMethodChannel() {
  const result: string = await webf.methodChannel.invokeMethod('flutter', 'showToast', 'Hello');
  console.log('Method result:', result);
}

// Test module invocation
const syncResult = webf.invokeModule('test', 'method', { data: 'test' });
console.log('Sync result:', syncResult);

async function testModuleInvocation() {
  const asyncResult = await webf.invokeModuleAsync<string>('test', 'asyncMethod', 'param1', 'param2');
  console.log('Async result:', asyncResult);
}

// Test module listeners
webf.addWebfModuleListener('navigation', (event: Event, extra: any) => {
  console.log('Navigation event:', event.type, extra);
});

webf.removeWebfModuleListener('navigation');
webf.clearWebfModuleListener();

// Test hybridHistory API
function testHybridHistory() {
  // State access
  const currentState: any = webf.hybridHistory.state;
  const currentPath: string = webf.hybridHistory.path;
  
  // Navigation methods
  webf.hybridHistory.back();
  webf.hybridHistory.pushState({ page: 1 }, 'page1');
  webf.hybridHistory.replaceState({ page: 2 }, 'page2');
  
  // Flutter-style navigation
  webf.hybridHistory.pop();
  webf.hybridHistory.pop({ result: 'data' });
  
  webf.hybridHistory.pushNamed('/home');
  webf.hybridHistory.pushNamed('/profile', { arguments: { userId: 123 } });
  
  webf.hybridHistory.pushReplacementNamed('/login');
  webf.hybridHistory.pushReplacementNamed('/dashboard', { arguments: { role: 'admin' } });
  
  // Navigation checks
  const canPop: boolean = webf.hybridHistory.canPop();
  const didPop: boolean = webf.hybridHistory.maybePop();
  
  // Advanced navigation
  webf.hybridHistory.popAndPushNamed('/settings');
  webf.hybridHistory.popUntil('/home');
  webf.hybridHistory.pushNamedAndRemoveUntil({ data: 'test' }, '/new', '/home');
  webf.hybridHistory.pushNamedAndRemoveUntilRoute('/new', '/home', { arguments: { clear: true } });
  
  // Restorable navigation
  const restorationId1: string = webf.hybridHistory.restorablePopAndPushState({ page: 3 }, 'page3');
  const restorationId2: string = webf.hybridHistory.restorablePopAndPushNamed('/restore', { arguments: {} });
}

// Test requestIdleCallback
webf.requestIdleCallback((deadline: IdleDeadline) => {
  console.log('Time remaining:', deadline.timeRemaining());
  console.log('Did timeout:', deadline.didTimeout);
});

// With timeout option
const idleHandle: number = webf.requestIdleCallback(
  (deadline) => {
    while (deadline.timeRemaining() > 0) {
      // Do work
    }
  },
  { timeout: 1000 }
);

// Test webf on window
const webfFromWindow: webf.Webf = window.webf;

// Test type exports from webf namespace
type WebfType = webf.Webf;
type ConsoleType = webf.Console;
type HeadersType = webf.Headers;
type RequestType = webf.Request;
type ResponseType = webf.Response;
type URLType = webf.URL;
type URLSearchParamsType = webf.URLSearchParams;

// Verify all APIs compile without errors
export function runAllTests() {
  testMethodChannel();
  testModuleInvocation();
  testHybridHistory();
  console.log('All webf API typing tests pass!');
}