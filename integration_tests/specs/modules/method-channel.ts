describe('MethodChannel', () => {
  it('addMethodCallHandler multi params', async () => {
    webf.methodChannel.addMethodCallHandler('helloworld', (args: any) => {
      expect(args).toEqual(['abc', 1234, null, /* undefined will be converted to */ null, [], true, false, {name: 1}]);
      return 'from helloworld' + args[0];
    });
    let result = await webf.methodChannel.invokeMethod('helloworld', 'abc', 1234, null, undefined, [], true, false, {name: 1});
    expect(result).toBe('method: helloworld, return_type: String, return_value: from helloworldabc');
  });

  it('invokeMethod', async () => {
    let result = await webf.methodChannel.invokeMethod('helloworld', 'abc');
    // TEST App will return method string
    expect(result).toBe('method: helloworld, return_type: Null, return_value: null');
  });

  it('invokeMethod return int64', async () => {
     let result = await webf.methodChannel.invokeMethod('helloInt64');
     expect(result).toBe(Math.round(1111111111111111));
  });

  it('addMethodCallHandler', async () => {
    webf.methodChannel.addMethodCallHandler('helloworld', (args: any[]) => {
      expect(args).toEqual(['abc']);
      return 0;
    });
    let result = await webf.methodChannel.invokeMethod('helloworld', 'abc');
    expect(result).toBe('method: helloworld, return_type: int, return_value: 0');
  });

  it('addMethodCallHandler can return value', async () => {
    webf.methodChannel.addMethodCallHandler('helloworld', (args: any[]) => {
      expect(args).toEqual(['abc']);
      return true;
    });
    let result = await webf.methodChannel.invokeMethod('helloworld', 'abc');
    expect(result).toBe('method: helloworld, return_type: bool, return_value: true');
  });


  it('removeMethodCallHandler', async (done: DoneFn) => {
    var handler = (args: any[]) => {
      done.fail('should not execute here.');
    };
    webf.methodChannel.addMethodCallHandler('helloworld', handler);
    webf.methodChannel.removeMethodCallHandler('helloworld');
    let result = await webf.methodChannel.invokeMethod('helloworld', 'abc');
    expect(result).toBe('method: helloworld, return_type: Null, return_value: null');
    done();
  });

  it('can pass JS callback to Dart via MethodChannel and invoke from a module', async () => {
    const ok = await webf.methodChannel.invokeMethod('setMethodChannelCallback', (x: number) => x + 1);
    expect(ok).toBe(true);

    const v = await webf.invokeModuleAsync<number>('MethodChannelCallback', 'callStored', 41);
    expect(v).toBe(42);

    expect(await webf.methodChannel.invokeMethod('clearMethodChannelCallback')).toBe(true);
    expect(await webf.invokeModuleAsync('MethodChannelCallback', 'callStored', 1)).toBe(null);
  });

  it('MethodChannel callback: async return, error, and function return', async () => {
    // async return (Promise)
    expect(
      await webf.methodChannel.invokeMethod('setMethodChannelCallback', (x: number) => Promise.resolve(x + 2))
    ).toBe(true);
    expect(await webf.invokeModuleAsync<number>('MethodChannelCallback', 'callStored', 40)).toBe(42);

    // throw -> module invocation rejects
    expect(await webf.methodChannel.invokeMethod('setMethodChannelCallback', () => { throw new Error('boom'); })).toBe(true);
    try {
      await webf.invokeModuleAsync('MethodChannelCallback', 'callStored');
      expect(true).toBe(false);
    } catch (e) {
      expect(String(e)).toContain('boom');
    }

    // return a function handle and call it again from Dart module
    expect(
      await webf.methodChannel.invokeMethod(
        'setMethodChannelCallback',
        (x: number) => (y: number) => x + y
      )
    ).toBe(true);
    expect(await webf.invokeModuleAsync<number>('MethodChannelCallback', 'callStoredAndCallReturned', 40, 2)).toBe(42);
  });

  it('MethodChannel callback: binding object argument + multi-call list return', async () => {
    const b: any = new (globalThis as any).TestBindingObject(10);

    expect(
      await webf.methodChannel.invokeMethod('setMethodChannelCallback', (obj: any) => obj.add(32))
    ).toBe(true);
    expect(await webf.invokeModuleAsync<number>('MethodChannelCallback', 'callStored', b)).toBe(42);

    expect(
      await webf.methodChannel.invokeMethod('setMethodChannelCallback', (x: number) => x + 1)
    ).toBe(true);
    expect(await webf.invokeModuleAsync('MethodChannelCallback', 'callStoredTwice', 41)).toEqual([42, 42]);
  });
});
