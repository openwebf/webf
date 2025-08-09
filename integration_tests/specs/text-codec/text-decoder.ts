describe('TextDecoder', () => {
  it('should exist and be a constructor', () => {
    expect(typeof TextDecoder).toBe('function');
    expect(TextDecoder.prototype.decode).toBeDefined();
  });

  it('should have default encoding utf-8', () => {
    const decoder = new TextDecoder();
    expect(decoder.encoding).toBe('utf-8');
    expect(decoder.fatal).toBe(false);
    expect(decoder.ignoreBOM).toBe(false);
  });

  it('should accept encoding parameter', () => {
    const utf8Decoder = new TextDecoder('utf-8');
    expect(utf8Decoder.encoding).toBe('utf-8');

    const asciiDecoder = new TextDecoder('ascii');
    expect(asciiDecoder.encoding).toBe('ascii');

    const latin1Decoder = new TextDecoder('latin1');
    expect(latin1Decoder.encoding).toBe('latin1');
  });

  it('should accept options parameter', () => {
    const decoder = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true });
    expect(decoder.fatal).toBe(true);
    expect(decoder.ignoreBOM).toBe(true);
  });

  it('should decode empty buffer', () => {
    const decoder = new TextDecoder();
    const result = decoder.decode(new Uint8Array([]));
    expect(result).toBe('');
  });

  it('should decode undefined/null input', () => {
    const decoder = new TextDecoder();
    expect(decoder.decode()).toBe('');
    expect(decoder.decode(undefined)).toBe('');
  });

  it('should decode ASCII string', () => {
    const decoder = new TextDecoder();
    const bytes = new Uint8Array([0x68, 0x65, 0x6c, 0x6c, 0x6f]);
    const result = decoder.decode(bytes);
    expect(result).toBe('hello');
  });

  it('should decode UTF-8 string with special characters', () => {
    const decoder = new TextDecoder();
    const bytes = new Uint8Array([0x63, 0x61, 0x66, 0xc3, 0xa9]);
    const result = decoder.decode(bytes);
    expect(result).toBe('café');
  });

  it('should decode emoji characters', () => {
    const decoder = new TextDecoder();
    const bytes = new Uint8Array([0xf0, 0x9f, 0x99, 0x82]);
    const result = decoder.decode(bytes);
    expect(result).toBe('🙂');
  });

  it('should decode Chinese characters', () => {
    const decoder = new TextDecoder();
    const bytes = new Uint8Array([0xe4, 0xbd, 0xa0, 0xe5, 0xa5, 0xbd]);
    const result = decoder.decode(bytes);
    expect(result).toBe('你好');
  });

  it('should handle BOM in UTF-8', () => {
    const decoder = new TextDecoder('utf-8');
    // UTF-8 BOM: EF BB BF + "hello"
    const bytes = new Uint8Array([0xef, 0xbb, 0xbf, 0x68, 0x65, 0x6c, 0x6c, 0x6f]);
    const result = decoder.decode(bytes);
    expect(result).toBe('hello'); // BOM should be stripped by default
  });

  it('should respect ignoreBOM option', () => {
    const decoderIgnoreBOM = new TextDecoder('utf-8', { ignoreBOM: true });
    const decoderKeepBOM = new TextDecoder('utf-8', { ignoreBOM: false });

    // UTF-8 BOM: EF BB BF + "hello"
    const bytes = new Uint8Array([0xef, 0xbb, 0xbf, 0x68, 0x65, 0x6c, 0x6c, 0x6f]);

    const resultIgnore = decoderIgnoreBOM.decode(bytes);
    const resultKeep = decoderKeepBOM.decode(bytes);

    expect(resultIgnore).toBe('hello');
    expect(resultKeep).toBe('hello'); // BOM should still be removed when ignoreBOM is false
  });

  describe('different input types', () => {
    const decoder = new TextDecoder();
    const testBytes = [0x68, 0x65, 0x6c, 0x6c, 0x6f]; // "hello"

    it('should decode ArrayBuffer', () => {
      const buffer = new ArrayBuffer(5);
      const view = new Uint8Array(buffer);
      view.set(testBytes);

      const result = decoder.decode(buffer);
      expect(result).toBe('hello');
    });

    it('should decode Uint8Array', () => {
      const bytes = new Uint8Array(testBytes);
      const result = decoder.decode(bytes);
      expect(result).toBe('hello');
    });

    it('should decode Int8Array', () => {
      const bytes = new Int8Array(testBytes);
      const result = decoder.decode(bytes);
      expect(result).toBe('hello');
    });

    it('should decode Uint16Array', () => {
      // Note: This tests the bytes interpretation, not UTF-16
      const uint16 = new Uint16Array([0x6568, 0x6c6c, 0x006f]); // little-endian "hello"
      const result = decoder.decode(uint16);
      expect(result).toBe('hello\0');
    });

    it('should decode DataView', () => {
      const buffer = new ArrayBuffer(5);
      const view = new DataView(buffer);
      testBytes.forEach((byte, i) => view.setUint8(i, byte));

      const result = decoder.decode(view);
      expect(result).toBe('hello');
    });

    it('should throw TypeError for invalid input', () => {
      expect(() => decoder.decode('string' as any)).toThrowError(TypeError);
      expect(() => decoder.decode(123 as any)).toThrowError(TypeError);
      expect(() => decoder.decode({} as any)).toThrowError(TypeError);
    });
  });

  describe('encoding support', () => {
    it('should decode ASCII', () => {
      const decoder = new TextDecoder('ascii');
      const bytes = new Uint8Array([0x68, 0x65, 0x6c, 0x6c, 0x6f]);
      const result = decoder.decode(bytes);
      expect(result).toBe('hello');
    });

    it('should decode latin1/iso-8859-1', () => {
      const decoder = new TextDecoder('latin1');
      const bytes = new Uint8Array([0x48, 0xe9, 0x6c, 0x6c, 0x6f]); // "Héllo" in Latin1
      const result = decoder.decode(bytes);
      expect(result).toBe('Héllo');
    });

    it('should handle case-insensitive encoding names', () => {
      const utf8Decoder = new TextDecoder('UTF-8');
      const asciiDecoder = new TextDecoder('US-ASCII');
      const latin1Decoder = new TextDecoder('ISO-8859-1');

      expect(utf8Decoder.encoding).toBe('UTF-8');
      expect(asciiDecoder.encoding).toBe('US-ASCII');
      expect(latin1Decoder.encoding).toBe('ISO-8859-1');
    });

    it('should fallback to utf-8 for unsupported encoding when not fatal', () => {
      const decoder = new TextDecoder('unsupported-encoding');
      const bytes = new Uint8Array([0x68, 0x65, 0x6c, 0x6c, 0x6f]);
      const result = decoder.decode(bytes);
      expect(result).toBe('hello'); // Should fallback to UTF-8
    });

    it('should throw for unsupported encoding when fatal', () => {
      expect(() => {
        new TextDecoder('unsupported-encoding', { fatal: true });
      }).toThrowError(RangeError);
    });
  });

  describe('error handling', () => {
    it('should handle invalid UTF-8 sequences gracefully when not fatal', () => {
      const decoder = new TextDecoder('utf-8', { fatal: false });
      const bytes = new Uint8Array([0x68, 0x65, 0xff, 0x6c, 0x6f]); // Invalid byte 0xff

      // Should not throw, might replace invalid bytes with replacement character
      const result = decoder.decode(bytes);
      expect(typeof result).toBe('string');
    });

    it('should throw for invalid UTF-8 sequences when fatal', () => {
      const decoder = new TextDecoder('utf-8', { fatal: true });
      const bytes = new Uint8Array([0x68, 0x65, 0xff, 0x6c, 0x6f]); // Invalid byte 0xff

      expect(() => decoder.decode(bytes)).toThrowError();
    });

    it('should handle incomplete multibyte sequences when not fatal', () => {
      const decoder = new TextDecoder('utf-8', { fatal: false });
      const bytes = new Uint8Array([0x68, 0x65, 0xc3]); // Incomplete UTF-8 sequence

      const result = decoder.decode(bytes);
      expect(typeof result).toBe('string');
    });

    it('should throw for incomplete multibyte sequences when fatal', () => {
      const decoder = new TextDecoder('utf-8', { fatal: true });
      const bytes = new Uint8Array([0x68, 0x65, 0xc3]); // Incomplete UTF-8 sequence

      expect(() => decoder.decode(bytes)).toThrowError();
    });
  });

  describe('stream option', () => {
    it('should accept stream option in decode method', () => {
      const decoder = new TextDecoder();
      const bytes = new Uint8Array([0x68, 0x65, 0x6c, 0x6c, 0x6f]);

      // Should not throw when stream option is provided
      const result = decoder.decode(bytes, { stream: false });
      expect(result).toBe('hello');

      const resultStream = decoder.decode(bytes, { stream: true });
      expect(resultStream).toBe('hello');
    });
  });

  it('should be reusable', () => {
    const decoder = new TextDecoder();

    const bytes1 = new Uint8Array([0x68, 0x65, 0x6c, 0x6c, 0x6f]);
    const bytes2 = new Uint8Array([0x77, 0x6f, 0x72, 0x6c, 0x64]);

    const result1 = decoder.decode(bytes1);
    const result2 = decoder.decode(bytes2);

    expect(result1).toBe('hello');
    expect(result2).toBe('world');
  });

  it('should handle very long byte sequences', () => {
    const decoder = new TextDecoder();
    const longBytes = new Uint8Array(10000).fill(0x61); // 10000 'a' characters
    const result = decoder.decode(longBytes);

    expect(result.length).toBe(10000);
    expect(result).toBe('a'.repeat(10000));
  });

  describe('round-trip encoding/decoding', () => {
    it('should maintain data integrity for ASCII text', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      const original = 'Hello, World!';

      const encoded = encoder.encode(original);
      const decoded = decoder.decode(encoded);

      expect(decoded).toBe(original);
    });

    it('should maintain data integrity for Unicode text', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      const original = 'Hello, 世界! 🌍 café ñoño';

      const encoded = encoder.encode(original);
      const decoded = decoder.decode(encoded);

      expect(decoded).toBe(original);
    });

    it('should maintain data integrity for mixed content', () => {
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      const original = 'ASCII123 中文 🚀 русский العربية';

      const encoded = encoder.encode(original);
      const decoded = decoder.decode(encoded);

      expect(decoded).toBe(original);
    });
  });
});
