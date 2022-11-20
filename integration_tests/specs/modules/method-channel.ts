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
});
