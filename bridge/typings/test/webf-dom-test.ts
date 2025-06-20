/*
 * Simple test to verify WebF DOM types work without DOM lib
 */

/// <reference path="../index.d.ts" />

// Test that global document and window are available
const doc: Document = document;
const win: Window = window;

// Test basic element creation
const element: Element = doc.createElement('div');

// Test that HTMLElement types exist
function testHTMLElements() {
  // These types should be available from webf namespace
  type DivElement = webf.HTMLDivElement;
  type CanvasElement = webf.HTMLCanvasElement;
  type ImageElement = webf.HTMLImageElement;
  
  // Cast to specific types
  const div = doc.createElement('div') as webf.HTMLDivElement;
  const canvas = doc.createElement('canvas') as webf.HTMLCanvasElement;
  const img = doc.createElement('img') as webf.HTMLImageElement;
  
  // Test HTMLElement properties exist
  const divElement = doc.createElement('div') as webf.HTMLElement;
  if (divElement.offsetTop !== undefined) {
    console.log('offsetTop exists');
  }
}

// Test event handling
function testEvents() {
  const button = doc.createElement('button');
  
  // Test with generic Event
  button.addEventListener('click', (event: Event) => {
    console.log('Button clicked');
  });
  
  // Test event types exist
  type MouseEv = webf.MouseEvent;
  type KeyboardEv = webf.KeyboardEvent;
  type TouchEv = webf.TouchEvent;
}

// Test global APIs from polyfill
function testPolyfillGlobals() {
  // Console
  console.log('Console works');
  
  // Fetch
  fetch('/api').then(response => {
    console.log('Fetch works');
  });
  
  // Storage
  localStorage.setItem('key', 'value');
  sessionStorage.setItem('key', 'value');
  
  // WebF specific
  const webfApi: webf.Webf = webf;
  webfApi.invokeModule('test', 'method');
}

// Test namespace access
function testNamespaceTypes() {
  // All types should be available under webf namespace
  let doc: webf.Document;
  let el: webf.Element;
  let node: webf.Node;
  let event: webf.Event;
  let htmlEl: webf.HTMLElement;
}

console.log('WebF DOM types test completed');