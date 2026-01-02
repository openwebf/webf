describe('custom binding object', () => {
  it('can be constructed and invoked from JS', async () => {
    const a: any = new (globalThis as any).TestBindingObject(10);
    expect(a instanceof (globalThis as any).TestBindingObject).toBe(true);

    a.value = 10;
    expect(a.value).toBe(10);
    expect(a.add(32)).toBe(42);

    const v = await a.asyncAdd(32);
    expect(v).toBe(42);
  });

  it('can be passed from JS to Dart as argument', async () => {
    const a: any = new (globalThis as any).TestBindingObject(10);
    const b: any = new (globalThis as any).TestBindingObject(32);

    // Dart should receive `b` as the same Dart instance, so it can read its internal state.
    expect(a.readOtherValue(b)).toBe(32);
    expect(await a.asyncReadOtherValue(b)).toBe(32);

    // Identity should be preserved when passing the same object.
    expect(a.isSameInstance(a)).toBe(true);
    expect(a.isSameInstance(b)).toBe(false);

    // Dart can mutate the passed object and JS observes the change.
    expect(a.setOtherValue(b, 100)).toBe(100);
    expect(b.value).toBe(100);
  });

  it('can register a JS callback and invoke from Dart', async () => {
    const a: any = new (globalThis as any).TestBindingObject(0);

    a.setCallback((x: number, y: number) => x + y);
    expect(await a.callCallback(40, 2)).toBe(42);

    a.setCallback((x: number) => Promise.resolve(x + 2));
    expect(await a.callCallback(40)).toBe(42);

    a.setCallback(() => {
      throw new Error('boom');
    });
    try {
      await a.callCallback();
      expect(true).toBe(false);
    } catch (e) {
      expect(String(e)).toContain('boom');
    }

    a.setCallback(() => Promise.reject(new Error('boom2')));
    try {
      await a.callCallback();
      expect(true).toBe(false);
    } catch (e) {
      expect(String(e)).toContain('boom2');
    }
  });

  it('js callback corner cases', async () => {
    const a: any = new (globalThis as any).TestBindingObject(0);

    // Not a function / invalid input.
    expect(a.setCallback(123)).toBe(false);
    expect(await a.callCallback(1)).toBe(null);

    // Clear callback (undefined -> null on the bridge).
    a.setCallback(() => 1);
    expect(await a.callCallback()).toBe(1);
    expect(a.setCallback(undefined)).toBe(true);
    expect(await a.callCallback()).toBe(null);

    // Return type conversions.
    a.setCallback(() => undefined);
    expect(await a.callCallback()).toBe(null);
    a.setCallback(() => null);
    expect(await a.callCallback()).toBe(null);
    a.setCallback(() => 'hello');
    expect(await a.callCallback()).toBe('hello');
    a.setCallback(() => ({ a: 1, b: 'x' }));
    expect(await a.callCallback()).toEqual({ a: 1, b: 'x' });
    a.setCallback(() => [1, 2, 3]);
    expect(await a.callCallback()).toEqual([1, 2, 3]);

    // Argument conversions (JS -> Dart -> JS).
    a.setCallback((x: any) => x);
    expect(await a.callCallback(undefined)).toBe(null);
    expect(await a.callCallback(null)).toBe(null);
    expect(await a.callCallback(true)).toBe(true);
    expect(await a.callCallback(false)).toBe(false);
    expect(await a.callCallback(42)).toBe(42);
    expect(await a.callCallback('ok')).toBe('ok');
    expect(await a.callCallback({ foo: 1 })).toEqual({ foo: 1 });
    expect(await a.callCallback([1, '2', { a: 3 }])).toEqual([1, '2', { a: 3 }]);

    // Overwrite callback should take effect immediately.
    a.setCallback(() => 1);
    expect(await a.callCallback()).toBe(1);
    a.setCallback(() => 2);
    expect(await a.callCallback()).toBe(2);

    // Multiple concurrent invocations should not interfere.
    a.setCallback((x: number) => Promise.resolve(x + 1));
    const results = await Promise.all([a.callCallback(1), a.callCallback(2), a.callCallback(3)]);
    expect(results).toEqual([2, 3, 4]);
  });
});
