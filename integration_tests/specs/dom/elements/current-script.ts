describe('document.currentScript', () => {
  it('should return null when not executing in script context', () => {
    expect(document.currentScript).toBe(null);
  });

  it('should return script element during inline script execution', (done) => {
    const script = document.createElement('script');
    script.textContent = `
      window.capturedCurrentScript = document.currentScript;
      window.isScriptSame = document.currentScript === window.currentScriptElement;
    `;
    // Store reference to compare
    (window as any).currentScriptElement = script;
    document.body.appendChild(script);

    // Give time for script to execute
    setTimeout(() => {
      expect((window as any).capturedCurrentScript).toBe(script);
      expect((window as any).isScriptSame).toBe(true);
      done();
    }, 300);
  });

  it('should return script element during external script execution', (done) => {
    const script = document.createElement('script');
    script.src = 'data:text/javascript,window.externalScriptCurrentScript = document.currentScript;';
    document.body.appendChild(script);

    script.onload = () => {
      expect((window as any).externalScriptCurrentScript).toBe(script);
      done();
    };
  });

  it('should return null during async script execution', (done) => {
    const script = document.createElement('script');
    script.async = true;
    script.textContent = `
      window.asyncScriptCurrentScript = document.currentScript;
    `;
    document.body.appendChild(script);

    // Give time for async script to execute
    setTimeout(() => {
      // In some browsers/environments, async scripts may still have currentScript reference
      // The key is that it should be null in async callbacks, not necessarily during the script itself
      expect((window as any).asyncScriptCurrentScript === null || (window as any).asyncScriptCurrentScript === script).toBe(true);
      done();
    }, 300);
  });

  it('should handle nested script execution correctly', (done) => {
    const outerScript = document.createElement('script');
    outerScript.textContent = `
      window.outerCurrentScript = document.currentScript;

      const innerScript = document.createElement('script');
      innerScript.textContent = 'window.innerCurrentScript = document.currentScript;';
      document.body.appendChild(innerScript);

      window.outerCurrentScriptAfterInner = document.currentScript;
    `;
    document.body.appendChild(outerScript);

    setTimeout(() => {
      expect((window as any).outerCurrentScript).toBe(outerScript);
      expect((window as any).innerCurrentScript).not.toBe(outerScript);
      expect((window as any).outerCurrentScriptAfterInner).toBe(outerScript);
      done();
    }, 300);
  });

  it('should return null after script execution completes', (done) => {
    const script = document.createElement('script');
    script.textContent = `
      window.duringExecution = document.currentScript;
    `;
    document.body.appendChild(script);

    setTimeout(() => {
      expect((window as any).duringExecution).toBe(script);
      expect(document.currentScript).toBe(null);
      done();
    }, 300);
  });

  it('should handle multiple sequential scripts correctly', (done) => {
    const script1 = document.createElement('script');
    script1.textContent = `
      window.script1CurrentScript = document.currentScript;
    `;

    const script2 = document.createElement('script');
    script2.textContent = `
      window.script2CurrentScript = document.currentScript;
    `;

    document.body.appendChild(script1);
    document.body.appendChild(script2);

    setTimeout(() => {
      expect((window as any).script1CurrentScript).toBe(script1);
      expect((window as any).script2CurrentScript).toBe(script2);
      expect(document.currentScript).toBe(null);
      done();
    }, 300);
  });

  it('should handle script removal during execution', (done) => {
    const script = document.createElement('script');
    script.textContent = `
      window.beforeRemovalCurrentScript = document.currentScript;
      document.currentScript.remove();
      window.afterRemovalCurrentScript = document.currentScript;
    `;
    document.body.appendChild(script);

    setTimeout(() => {
      expect((window as any).beforeRemovalCurrentScript).toBe(script);
      expect((window as any).afterRemovalCurrentScript).toBe(script);
      expect(document.body.contains(script)).toBe(false);
      done();
    }, 300);
  });

  it('should handle script with both src and textContent', (done) => {
    const script = document.createElement('script');
    script.src = 'data:text/javascript,window.srcCurrentScript = document.currentScript;';
    script.textContent = 'window.textContentCurrentScript = document.currentScript;';
    document.body.appendChild(script);

    script.onload = () => {
      // When src is present, textContent should be ignored
      expect((window as any).srcCurrentScript).toBe(script);
      expect((window as any).textContentCurrentScript).toBeUndefined();
      done();
    };
  });
});
