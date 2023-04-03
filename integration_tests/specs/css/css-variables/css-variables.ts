describe('CSS Variables', () => {
  // https://github.com/web-platform-tests/wpt/blob/master/css/css-variables/css-variable-change-style-001.html
  it('change-style-001', async (done) => {
    document.body.appendChild(
      createStyle(`
      .outer {
        --x: red;
        --y: green;
        --z: 28px;
      }
    `)
    );
    document.head.appendChild(
      createStyle(`
      .inner {
        font-size: var(--z);
      }
    `)
    );

    document.body.appendChild(
      <div class='outer'>
        <div class='inbetween'>
          <div class='inner'>FontSize should be 28px.</div>
        </div>
      </div>
    );

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('change-style-002', async (done) => {
    document.head.appendChild(
      createStyle(`
      .inner {

        --x: red;
        --y: green;
        --z: 28px;
        font-size: var(--z);
      }
    `)
    );

    document.body.appendChild(
      <div class='outer'>
        <div class='inbetween'>
          <div class='inner'>FontSize should be 28px.</div>
        </div>
      </div>
    );

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('change-style-003', async (done) => {
    document.head.appendChild(
      createStyle(`
      :root {
        --red: #red;
      }
      .container {
          color: var(--red);
      }
    `)
    );
    
    document.body.appendChild(
      <div class='container'>
          <h2>The text should be green.</h2>
      </div>
    );

    requestAnimationFrame(async () => {
      var r = document.querySelector(':root');
      r.style.setProperty('--red', 'green');
      await snapshot();
      done();
    });
  });

  it('variable resolve percentage color', async (done) => {
    document.head.appendChild(
      createStyle(`
      .inner {
        --a: 100%;
        background-color: rgb(var(--a), 0%, 0%);
      }
    `)
    );

    document.body.appendChild(
      <div class='outer'>
        <div class='inbetween'>
          <div class='inner'>Background should be red.</div>
        </div>
      </div>
    );

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('variable resolve color', async (done) => {
    document.head.appendChild(
      createStyle(`
      .inner {
        --x: red;
        --y: green;
        --z: 28px;
        background-color: var(--x);
      }
    `)
    );

    document.body.appendChild(
      <div class='outer'>
        <div class='inbetween'>
          <div class='inner'>Background should be red.</div>
        </div>
      </div>
    );

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });


  it('nested variables', async (done) => {
    document.head.appendChild(
      createStyle(`
     .inner {
        color: var(--x);
      }
      .outer {
        --y: red;
        --x: var(--y);
      }
    `)
    );

    document.body.appendChild(
      <div class='outer'>
        <div class='inbetween'>
          <div class='inner'>Color should be red.</div>
        </div>
      </div>
    );

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  describe('Shorthand CSS properties', () => {
    it('background', async (done) => {
      document.head.appendChild(
        createStyle(`
        .inner {
          --x: red;
          --y: green;
          --z: 28px;
          background: var(--y);
        }
      `)
      );

      document.body.appendChild(
        <div class='outer'>
          <div class='inbetween'>
            <div class='inner'>Background should be green.</div>
          </div>
        </div>
      );

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });

    it('margin', async (done) => {
      document.head.appendChild(
        createStyle(`
        .inner {
          --x: red;
          --y: green;
          --z: 28px;
          margin: var(--z);
          background: red;
        }
      `)
      );

      document.body.appendChild(
        <div class='outer'>
          <div class='inbetween'>
            <div class='inner'>Background should be red with 28px margin.</div>
          </div>
        </div>
      );

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });

    it('padding', async (done) => {
      document.head.appendChild(
        createStyle(`
        .inner {
          --x: red;
          --y: green;
          --z: 28px;
          padding: var(--z);
          background: red;
        }
      `)
      );

      document.body.appendChild(
        <div class='outer'>
          <div class='inbetween'>
            <div class='inner'>Background should be red with 28px padding.</div>
          </div>
        </div>
      );

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });

    it('border', async (done) => {
      document.head.appendChild(
        createStyle(`
        .inner {
          --x: 4px;
          --y: solid;
          --z: green;
          border: var(--x) var(--y) var(--z);
          background: red;
        }
      `)
      );

      document.body.appendChild(
        <div class='outer'>
          <div class='inbetween'>
            <div class='inner'>
              Background should be red with 4px green solid border.
            </div>
          </div>
        </div>
      );

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  function createStyle(text) {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(text));
    return style;
  }
});
