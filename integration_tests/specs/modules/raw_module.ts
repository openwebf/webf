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