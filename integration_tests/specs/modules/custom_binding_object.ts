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
});

