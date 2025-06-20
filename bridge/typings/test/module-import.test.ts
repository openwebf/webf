/*
 * Test file for module imports
 * This file tests importing WebF types as ES modules
 */

// Import types from the main entry point
import {
  console,
  fetch,
  Headers,
  Request,
  Response,
  URL,
  URLSearchParams,
  location,
  history,
  navigator,
  matchMedia,
  localStorage,
  sessionStorage,
  asyncStorage,
  XMLHttpRequest,
  WebSocket,
  ResizeObserver,
  DOMException,
  webf
} from '../index';

// Import type-only exports
import type {
  Console,
  WebfInstance,
  HeadersInit,
  RequestInit,
  ResponseInit,
  RequestMode,
  ResponseType,
  BodyInit,
  MediaQueryList,
  MediaQueryListEvent,
  LocationInterface,
  HistoryInterface,
  NavigatorInterface,
  XMLHttpRequestInterface,
  AsyncStorage,
  URLSearchParamsInterface,
  StorageInterface,
  URLInterface,
  WebSocketInterface,
  BoxSize,
  ResizeObserverEntry,
  ResizeObserverInterface,
  IdleRequestOptions,
  IdleRequestCallback,
  IdleDeadline,
  MethodCallHandler,
  MethodChannelInterface,
  HybridHistoryInterface,
  Webf,
  Fetch,
  MatchMedia,
  RequestIdleCallback,
  AddWebfModuleListener,
  ClearWebfModuleListener,
  RemoveWebfModuleListener
} from '../index';

// Test imported console
function testImportedConsole() {
  console.log('Testing imported console');
  console.info('Info from import');
  console.warn('Warning from import');
  console.error('Error from import');
  
  // Type check
  const consoleType: Console = console;
}

// Test imported fetch API
async function testImportedFetch() {
  // Basic fetch
  const response = await fetch('/api/data');
  console.log('Status:', response.status);
  
  // With Headers
  const headers = new Headers();
  headers.append('Content-Type', 'application/json');
  headers.append('Authorization', 'Bearer token');
  
  // With Request
  const request = new Request('/api/endpoint', {
    method: 'POST',
    headers: headers,
    body: JSON.stringify({ data: 'test' })
  });
  
  const response2 = await fetch(request);
  
  // Create Response
  const customResponse = new Response('Hello', {
    status: 200,
    statusText: 'OK',
    headers: new Headers({ 'Content-Type': 'text/plain' })
  });
  
  // Type checks
  const headersInit: HeadersInit = { 'X-Custom': 'value' };
  const requestInit: RequestInit = { method: 'GET' };
  const responseInit: ResponseInit = { status: 404 };
  const mode: RequestMode = 'cors';
  const responseType: ResponseType = 'basic';
  const body: BodyInit = 'text body';
}

// Test imported URL API
function testImportedURL() {
  const url = new URL('https://example.com/path?query=value');
  console.log('Host:', url.host);
  
  const params = new URLSearchParams('a=1&b=2');
  params.forEach((value, key) => {
    console.log(`${key}: ${value}`);
  });
  
  // Type checks
  const urlInterface: URLInterface = url;
  const paramsInterface: URLSearchParamsInterface = params;
}

// Test imported BOM objects
function testImportedBOM() {
  // Location
  console.log('Location href:', location.href);
  const locInterface: LocationInterface = location;
  
  // History
  console.log('History length:', history.length);
  const histInterface: HistoryInterface = history;
  
  // Navigator
  console.log('User agent:', navigator.userAgent);
  const navInterface: NavigatorInterface = navigator;
  
  // Storage
  localStorage.setItem('test', 'value');
  sessionStorage.setItem('session', 'data');
  
  asyncStorage.setItem('async', 'value').then(() => {
    console.log('Async storage set');
  });
  
  const storageInterface: StorageInterface = localStorage;
  const asyncInterface: AsyncStorage = asyncStorage;
  
  // Media query
  const mq = matchMedia('(max-width: 768px)');
  console.log('Matches:', mq.matches);
  
  const mqList: MediaQueryList = mq;
  const matchMediaFn: MatchMedia = matchMedia;
}

// Test imported constructors
function testImportedConstructors() {
  // XMLHttpRequest
  const xhr = new XMLHttpRequest();
  xhr.open('GET', '/api/data');
  xhr.send();
  
  const xhrInterface: XMLHttpRequestInterface = xhr;
  
  // WebSocket
  const ws = new WebSocket('wss://example.com/socket');
  ws.send('Hello');
  
  const wsInterface: WebSocketInterface = ws;
  
  // ResizeObserver
  const observer = new ResizeObserver((entries) => {
    entries.forEach(entry => {
      const size: BoxSize = entry.borderBoxSize;
      console.log('Size:', size.inlineSize, size.blockSize);
    });
  });
  
  const roInterface: ResizeObserverInterface = observer;
  const roEntry: ResizeObserverEntry = {
    target: document.body,
    borderBoxSize: { inlineSize: 100, blockSize: 200 },
    contentBoxSize: { inlineSize: 90, blockSize: 190 },
    contentRect: { width: 90, height: 190 }
  };
  
  // DOMException
  const error = new DOMException('Not found', 'NotFoundError');
  console.log('Error:', error.message);
}

// Test imported webf object
function testImportedWebf() {
  // Type check
  const webfObj: Webf = webf;
  const webfInstance: WebfInstance = webf;
  
  // Use webf methods
  webf.invokeModule('test', 'method');
  
  webf.invokeModuleAsync('test', 'async').then(result => {
    console.log('Async result:', result);
  });
  
  // Method channel
  const methodChannel: MethodChannelInterface = webf.methodChannel;
  methodChannel.invokeMethod('flutter', 'method').then(result => {
    console.log('Flutter result:', result);
  });
  
  // Hybrid history
  const hybridHistory: HybridHistoryInterface = webf.hybridHistory;
  hybridHistory.pushNamed('/route');
  
  // Module listeners
  const addListener: AddWebfModuleListener = webf.addWebfModuleListener;
  const clearListener: ClearWebfModuleListener = webf.clearWebfModuleListener;
  const removeListener: RemoveWebfModuleListener = webf.removeWebfModuleListener;
  
  // Idle callback
  const requestIdle: RequestIdleCallback = webf.requestIdleCallback;
  requestIdle((deadline: IdleDeadline) => {
    console.log('Time remaining:', deadline.timeRemaining());
  });
}

// Test type-only imports work correctly
function testTypeOnlyImports() {
  // These should only be used for type annotations
  let consoleType: Console;
  let fetchType: Fetch;
  let webfType: Webf;
  let methodHandler: MethodCallHandler;
  let idleCallback: IdleRequestCallback;
  let idleOptions: IdleRequestOptions;
  
  // Verify types compile correctly
  const handler: MethodCallHandler = (args: any[]) => {
    console.log('Handler called with:', args);
  };
  
  const callback: IdleRequestCallback = (deadline: IdleDeadline) => {
    while (deadline.timeRemaining() > 0) {
      // Do work
    }
  };
  
  const options: IdleRequestOptions = { timeout: 1000 };
}

// Export test runner
export function runModuleImportTests() {
  testImportedConsole();
  testImportedFetch();
  testImportedURL();
  testImportedBOM();
  testImportedConstructors();
  testImportedWebf();
  testTypeOnlyImports();
  console.log('All module import tests pass!');
}