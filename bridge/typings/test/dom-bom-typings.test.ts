/*
 * Test file for DOM/BOM typings
 * This file tests that DOM and BOM APIs are properly typed in WebF
 */

/// <reference path="../index.d.ts" />

// Test Document API
function testDocumentAPI() {
  const doc: Document = document;
  
  // Element creation
  const div: HTMLDivElement = doc.createElement('div');
  const canvas: HTMLCanvasElement = doc.createElement('canvas');
  const img: HTMLImageElement = doc.createElement('img');
  const video: HTMLVideoElement = doc.createElement('video');
  const anchor: HTMLAnchorElement = doc.createElement('a');
  const button: HTMLButtonElement = doc.createElement('button');
  const input: HTMLInputElement = doc.createElement('input');
  const form: HTMLFormElement = doc.createElement('form');
  const iframe: HTMLIFrameElement = doc.createElement('iframe');
  const script: HTMLScriptElement = doc.createElement('script');
  const style: HTMLStyleElement = doc.createElement('style');
  const link: HTMLLinkElement = doc.createElement('link');
  const template: HTMLTemplateElement = doc.createElement('template');
  const textarea: HTMLTextAreaElement = doc.createElement('textarea');
  
  // Query methods
  const element: Element | null = doc.querySelector('.class');
  const elements: NodeListOf<Element> = doc.querySelectorAll('div');
  const byId: HTMLElement | null = doc.getElementById('id');
  const byClass: HTMLCollectionOf<Element> = doc.getElementsByClassName('class');
  const byTag: HTMLCollectionOf<HTMLDivElement> = doc.getElementsByTagName('div');
  
  // Document properties
  const body: HTMLBodyElement | null = doc.body;
  const head: HTMLHeadElement = doc.head;
  const html: HTMLHtmlElement = doc.documentElement;
  const title: string = doc.title;
  const cookie: string = doc.cookie;
  
  // Document methods
  const fragment: DocumentFragment = doc.createDocumentFragment();
  const text: Text = doc.createTextNode('text');
  const comment: Comment = doc.createComment('comment');
  const attr: Attr = doc.createAttribute('data-test');
  const event: Event = doc.createEvent('Event');
  
  // Custom elements
  const customEl: HTMLElement = doc.createElement('custom-element');
}

// Test Element API
function testElementAPI() {
  const div = document.createElement('div');
  
  // Properties
  div.id = 'test-id';
  div.className = 'test-class';
  div.innerHTML = '<span>test</span>';
  div.innerText = 'test text';
  div.textContent = 'test content';
  
  // Attributes
  div.setAttribute('data-test', 'value');
  const attrValue: string | null = div.getAttribute('data-test');
  div.removeAttribute('data-test');
  const hasAttr: boolean = div.hasAttribute('data-test');
  
  // Classes
  div.classList.add('new-class');
  div.classList.remove('old-class');
  div.classList.toggle('toggle-class');
  const hasClass: boolean = div.classList.contains('test-class');
  
  // Style
  div.style.width = '100px';
  div.style.height = '200px';
  div.style.backgroundColor = 'red';
  div.style.setProperty('color', 'blue');
  const color: string = div.style.getPropertyValue('color');
  div.style.removeProperty('color');
  
  // Computed style
  const computed: CSSStyleDeclaration = window.getComputedStyle(div);
  const width: string = computed.width;
  
  // DOM manipulation
  const child = document.createElement('span');
  div.appendChild(child);
  div.insertBefore(child, null);
  div.removeChild(child);
  div.replaceChild(document.createElement('p'), child);
  
  // Query within element
  const span: HTMLElement | null = div.querySelector('span');
  const spans: NodeListOf<HTMLSpanElement> = div.querySelectorAll('span');
  
  // Dimensions
  const rect: DOMRect = div.getBoundingClientRect();
  const width2: number = div.offsetWidth;
  const height: number = div.offsetHeight;
  const scrollTop: number = div.scrollTop;
  const scrollLeft: number = div.scrollLeft;
}

