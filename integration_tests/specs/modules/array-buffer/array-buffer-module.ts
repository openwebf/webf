/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

describe('ArrayBuffer Module', () => {
  it('should be able to receive array buffer data from JavaScript', async () => {
    // Create an ArrayBuffer with test data
    const buffer = new ArrayBuffer(16);
    const view = new Uint8Array(buffer);
    
    // Fill with test pattern
    for (let i = 0; i < view.length; i++) {
      view[i] = i + 1; // 1, 2, 3, ...
    }
    
    // Send the buffer to the native module
    // @ts-ignore
    const result = window.webf.invokeModule('ArrayBufferTest', 'receiveArrayBuffer', buffer);
    
    // Verify the result
    expect(result.received).toBe(true);
    expect(result.byteLength).toBe(16);
    expect(result.firstByte).toBe(1);
    expect(result.lastByte).toBe(16);
  });

  it('should handle callbacks with array buffer data', async () => {
    // Create a larger ArrayBuffer
    const buffer = new ArrayBuffer(32);
    const view = new Uint8Array(buffer);
    
    // Fill with test pattern
    for (let i = 0; i < view.length; i++) {
      view[i] = i * 2; // 0, 2, 4, ...
    }
    
    // Send the buffer to the native module with async callback
    // @ts-ignore
    const result = await window.webf.invokeModuleAsync('ArrayBufferTest', 'receiveAndCallback', buffer);
    
    // The callback result should be returned from the Promise as well
    expect(result.asyncProcessed).toBe(true);
    expect(result.byteLength).toBe(32);
  });

  it('should handle typed array views (Uint8Array)', async () => {
    // Create a Uint8Array directly
    const array = new Uint8Array([10, 20, 30, 40, 50]);
    
    // Send the typed array to the native module
    // @ts-ignore
    const result = await window.webf.invokeModuleAsync('ArrayBufferTest', 'receiveArrayBuffer', array.buffer);
    
    // Verify the result
    expect(result.received).toBe(true);
    expect(result.byteLength).toBe(5);
    expect(result.firstByte).toBe(10);
    expect(result.lastByte).toBe(50);
  });

  it('should handle zero-length array buffers', async () => {
    // Create an empty ArrayBuffer
    const buffer = new ArrayBuffer(0);
    
    // Send the buffer to the native module
    const result = await window.webf.invokeModuleAsync('ArrayBufferTest', 'receiveArrayBuffer', buffer);
    
    // Verify the result
    expect(result.received).toBe(true);
    expect(result.byteLength).toBe(0);
    expect(result.firstByte).toBe(null);
    expect(result.lastByte).toBe(null);
  });

  it('should handle large array buffers', async () => {
    // Create a larger buffer (100KB)
    const size = 100 * 1024;
    const buffer = new ArrayBuffer(size);
    const view = new Uint8Array(buffer);
    
    // Fill with a simple pattern
    for (let i = 0; i < size; i++) {
      view[i] = i % 256;
    }
    
    // Send the buffer to the native module
    const result = await window.webf.invokeModuleAsync('ArrayBufferTest', 'receiveArrayBuffer', buffer);
    
    // Verify the result
    expect(result.received).toBe(true);
    expect(result.byteLength).toBe(size);
    expect(result.firstByte).toBe(0);
    expect(result.lastByte).toBe(255);
  });
});