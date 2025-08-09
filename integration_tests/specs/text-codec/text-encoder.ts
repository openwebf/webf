describe('TextEncoder', () => {
  it('should exist and be a constructor', () => {
    expect(typeof TextEncoder).toBe('function');
    expect(TextEncoder.prototype.encode).toBeDefined();
    expect(TextEncoder.prototype.encodeInto).toBeDefined();
  });

  it('should have encoding property set to utf-8', () => {
    const encoder = new TextEncoder();
    expect(encoder.encoding).toBe('utf-8');
  });

  it('should encode empty string', () => {
    const encoder = new TextEncoder();
    const result = encoder.encode('');
    expect(result).toBeInstanceOf(Uint8Array);
    expect(result.length).toBe(0);
  });

  it('should encode ASCII string', () => {
    const encoder = new TextEncoder();
    const result = encoder.encode('hello');
    expect(result).toBeInstanceOf(Uint8Array);
    expect(Array.from(result)).toEqual([0x68, 0x65, 0x6c, 0x6c, 0x6f]);
  });

  it('should encode UTF-8 string with special characters', () => {
    const encoder = new TextEncoder();
    const result = encoder.encode('café');
    expect(result).toBeInstanceOf(Uint8Array);
    // 'c' = 0x63, 'a' = 0x61, 'f' = 0x66, 'é' = 0xc3 0xa9
    expect(Array.from(result)).toEqual([0x63, 0x61, 0x66, 0xc3, 0xa9]);
  });

  it('should encode emoji characters', () => {
    const encoder = new TextEncoder();
    const result = encoder.encode('🙂');
    expect(result).toBeInstanceOf(Uint8Array);
    // 🙂 emoji in UTF-8: F0 9F 99 82
    expect(Array.from(result)).toEqual([0xf0, 0x9f, 0x99, 0x82]);
  });

  it('should encode Chinese characters', () => {
    const encoder = new TextEncoder();
    const result = encoder.encode('你好');
    expect(result).toBeInstanceOf(Uint8Array);
    // 你 = E4 BD A0, 好 = E5 A5 BD
    expect(Array.from(result)).toEqual([0xe4, 0xbd, 0xa0, 0xe5, 0xa5, 0xbd]);
  });

  it('should handle null and undefined inputs', () => {
    const encoder = new TextEncoder();

    // null should be converted to string "null"
    const nullResult = encoder.encode(null as any);
    expect(Array.from(nullResult)).toEqual([0x6e, 0x75, 0x6c, 0x6c]);

    // undefined should be converted to string "undefined"
    const undefinedResult = encoder.encode(undefined as any);
    expect(Array.from(undefinedResult)).toEqual([0x75, 0x6e, 0x64, 0x65, 0x66, 0x69, 0x6e, 0x65, 0x64]);
  });

  it('should handle numeric inputs by converting to string', () => {
    const encoder = new TextEncoder();
    const result = encoder.encode(123 as any);
    expect(Array.from(result)).toEqual([0x31, 0x32, 0x33]); // "123"
  });

  it('should handle boolean inputs by converting to string', () => {
    const encoder = new TextEncoder();
    const trueResult = encoder.encode(true as any);
    expect(Array.from(trueResult)).toEqual([0x74, 0x72, 0x75, 0x65]); // "true"

    const falseResult = encoder.encode(false as any);
    expect(Array.from(falseResult)).toEqual([0x66, 0x61, 0x6c, 0x73, 0x65]); // "false"
  });

  describe('encodeInto method', () => {
    it('should encode into provided buffer', () => {
      const encoder = new TextEncoder();
      const destination = new Uint8Array(10);
      const result = encoder.encodeInto('hello', destination);

      expect(result.read).toBe(5);
      expect(result.written).toBe(5);
      expect(Array.from(destination.slice(0, 5))).toEqual([0x68, 0x65, 0x6c, 0x6c, 0x6f]);
    });

    it('should handle buffer too small for entire string', () => {
      const encoder = new TextEncoder();
      const destination = new Uint8Array(3);
      const result = encoder.encodeInto('hello', destination);

      expect(result.read).toBe(3);
      expect(result.written).toBe(3);
      expect(Array.from(destination)).toEqual([0x68, 0x65, 0x6c]);
    });

    it('should handle multibyte characters correctly', () => {
      const encoder = new TextEncoder();
      const destination = new Uint8Array(10);
      const result = encoder.encodeInto('café', destination);

      expect(result.read).toBe(4);
      expect(result.written).toBe(5);
      expect(Array.from(destination.slice(0, 5))).toEqual([0x63, 0x61, 0x66, 0xc3, 0xa9]);
    });

    it('should handle partial multibyte character at buffer end', () => {
      const encoder = new TextEncoder();
      const destination = new Uint8Array(4);
      const result = encoder.encodeInto('café', destination);

      // Should stop before the 'é' because it requires 2 bytes but only 1 is available
      expect(result.read).toBe(3);
      expect(result.written).toBe(3);
      expect(Array.from(destination.slice(0, 3))).toEqual([0x63, 0x61, 0x66]);
    });

    it('should handle emoji characters at buffer boundary', () => {
      const encoder = new TextEncoder();
      const destination = new Uint8Array(6);
      const result = encoder.encodeInto('hi🙂', destination);

      // 'h' + 'i' = 2 bytes, emoji = 4 bytes, total 6 bytes
      expect(result.read).toBe(4); // 2 UTF-16 code units for hi + 2 for surrogate pair
      expect(result.written).toBe(6);
      expect(Array.from(destination)).toEqual([0x68, 0x69, 0xf0, 0x9f, 0x99, 0x82]);
    });

    it('should handle empty string', () => {
      const encoder = new TextEncoder();
      const destination = new Uint8Array(10);
      const result = encoder.encodeInto('', destination);

      expect(result.read).toBe(0);
      expect(result.written).toBe(0);
    });

    it('should throw TypeError for invalid destination', () => {
      const encoder = new TextEncoder();
      expect(() => encoder.encodeInto('test', null as any)).toThrowError(TypeError);
      expect(() => encoder.encodeInto('test', undefined as any)).toThrowError(TypeError);
      expect(() => encoder.encodeInto('test', [] as any)).toThrowError(TypeError);
    });

    it('should handle zero-length buffer', () => {
      const encoder = new TextEncoder();
      const destination = new Uint8Array(0);
      const result = encoder.encodeInto('hello', destination);

      expect(result.read).toBe(0);
      expect(result.written).toBe(0);
    });
  });

  it('should be reusable', () => {
    const encoder = new TextEncoder();

    const result1 = encoder.encode('hello');
    const result2 = encoder.encode('world');

    expect(Array.from(result1)).toEqual([0x68, 0x65, 0x6c, 0x6c, 0x6f]);
    expect(Array.from(result2)).toEqual([0x77, 0x6f, 0x72, 0x6c, 0x64]);
  });

  it('should handle very long strings', () => {
    const encoder = new TextEncoder();
    const longString = 'a'.repeat(10000);
    const result = encoder.encode(longString);

    expect(result.length).toBe(10000);
    expect(result[0]).toBe(0x61); // 'a'
    expect(result[9999]).toBe(0x61); // 'a'
  });
});