// Test Event API
function testEventAPI() {
  const button = document.createElement('button');
  
  // Event listeners
  button.addEventListener('click', (e: MouseEvent) => {
    console.log('Clicked at:', e.clientX, e.clientY);
    e.preventDefault();
    e.stopPropagation();
  });
  
  button.addEventListener('touchstart', (e: TouchEvent) => {
    const touch: Touch = e.touches[0];
    console.log('Touch at:', touch.clientX, touch.clientY);
  });
  
  button.addEventListener('keydown', (e: KeyboardEvent) => {
    console.log('Key pressed:', e.key, e.code);
  });
  
  // Custom events
  const customEvent = new CustomEvent('custom', {
    detail: { data: 'test' },
    bubbles: true,
    cancelable: true
  });
  button.dispatchEvent(customEvent);
  
  // Event properties
  button.onclick = (e: MouseEvent) => console.log('onclick');
  button.onmouseenter = (e: MouseEvent) => console.log('onmouseenter');
  button.onmouseleave = (e: MouseEvent) => console.log('onmouseleave');
  
  // Form events
  const input = document.createElement('input');
  input.addEventListener('input', (e: InputEvent) => {
    console.log('Input data:', e.data);
  });
  
  input.addEventListener('change', (e: Event) => {
    const target = e.target as HTMLInputElement;
    console.log('Changed to:', target.value);
  });
  
  // Focus events
  input.addEventListener('focus', (e: FocusEvent) => {
    console.log('Focused');
  });
  
  input.addEventListener('blur', (e: FocusEvent) => {
    console.log('Blurred');
  });
}

// Test Canvas API
function testCanvasAPI() {
  const canvas = document.createElement('canvas');
  const ctx: CanvasRenderingContext2D | null = canvas.getContext('2d');
  
  if (ctx) {
    // Drawing
    ctx.fillStyle = 'red';
    ctx.fillRect(0, 0, 100, 100);
    
    ctx.strokeStyle = 'blue';
    ctx.lineWidth = 2;
    ctx.strokeRect(50, 50, 100, 100);
    
    // Path
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(100, 100);
    ctx.stroke();
    
    // Text
    ctx.font = '16px Arial';
    ctx.fillText('Hello WebF', 10, 50);
    
    // Gradients
    const gradient: CanvasGradient = ctx.createLinearGradient(0, 0, 100, 100);
    gradient.addColorStop(0, 'red');
    gradient.addColorStop(1, 'blue');
    ctx.fillStyle = gradient;
    
    // Pattern
    const img = new Image();
    const pattern: CanvasPattern | null = ctx.createPattern(img, 'repeat');
    if (pattern) {
      ctx.fillStyle = pattern;
    }
    
    // Transform
    ctx.translate(50, 50);
    ctx.rotate(Math.PI / 4);
    ctx.scale(2, 2);
    
    // Image
    ctx.drawImage(img, 0, 0);
    
    // Save/restore
    ctx.save();
    ctx.restore();
  }
  
  // Canvas blob
  canvas.toBlob(1).then((blob: Blob) => {
    console.log('Blob size:', blob.size);
  });
}

