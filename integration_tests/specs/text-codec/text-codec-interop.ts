describe('TextEncoder/TextDecoder Interoperability', () => {
  it('should work together for basic text', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    const original = 'Hello, World!';
    
    const encoded = encoder.encode(original);
    const decoded = decoder.decode(encoded);
    
    expect(decoded).toBe(original);
  });

  it('should work together for empty strings', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    const original = '';
    
    const encoded = encoder.encode(original);
    const decoded = decoder.decode(encoded);
    
    expect(decoded).toBe(original);
    expect(encoded.length).toBe(0);
  });

  it('should preserve Unicode characters', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    const testCases = [
      'café',
      '你好世界',
      'Здравствуй мир',
      'مرحبا بالعالم',
      '🌍🚀💻',
      '✨🎉🌟',
      'Math: ∑∞≠≈±',
      'Currency: €$¥£₹',
      'Arrows: ←↑→↓↖↗↘↙',
    ];

    testCases.forEach(original => {
      const encoded = encoder.encode(original);
      const decoded = decoder.decode(encoded);
      expect(decoded).toBe(original);
    });
  });

  it('should handle complex mixed content', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    const original = `
      Mixed content test:
      - ASCII: Hello World 123
      - Latin: café résumé naïve
      - Cyrillic: Привет мир
      - Chinese: 你好世界
      - Arabic: مرحبا
      - Emoji: 🌍🚀💻✨
      - Symbols: ©®™℠
      - Math: ∑∞≠≈±∴∵
      - Special: \t\n\r\\/"'
    `;
    
    const encoded = encoder.encode(original);
    const decoded = decoder.decode(encoded);
    
    expect(decoded).toBe(original);
  });

  it('should work with different ArrayBuffer types', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    const original = 'Test 测试 🧪';
    
    const uint8Array = encoder.encode(original);
    
    // Test with ArrayBuffer
    const arrayBuffer = uint8Array.buffer.slice(uint8Array.byteOffset, uint8Array.byteOffset + uint8Array.byteLength);
    expect(decoder.decode(arrayBuffer)).toBe(original);
    
    // Test with Int8Array
    const int8Array = new Int8Array(uint8Array.buffer, uint8Array.byteOffset, uint8Array.byteLength);
    expect(decoder.decode(int8Array)).toBe(original);
    
    // Test with DataView
    const dataView = new DataView(uint8Array.buffer, uint8Array.byteOffset, uint8Array.byteLength);
    expect(decoder.decode(dataView)).toBe(original);
  });

  it('should handle encodeInto with decode', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    const original = 'Hello 世界 🌍';
    
    // Use encodeInto
    const buffer = new Uint8Array(50); // Large enough buffer
    const result = encoder.encodeInto(original, buffer);
    
    // Decode only the written portion
    const encoded = buffer.slice(0, result.written);
    const decoded = decoder.decode(encoded);
    
    expect(decoded).toBe(original);
    expect(result.read).toBe(original.length);
  });

  it('should handle partial encodeInto results', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    const original = 'Hello 世界';
    
    // Use a small buffer that can't fit the entire string
    const buffer = new Uint8Array(8); // Should fit "Hello " but not the Chinese characters
    const result = encoder.encodeInto(original, buffer);
    
    const decoded = decoder.decode(buffer.slice(0, result.written));
    
    // Should contain the partial string that fit in the buffer
    expect(decoded).toBe('Hello ');
    expect(result.read).toBeLessThan(original.length);
    expect(result.written).toBe(6); // "Hello " = 6 bytes
  });

  it('should preserve data through multiple encode/decode cycles', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    let text = 'Original text 原始文本 🔄';
    
    // Encode and decode multiple times
    for (let i = 0; i < 5; i++) {
      const encoded = encoder.encode(text);
      text = decoder.decode(encoded);
    }
    
    expect(text).toBe('Original text 原始文本 🔄');
  });

  it('should work with very large texts', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    
    // Create a large string with various Unicode characters
    const chunk = 'Hello 世界 🌍 café résumé ';
    const original = chunk.repeat(1000); // ~25KB of text
    
    const encoded = encoder.encode(original);
    const decoded = decoder.decode(encoded);
    
    expect(decoded).toBe(original);
    expect(decoded.length).toBe(original.length);
  });

  it('should handle BOM correctly in round-trip', () => {
    const encoder = new TextEncoder();
    const decoder = new TextDecoder('utf-8', { ignoreBOM: false });
    const original = 'Test text';
    
    // Manually create UTF-8 with BOM
    const encoded = encoder.encode(original);
    const withBOM = new Uint8Array(3 + encoded.length);
    withBOM.set([0xEF, 0xBB, 0xBF], 0); // UTF-8 BOM
    withBOM.set(encoded, 3);
    
    const decoded = decoder.decode(withBOM);
    expect(decoded).toBe(original); // BOM should be stripped
  });

  describe('Error consistency', () => {
    it('should handle encoding errors consistently', () => {
      const encoder = new TextEncoder();
      const fatalDecoder = new TextDecoder('utf-8', { fatal: true });
      const nonFatalDecoder = new TextDecoder('utf-8', { fatal: false });
      
      // Create invalid UTF-8 sequence
      const invalidBytes = new Uint8Array([0xFF, 0xFE, 0xFD]);
      
      // Fatal decoder should throw
      expect(() => fatalDecoder.decode(invalidBytes)).toThrow();
      
      // Non-fatal decoder should handle gracefully
      const result = nonFatalDecoder.decode(invalidBytes);
      expect(typeof result).toBe('string');
    });
  });

  describe('Performance characteristics', () => {
    it('should handle repeated operations efficiently', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      const original = 'Performance test 性能测试 ⚡';
      
      // Perform many encode/decode operations
      for (let i = 0; i < 100; i++) {
        const encoded = encoder.encode(original);
        const decoded = decoder.decode(encoded);
        expect(decoded).toBe(original);
      }
    });

    it('should reuse encoder/decoder instances efficiently', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      
      const testStrings = [
        'ASCII text',
        'Unicode: 你好',
        'Emoji: 🎯',
        'Mixed: Hello 世界 🌍',
        'Symbols: ©®™',
      ];
      
      testStrings.forEach(original => {
        const encoded = encoder.encode(original);
        const decoded = decoder.decode(encoded);
        expect(decoded).toBe(original);
      });
    });
  });

  describe('Edge cases', () => {
    it('should handle strings with null bytes', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      const original = 'Before\0After';
      
      const encoded = encoder.encode(original);
      const decoded = decoder.decode(encoded);
      
      expect(decoded).toBe(original);
      expect(decoded.includes('\0')).toBe(true);
    });

    it('should handle strings with control characters', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      const original = 'Line1\nLine2\tTabbed\rCarriageReturn';
      
      const encoded = encoder.encode(original);
      const decoded = decoder.decode(encoded);
      
      expect(decoded).toBe(original);
    });

    it('should handle surrogate pairs correctly', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      const original = '𝒽𝑒𝓁𝓁𝑜'; // Mathematical script characters (surrogate pairs)
      
      const encoded = encoder.encode(original);
      const decoded = decoder.decode(encoded);
      
      expect(decoded).toBe(original);
    });
  });
});