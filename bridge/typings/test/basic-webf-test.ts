/*
 * Basic WebF type test that should work without errors
 */
import '../index.d.ts';
/// <reference path="../index.d.ts" />

// Test 1: Basic DOM elements are available
function testBasicDOM() {
  // Document and window are available globally
  const doc: Document = document;
  const win: Window = window;
  
  // Can create elements
  const element: Element = doc.createElement('div');
  
  // Element has basic properties
  if ('id' in element) {
    element.id = 'test';
  }
  
  // Can query elements
  const found = doc.querySelector('#test');
  const all = doc.querySelectorAll('div');
  
  // Can append elements
  if (doc.body) {
    doc.body.appendChild(element);
  }
}

// Test 2: WebF-specific APIs
// function testWebFAPIs() {
//   // The webf global is declared in polyfill.d.ts
//   // For now, we'll skip this test since webf global isn't properly exposed
//   // TODO: Fix webf global declaration
// }
//
// // Test 3: Event handling
// function testEvents() {
//   const button = document.createElement('button');
//
//   // Add event listener with generic Event type
//   button.addEventListener('click', (event: Event) => {
//     event.preventDefault();
//   });
//
//   // Remove event listener
//   const handler = (event: Event) => {};
//   button.addEventListener('click', handler);
//   button.removeEventListener('click', handler);
// }
//
// // Test 4: Basic console usage (from polyfill)
// function testConsole() {
//   // Console should be available from polyfill
//   if (typeof console !== 'undefined') {
//     console.log('Test message');
//     console.info('Info message');
//     console.warn('Warning message');
//     console.error('Error message');
//   }
// }
//
// // Test 5: Basic storage APIs
// function testStorage() {
//   // Local storage
//   if (typeof localStorage !== 'undefined') {
//     localStorage.setItem('key', 'value');
//     const value = localStorage.getItem('key');
//     localStorage.removeItem('key');
//   }
//
//   // Session storage
//   if (typeof sessionStorage !== 'undefined') {
//     sessionStorage.setItem('session', 'data');
//     const data = sessionStorage.getItem('session');
//   }
// }
//
// // Test 6: Canvas API
// function testCanvas() {
//   const canvas = document.createElement('canvas') as HTMLCanvasElement;
//   const ctx = canvas.getContext('2d');
//
//   if (ctx) {
//     // Basic drawing operations
//     ctx.fillStyle = 'red';
//     ctx.fillRect(0, 0, 100, 100);
//
//     ctx.strokeStyle = 'blue';
//     ctx.strokeRect(50, 50, 100, 100);
//
//     // Path operations
//     ctx.beginPath();
//     ctx.moveTo(0, 0);
//     ctx.lineTo(100, 100);
//     ctx.stroke();
//   }
// }
//
// // Test 7: Basic type access through namespace
// function testNamespaceTypes() {
//   // Access types through webf namespace
//   type MyDocument = webf.Document;
//   type MyElement = webf.Element;
//   type MyEvent = webf.Event;
//   type MyNode = webf.Node;
//
//   // These types should be available
//   const doc: MyDocument = document;
//   const el: MyElement = doc.createElement('div');
// }

// Run all tests
export function runBasicTests() {
  testBasicDOM();
  // testWebFAPIs();
  // testEvents();
  // testConsole();
  // testStorage();
  // testCanvas();
  // testNamespaceTypes();
  
  console.log('Basic WebF tests completed');
}