// Test BOM APIs
function testBOMAPIs() {
  // Console
  console.log('Log message');
  console.info('Info message');
  console.warn('Warning message');
  console.error('Error message');
  console.debug('Debug message');
  console.trace('Trace');
  console.time('timer');
  console.timeEnd('timer');
  console.group('Group');
  console.groupEnd();
  console.table([{ a: 1, b: 2 }], ['a']);
  console.assert(true, 'Assertion');
  console.count('counter');
  console.countReset('counter');
  console.clear();
  
  // Fetch API
  fetch('/api/data')
    .then((response: Response) => {
      console.log('Status:', response.status);
      console.log('OK:', response.ok);
      return response.json();
    })
    .then((data: any) => {
      console.log('Data:', data);
    });
  
  // With options
  const headers = new Headers({
    'Content-Type': 'application/json'
  });
  
  const request = new Request('/api/data', {
    method: 'POST',
    headers: headers,
    body: JSON.stringify({ data: 'test' })
  });
  
  fetch(request).then((response: Response) => {
    console.log('Response:', response);
  });
  
  // URL API
  const url = new URL('https://example.com/path?query=value#hash');
  console.log('Protocol:', url.protocol);
  console.log('Host:', url.host);
  console.log('Pathname:', url.pathname);
  console.log('Search:', url.search);
  console.log('Hash:', url.hash);
  
  // URLSearchParams
  const params = new URLSearchParams('a=1&b=2');
  params.append('c', '3');
  params.set('a', '10');
  params.delete('b');
  console.log('Has a:', params.has('a'));
  console.log('Get a:', params.get('a'));
  console.log('String:', params.toString());
  
  // Location
  console.log('Current URL:', location.href);
  console.log('Origin:', location.origin);
  console.log('Pathname:', location.pathname);
  // location.assign('/new-page');
  // location.replace('/new-page');
  // location.reload();
  
  // History
  console.log('History length:', history.length);
  console.log('History state:', history.state);
  history.pushState({ page: 1 }, 'Page 1', '/page1');
  history.replaceState({ page: 2 }, 'Page 2', '/page2');
  // history.back();
  // history.forward();
  // history.go(-1);
  
  // Navigator
  console.log('User Agent:', navigator.userAgent);
  console.log('Platform:', navigator.platform);
  console.log('Language:', navigator.language);
  console.log('Languages:', navigator.languages);
  console.log('App Name:', navigator.appName);
  console.log('App Version:', navigator.appVersion);
  console.log('Hardware Concurrency:', navigator.hardwareConcurrency);
  
  // Clipboard
  navigator.clipboard.writeText('Hello WebF').then(() => {
    console.log('Text copied');
  });
  
  navigator.clipboard.readText().then((text: string) => {
    console.log('Clipboard text:', text);
  });
  
  // Storage
  localStorage.setItem('key', 'value');
  const value: string | null = localStorage.getItem('key');
  localStorage.removeItem('key');
  localStorage.clear();
  console.log('Storage length:', localStorage.length);
  const keys: string[] = localStorage.getAllKeys();
  
  sessionStorage.setItem('session', 'data');
  const sessionData: string | null = sessionStorage.getItem('session');
  
  // Async storage
  asyncStorage.setItem('async', 'value').then(() => {
    return asyncStorage.getItem('async');
  }).then((value: string) => {
    console.log('Async value:', value);
  });
  
  // Media queries
  const mq: MediaQueryList = matchMedia('(min-width: 768px)');
  console.log('Matches:', mq.matches);
  console.log('Media:', mq.media);
  mq.addListener((e: MediaQueryListEvent) => {
    console.log('Media query changed:', e.matches);
  });
}

// Test XMLHttpRequest
function testXMLHttpRequest() {
  const xhr = new XMLHttpRequest();
  
  xhr.onreadystatechange = function() {
    if (xhr.readyState === xhr.DONE) {
      if (xhr.status === 200) {
        console.log('Response:', xhr.responseText);
      }
    }
  };
  
  xhr.open('GET', '/api/data', true);
  xhr.setRequestHeader('X-Custom-Header', 'value');
  xhr.send();
  
  // Properties
  console.log('Ready state:', xhr.readyState);
  console.log('Status:', xhr.status);
  console.log('Status text:', xhr.statusText);
  console.log('Response type:', xhr.responseType);
  console.log('With credentials:', xhr.withCredentials);
  
  // Methods
  const header: string | null = xhr.getResponseHeader('Content-Type');
  const allHeaders: string = xhr.getAllResponseHeaders();
  // xhr.abort();
}

// Test WebSocket
function testWebSocket() {
  const ws = new WebSocket('wss://example.com/socket', 'protocol');
  
  ws.addEventListener('open', (event: Event) => {
    console.log('WebSocket opened');
    ws.send('Hello Server');
  });
  
  ws.addEventListener('message', (event: MessageEvent) => {
    console.log('Received:', event.data);
  });
  
  ws.addEventListener('close', (event: CloseEvent) => {
    console.log('WebSocket closed:', event.code, event.reason);
  });
  
  ws.addEventListener('error', (event: Event) => {
    console.error('WebSocket error');
  });
  
  // Properties
  console.log('Ready state:', ws.readyState);
  console.log('URL:', ws.url);
  console.log('Protocol:', ws.protocol);
  console.log('Extensions:', ws.extensions);
  console.log('Binary type:', ws.binaryType);
  
  // Constants
  console.log('CONNECTING:', ws.CONNECTING);
  console.log('OPEN:', ws.OPEN);
  console.log('CLOSING:', ws.CLOSING);
  console.log('CLOSED:', ws.CLOSED);
  
  // Close with code and reason
  ws.close(1000, 'Normal closure');
}

// Test ResizeObserver
function testResizeObserver() {
  const observer = new ResizeObserver((entries: ResizeObserverEntry[]) => {
    for (const entry of entries) {
      console.log('Target:', entry.target);
      console.log('Content rect:', entry.contentRect.width, entry.contentRect.height);
      console.log('Border box size:', entry.borderBoxSize.inlineSize, entry.borderBoxSize.blockSize);
      console.log('Content box size:', entry.contentBoxSize.inlineSize, entry.contentBoxSize.blockSize);
    }
  });
  
  const div = document.createElement('div');
  observer.observe(div);
  observer.unobserve(div);
  observer.disconnect();
}

