describe('script element async', () => {
  fit('should work with src', async (done) => {
    const p = <p>Should see hello below:</p>;
    document.body.appendChild(p);
    var x = document.createElement('script');
    // @ts-ignore
    x.src_async = 'assets:///assets/hello.js';
    document.head.appendChild(x);
    x.onload = async () => {
      await snapshot();
      done();
    };
  });

  fit('load failed with error event', (done) => {
    const script = document.createElement('script');
    document.body.appendChild(script);
    script.onerror = () => {
      done();
    };
    // @ts-ignore
    script.src_async = '/404';
  });

  fit('async script execute in delayed order', async (done) => {
    const scriptA = document.createElement('script');
    // @ts-ignore
    scriptA.async_async = true;
    // @ts-ignore
    scriptA.src_async = 'assets:///assets/defineA.js';

    const scriptB = document.createElement('script');
    // @ts-ignore
    scriptB.src_async = 'assets:///assets/defineB.js';

    document.body.appendChild(scriptA);
    document.body.appendChild(scriptB);

    scriptA.onload = () => {
      // expect bundle B has already loaded.
      expect(window.A).toEqual('A');
      expect(window.B).toEqual('B');

      // Bundle B load earlier than A.
      expect(window.bundleALoadTime - window.bundleBLoadTime >= 0).toEqual(true);
      done();
    };
  });

  fit('could loading the kbc files', done => {
    const script = document.createElement('script');
    // @ts-ignore
    script.src_async = 'assets:///assets/bundle.kbc1';
    // @ts-ignore
    script.type_async = 'application/vnd.webf.bc1';
    document.body.appendChild(script);

    script.onload = async () => {
      await snapshot();
      done();
    }
  });

  // function waitForLoad(script) {
  //   return new Promise((resolve) => {
  //     script.onload = () => {
  //       resolve();
  //     };
  //   });
  // }

  fit('Waiting order for large script loaded', (done) => {
    const scriptLarge = document.createElement('script');
    // @ts-ignore
    scriptLarge.src_async = 'assets:///assets/large-script.js';

    const scriptSmall = document.createElement('script');
    // @ts-ignore
    scriptSmall.src_async = 'assets:///assets/defineA.js';

    document.body.appendChild(scriptLarge);
    document.body.appendChild(scriptSmall);

    Promise.all([
      waitForLoad(scriptLarge),
      waitForLoad(scriptSmall),
    ]).then(() => {
      // Bundle C load earlier than A.
      expect(window.bundleALoadTime - window.bundleCLoadTime >= 0).toEqual(true);
      done();
    });
  });

  fit('should run by element\'s place order', async (done) => {
    const scriptA = document.createElement('script');
    // @ts-ignore
    scriptA.src_async = 'assets:///assets/defineA.js';

    const inlineScriptA = document.createElement('script');
    inlineScriptA.textContent = 'window.C = window.A;';

    const scriptB = document.createElement('script');
    // @ts-ignore
    scriptB.src_async = 'assets:///assets/defineB.js';

    const inlineScriptB = document.createElement('script');
    inlineScriptB.textContent = 'window.D = window.B';

    document.body.appendChild(scriptA);
    document.body.appendChild(inlineScriptA);
    document.body.appendChild(scriptB);
    document.body.appendChild(inlineScriptB);

    Promise.all([
      waitForLoad(scriptA),
      waitForLoad(scriptB),
      waitForLoad(inlineScriptA),
      waitForLoad(inlineScriptB)
    ]).then(() => {
      // @ts-ignore
      expect(window.C).toBe(window.A);
      // @ts-ignore
      expect(window.D).toBe(window.B);
      done();
    });
  });
});
