/// <reference path="../index.d.ts" />
import type { Console } from '../polyfill';

// Test 1: Basic globals are available
const doc: Document = document;
const win: Window = window;
const cons: Console = console;

// Test 2: Basic DOM operations
const div = document.createElement('div');
div.id = 'test';
document.body?.appendChild(div);

// Test 3: Events
div.addEventListener('click', (event) => {
  console.log('Clicked');
});

// Test 4: Storage
localStorage.setItem('key', 'value');
const value = localStorage.getItem('key');

// Test 5: Console
console.log('Test log');
console.error('Test error');

// Test 6: Basic types from webf namespace
type MyDocument = webf.Document;
type MyElement = webf.Element;
type MyEvent = webf.Event;

// Test completed
console.log('Simple test completed');