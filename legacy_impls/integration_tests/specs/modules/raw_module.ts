describe('Modules.invokeModule', () => {
  it('invokeModule can have no params', () => {
    let result = webf.invokeModule('Demo', 'noParams');
    expect(result).toBe(true);
  });
  it('invokeModule can accept int', () => {
    let result = webf.invokeModule('Demo', 'callInt', 10);
    expect(result).toBe(20);
  });
  it('invokeModule can accept double', () => {
    let result = webf.invokeModule('Demo', 'callDouble', 14.5);
    expect(result).toBe(29.0);
  });
  it('invokeModule can accept string', () => {
    let result = webf.invokeModule('Demo', 'callString', 'helloworld');
    expect(result).toBe('HELLOWORLD');
  });
  it('invokeModule can accept array', () => {
    let result = webf.invokeModule('Demo', 'callArray', [1, 2, 3, 4, 5]);
    expect(result).toBe(15);
  });
  it('invokeModule can accept null or undefined', () => {
    expect(webf.invokeModule('Demo', 'callNull', null)).toBe(null);
    expect(webf.invokeModule('Demo', 'callNull', undefined)).toBe(null);
  });
  it('invokeModule can accept callback and receive value from callback', () => {
    return new Promise((resolve, reject) => {
      let callParams = 10;
      let syncResult = webf.invokeModule('Demo', 'callAsyncFn', callParams, (err, data) => {
        if (err) {
          return reject(err);
        }
        expect(data).toEqual([1, '2', null, 4.0, { value: 1}]);
        setTimeout(() => resolve());
        return 'success';
      });
      expect(syncResult).toBe(callParams);
    });
  });
  it('invokeModule can accept callback and handle the error', () => {
    return new Promise((resolve) => {
      let syncResult = webf.invokeModule('Demo', 'callAsyncFnFail', null, (err, data) => {
        expect(err).toBeInstanceOf(Error);
        expect(err.message).toBe('Must to fail');
        setTimeout(() => resolve());
        return 'fail';
      });
      expect(syncResult).toBe(null);
    });
  });
});

describe('Module.addModuleListener', () => {
  it('event params should works', (done) => {
    webf.addWebfModuleListener('Demo', (event: CustomEvent, extra) => {
      expect(event instanceof CustomEvent).toBe(true);
      expect(event.type).toBe('click');
      expect(event.detail).toBe('helloworld');
      expect(extra).toEqual([1,2,3,4,5]);
      setTimeout(() => done());
      return 'success';
    });
    webf.invokeModule('Demo', 'callToDispatchEvent');
  });
});