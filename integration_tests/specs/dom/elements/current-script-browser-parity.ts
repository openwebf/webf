describe('document.currentScript (browser parity)', () => {
  it('is null in event listeners (addEventListener)', (done) => {
    const btn = document.createElement('button');
    btn.addEventListener('click', () => {
      (window as any).clickCurrentScript = document.currentScript;
    });
    document.body.appendChild(btn);

    btn.dispatchEvent(new MouseEvent('click', { bubbles: true }));

    setTimeout(() => {
      expect((window as any).clickCurrentScript).toBe(null);
      done();
    }, 50);
  });

  it('is null in event listeners (onclick property)', (done) => {
    const btn = document.createElement('button');
    (btn as any).onclick = () => {
      (window as any).onclickPropCurrentScript = document.currentScript;
    };
    document.body.appendChild(btn);

    btn.dispatchEvent(new MouseEvent('click', { bubbles: true }));

    setTimeout(() => {
      expect((window as any).onclickPropCurrentScript).toBe(null);
      done();
    }, 50);
  });

  it('is null in microtasks scheduled from a script', (done) => {
    const script = document.createElement('script');
    script.textContent = `
      Promise.resolve().then(() => {
        window.microtaskCurrentScript = document.currentScript;
      });
    `;
    document.body.appendChild(script);

    setTimeout(() => {
      expect((window as any).microtaskCurrentScript).toBe(null);
      done();
    }, 100);
  });

  it('is null in macrotasks scheduled from a script (setTimeout)', (done) => {
    const script = document.createElement('script');
    script.textContent = `
      setTimeout(() => {
        window.timeoutCurrentScript = document.currentScript;
      }, 0);
    `;
    document.body.appendChild(script);

    setTimeout(() => {
      expect((window as any).timeoutCurrentScript).toBe(null);
      done();
    }, 100);
  });

  it('is the script inside eval() executed by that script', (done) => {
    const script = document.createElement('script');
    script.textContent = `
      eval('window.evalCurrentScript = document.currentScript');
    `;
    document.body.appendChild(script);

    setTimeout(() => {
      expect((window as any).evalCurrentScript).toBe(script);
      done();
    }, 50);
  });

  it('is null inside script onload handler (external classic)', (done) => {
    const script = document.createElement('script');
    script.src = 'data:text/javascript,void%200;';
    script.onload = () => {
      expect(document.currentScript).toBe(null);
      done();
    };
    document.body.appendChild(script);
  });

  it('is null in module scripts (inline)', (done) => {
    const script = document.createElement('script');
    script.type = 'module';
    script.textContent = `
      window.moduleInlineCurrentScript = document.currentScript;
    `;
    script.onload = () => {
      expect((window as any).moduleInlineCurrentScript).toBe(null);
      done();
    };
    script.onerror = () => done.fail('Module inline script failed');
    document.body.appendChild(script);
  });

  it('is null in module scripts (external)', (done) => {
    const script = document.createElement('script');
    script.type = 'module';
    script.src = 'data:text/javascript,window.moduleExternalCurrentScript%20=%20document.currentScript;';
    script.onload = () => {
      expect((window as any).moduleExternalCurrentScript).toBe(null);
      done();
    };
    script.onerror = () => done.fail('Module external script failed');
    document.body.appendChild(script);
  });
});

