/// <reference path="../webf.d.ts" />
/// <reference path="../polyfill.d.ts" />

// Test that basic types exist
const doc: Document = document;
const win: Window = window;
const el: Element = doc.createElement('div');

// Test console exists
console.log('test');

// Export to make this a module
export {};