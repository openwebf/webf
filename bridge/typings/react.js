/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a AGPL-3.0 license that can be
 * found in the LICENSE file.
 */

// React utility implementations for WebF

/**
 * Cast a standard DOM element to its WebF equivalent
 */
export function toWebF(element) {
  return element;
}

/**
 * Type guard to check if an element supports WebF features
 */
export function isWebFElement(element) {
  return element && typeof element.toBlob === 'function';
}

/**
 * Utility to create a WebF-aware event handler
 */
export function webfEventHandler(handler) {
  return (event) => {
    handler(event);
  };
}

/**
 * React hook for WebF elements
 * Note: This requires React to be available
 */
export function useWebFRef() {
  // Try to get React from various sources
  let ReactLib;
  
  // Check if React is globally available
  if (typeof React !== 'undefined') {
    ReactLib = React;
  }
  // Check if we can import it (ES modules)
  else if (typeof require !== 'undefined') {
    try {
      ReactLib = require('react');
    } catch (e) {
      // React not available via require
    }
  }
  
  if (!ReactLib || !ReactLib.useRef) {
    throw new Error(
      'useWebFRef requires React. Make sure to:\n' +
      '1. Install React: npm install react\n' +
      '2. Import React before using this hook: import React from "react"'
    );
  }
  
  const ref = ReactLib.useRef(null);
  
  return {
    ref,
    get webf() {
      return toWebF(ref.current);
    }
  };
}