// Test MutationObserver
function testMutationObserver() {
  const observer = new MutationObserver((mutations: MutationRecord[]) => {
    for (const mutation of mutations) {
      console.log('Type:', mutation.type);
      console.log('Target:', mutation.target);
      
      if (mutation.type === 'childList') {
        console.log('Added nodes:', mutation.addedNodes);
        console.log('Removed nodes:', mutation.removedNodes);
      } else if (mutation.type === 'attributes') {
        console.log('Attribute:', mutation.attributeName);
        console.log('Old value:', mutation.oldValue);
      }
    }
  });
  
  const div = document.createElement('div');
  observer.observe(div, {
    childList: true,
    attributes: true,
    characterData: true,
    subtree: true,
    attributeOldValue: true,
    characterDataOldValue: true
  });
  
  const records: MutationRecord[] = observer.takeRecords();
  observer.disconnect();
}

// Test Blob and File APIs
function testBlobFileAPIs() {
  // Blob
  const blob = new Blob(['Hello WebF'], { type: 'text/plain' });
  console.log('Blob size:', blob.size);
  console.log('Blob type:', blob.type);
  
  blob.text().then((text: string) => {
    console.log('Blob text:', text);
  });
  
  blob.arrayBuffer().then((buffer: ArrayBuffer) => {
    console.log('Blob buffer:', buffer.byteLength);
  });
  
  const sliced: Blob = blob.slice(0, 5, 'text/plain');
  
  // File
  const file = new File(['content'], 'filename.txt', {
    type: 'text/plain',
    lastModified: Date.now()
  });
  
  console.log('File name:', file.name);
  console.log('File size:', file.size);
  console.log('File type:', file.type);
  console.log('Last modified:', file.lastModified);
  
  // FileList (from input element)
  const input = document.createElement('input');
  input.type = 'file';
  // After file selection:
  // const files: FileList = input.files!;
  // const firstFile: File = files[0];
  // console.log('File count:', files.length);
}

// Test FormData
function testFormData() {
  const formData = new FormData();
  
  formData.append('name', 'value');
  formData.append('file', new Blob(['content']), 'filename.txt');
  
  const hasName: boolean = formData.has('name');
  formData.delete('name');
  formData.set('name', 'new value');
  
  // With form element
  const form = document.createElement('form');
  const formData2 = new FormData(form);
}

// Test Performance API
function testPerformanceAPI() {
  // Performance timing
  console.log('Navigation start:', performance.timeOrigin);
  
  // Performance marks
  performance.mark('start');
  // Do some work
  performance.mark('end');
  
  // Performance measure
  performance.measure('duration', 'start', 'end');
  
  // Get entries
  const entries: PerformanceEntry[] = performance.getEntries();
  const marks: PerformanceEntry[] = performance.getEntriesByType('mark');
  const measures: PerformanceEntry[] = performance.getEntriesByType('measure');
  const named: PerformanceEntry[] = performance.getEntriesByName('start');
  
  // Clear marks and measures
  performance.clearMarks('start');
  performance.clearMeasures('duration');
  
  // Now
  const now: number = performance.now();
  console.log('Time since origin:', now);
}

// Test Screen API
function testScreenAPI() {
  console.log('Screen width:', screen.width);
  console.log('Screen height:', screen.height);
  console.log('Available width:', screen.availWidth);
  console.log('Available height:', screen.availHeight);
  console.log('Color depth:', screen.colorDepth);
  console.log('Pixel depth:', screen.pixelDepth);
}

// Test DOMException
function testDOMException() {
  try {
    throw new DOMException('Something went wrong', 'NotFoundError');
  } catch (e) {
    if (e instanceof DOMException) {
      console.log('DOMException message:', e.message);
      console.log('DOMException name:', e.name);
    }
  }
}

// Run all tests
export function runAllDOMBOMTests() {
  testDocumentAPI();
  testElementAPI();
  testEventAPI();
  testCanvasAPI();
  testBOMAPIs();
  testXMLHttpRequest();
  testWebSocket();
  testResizeObserver();
  testMutationObserver();
  testBlobFileAPIs();
  testFormData();
  testPerformanceAPI();
  testScreenAPI();
  testDOMException();
  console.log('All DOM/BOM typing tests pass!');
}