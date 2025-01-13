describe('MediaQuery prefers-color-scheme', () => {
  it('should works with @media (prefers-color-scheme) dark', async () => {
    const cssText = `
    div.example {
      background-color: red;
    }

    @media (prefers-color-scheme:dark) {
       div.example {
        background-color: green;
       }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is green when dark mode enabled')
    ]);

    BODY.appendChild(container);

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });

  it('should works with @media (prefers-color-scheme) light', async () => {
    const cssText = `
    div.example {
      background-color: red;
    }

    @media (prefers-color-scheme:light) {
       div.example {
        background-color: green;
       }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is green when dark mode enabled')
    ]);

    BODY.appendChild(container);

    simulateChangeDarkMode(true);

    await snapshot();

    simulateChangeDarkMode(false);

    await snapshot();
  });

  it('should works with @media (prefers-color-scheme) dark and light', async () => {
    const cssText = `
    div.example {
      background-color: red;
    }

    @media (prefers-color-scheme:dark) {
       div.example {
        background-color: green;
       }
    }

    @media (prefers-color-scheme:light) {
       div.example {
        background-color: yellow;
       }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is green when dark mode enabled')
    ]);

    BODY.appendChild(container);

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });

  it('should works with css variables and hsl color', async () => {
    const cssText = `
    div.example {
      background-color: hsl(var(--twc-gray-10));
    }

    @media (prefers-color-scheme:dark) {
      :root {
        --twc-gray-10: 12 100% 50%;
      }
    }

    @media (prefers-color-scheme:light) {
      :root {
        --twc-gray-10: 240 100% 50%;
      }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is green when dark mode enabled')
    ]);

    BODY.appendChild(container);
    BODY.appendChild(createText('-----'));

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });

  it('should works with css variables and rgba color', async () => {
    const cssText = `
    div.example {
      background-color: rgba(var(--twc-gray-10));
    }

    @media (prefers-color-scheme:dark) {
      :root {
        --twc-gray-10: 0, 0, 0, 0.5;
      }
    }

    @media (prefers-color-scheme:light) {
      :root {
        --twc-gray-10: 255, 0, 255, 1;
      }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is green when dark mode enabled')
    ]);

    BODY.appendChild(container);
    BODY.appendChild(createText('-----'));

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });

  it('should works with css variables in rgba color', async () => {
    const cssText = `
    div.example {
      background-color: rgb(32 38 48 / var(--tw-bg-opacity));
    }

    @media (prefers-color-scheme:dark) {
      :root {
        --tw-bg-opacity: 1;
      }
    }

    @media (prefers-color-scheme:light) {
      :root {
      }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is black when dark mode enabled')
    ]);

    BODY.appendChild(container);
    BODY.appendChild(createText('-----'));

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });

  it('should works with css variable value is hsl color', async () => {
    const cssText = `
    div.example {
      background-color: var(--twc-gray-50);
    }

    @media (prefers-color-scheme:dark) {
      :root {
        --twc-gray-50: hsl(12, 100%, 50%);
      }
    }

    @media (prefers-color-scheme:light) {
      :root {
        --twc-gray-50: hsl(240, 100%, 50%);
      }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is black when dark mode enabled')
    ]);

    BODY.appendChild(container);
    BODY.appendChild(createText('-----'));

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });

  it('should works with hsl color values comes from three different css variables', async () => {
    const cssText = `
    div.example {
      background-color: hsl(var(--twc-gray-250) / var(--twc-gray-250-opacity, var(--tw-text-opacity)));
    }

    @media (prefers-color-scheme:dark) {
      :root {
        --twc-gray-250: 214.70000000000005 9.5% 61%;
        --twc-gray-250-opacity: 0.5;
        --tw-text-opacity: 1;
      }
    }

    @media (prefers-color-scheme:light) {
      :root {
        --twc-gray-250: 216.5 14.6% 30.8%;
        --twc-gray-250-opacity: 0.5;
        --tw-text-opacity: 1;
      }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when bg color is black when dark mode enabled')
    ]);

    BODY.appendChild(container);
    BODY.appendChild(createText('-----'));

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });

  it('should works with set color for nest dom structures', async () => {
    const cssText = `
    div.example {
      color: rgba(var(--twc-gray-10));
    }

    @media (prefers-color-scheme:dark) {
      :root {
        --twc-gray-10: 0, 0, 0, 0.5;
      }
    }

    @media (prefers-color-scheme:light) {
      :root {
        --twc-gray-10: 255, 0, 255, 1;
      }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when color is gray when dark mode enabled')
    ]);

    const others = createElement('div', {}, [
      createText('the text should be black')
    ]);

    BODY.appendChild(container);
    BODY.appendChild(createText('-----'));
    BODY.appendChild(others);

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });


  it('should works with css color with camelCase varaibles', async () => {
    const cssText = `
    div.example {
      background-color:hsl(var(--twc-cardBg) / var(--twc-cardBg-opacity, var(--tw-bg-opacity)));
    }

    @media (prefers-color-scheme:dark) {
      :root {
        --twc-cardBg: 214.70000000000005 9.5% 61%;
        --twc-cardBg-opacity: 0.5;
        --tw-bg-opacity: 1;
      }
    }

    @media (prefers-color-scheme:light) {
      :root {
        --twc-cardBg: 216.5 14.6% 30.8%;
        --twc-cardBg-opacity: 0.5;
        --tw-bg-opacity: 1;
      }
    }
    `;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.append(style);

    const container = createElement('div', {
      className: 'example',
      style: {
        width: '300px',
        height: '200px'
      }
    }, [
      createText('should pass when color is gray when dark mode enabled')
    ]);

    const others = createElement('div', {}, [
      createText('the text should be black')
    ]);

    BODY.appendChild(container);
    BODY.appendChild(createText('-----'));
    BODY.appendChild(others);

    simulateChangeDarkMode(false);

    await snapshot();

    simulateChangeDarkMode(true);

    await snapshot();
  });
});
