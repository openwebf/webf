describe('Tempoary Tags input', () => {
  it('input text can set height', async () => {
    const input = document.createElement('input');
    input.value = 'helloworld';
    document.body.appendChild(input);
    await snapshot();
    input.style.height = '100px';
    await snapshot();
  });
});

describe('Input line-height', () => {
  it('height not set and line-height set', async () => {
    let div;
    div = createElement(
      'input',
      {
        value: '123',
        style: {
          lineHeight: '50px',
          fontSize: '30px',
        },
      }
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('height set should work when the unit not px', async () => {
    let div;
    div = createElement(
      'input',
      {
        value: '1234',
        style: {
          height: '100%',
          fontSize: '30px',
        },
      }
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('height set and line-height set', async () => {
    let div;
    div = createElement(
      'input',
      {
        value: '1234',
        style: {
          lineHeight: '50px',
          height: '100px',
          fontSize: '30px',
        },
      }
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('height set and line-height greater than height', async () => {
    let div;
    div = createElement(
      'input',
      {
        value: '12345',
        style: {
          lineHeight: '100px',
          height: '50px',
          fontSize: '30px',
        },
      }
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('line-height set and is smaller than text size', async () => {
    let input;
    input = createElement(
      'input',
      {
        value: '123456',
        style: {
          lineHeight: '10px',
          fontSize: '30px'
        },
      }
    );
    BODY.appendChild(input);
    await snapshot();
  });

  it('line-height set and is bigger than text size', async () => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567',
        style: {
          lineHeight: '100px',
          fontSize: '30px'
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();
  });

  it('line-height changes when height is not set', async (done) => {
    let input;
    input = createElement(
      'input',
      {
        value: '12345678',
        style: {
          lineHeight: '50px',
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();

    requestAnimationFrame(async () => {
      input.style.lineHeight = '100px';
      await snapshot();
      done();
    });
  });
})

describe('Tags input', () => {
  it('basic', async () => {
    const input = document.createElement('input');
    input.style.width = '60px';
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('should works with display none', async () => {
    const input = document.createElement('input');
    input.style.width = '60px';
    input.style.fontSize = '16px';
    input.style.display = 'none';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);
    await snapshot();
  });

  it('with default width', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World Hello World Hello World Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('with size attribute', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World Hello World Hello World Hello World');
    input.setAttribute('size', '10');
    document.body.appendChild(input);

    await snapshot();
  });


  it('with size attribute change when width is not set', async (done) => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    requestAnimationFrame(async () => {
      input.setAttribute('size', '30');
      await snapshot();
      done();
    });
  });

  it('with cols attribute change when width is set', async (done) => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.style.width = '100px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    requestAnimationFrame(async () => {
      input.setAttribute('size', '30');
      await snapshot();
      done();
    });
  });

  it('with size attribute set and width changed to auto', async (done) => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.style.width = '100px';
    input.setAttribute('size', '30');
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    requestAnimationFrame(async () => {
      input.style.width = 'auto';
      await snapshot();
      done();
    });
  });

  it('with defaultValue property', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.defaultValue = 'Hello World Hello World Hello World Hello World';
    document.body.appendChild(input);

    await snapshot();
  });

  it('with placeholder and value set', async () => {
    const input = document.createElement('input');
    input.style.width = '100px';
    input.setAttribute('placeholder', 'Please input');
    input.setAttribute('value', 'Hello World');

    document.body.appendChild(input);
    await snapshot();
  });

  it('with height smaller than text height', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '26px';
    input.style.height = '22px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('with height larger than text height', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '26px';
    input.style.height = '52px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('font-size set and width not set', async () => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567890',
        style: {
          fontSize: '30px'
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();
  });

  it('font-size changes when width not set', async (done) => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567890',
        style: {
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();

    requestAnimationFrame(async () => {
      input.style.fontSize = '30px';
      await snapshot();
      done();
    });
  });

  it('with value first', async () => {
    const input = document.createElement('input');
    input.setAttribute('value', 'Hello World Hello World Hello World Hello World');
    input.style.fontSize = '16px';
    document.body.appendChild(input);

    await snapshot();
  });

  it('type password', async () => {
    const div = document.createElement('div');
    const input = document.createElement('input');

    input.type = 'password';
    input.value = 'HelloWorld';
    input.placeholder = "This is placeholder.";
  
    div.appendChild(input);
    document.body.appendChild(div);

    await snapshot();
  });

  it('event blur', (done) => {
    const input1 = document.createElement('input');
    const input2 = document.createElement('input');
    input1.setAttribute('value', 'Input 1');
    input2.setAttribute('value', 'Input 2');
    document.body.appendChild(input1);
    document.body.appendChild(input2);

    input1.addEventListener('blur', function handler(event) {
      input1.removeEventListener('blur', handler);
      done();
    });

    input1.ononscreen = () => {
      input1.focus();
      requestAnimationFrame(() => {
        input2.focus();
      });
    }
  });


  it('event focus', (done) => {
    const input1 = document.createElement('input');
    const input2 = document.createElement('input');
    input1.setAttribute('value', 'Input 1');
    input2.setAttribute('value', 'Input 2');
    document.body.appendChild(input1);
    document.body.appendChild(input2);

    input2.addEventListener('focus', function handler(event) {
      input2.removeEventListener('focus', handler);
      done();
    });

    requestAnimationFrame(() => {
      input1.focus();
      requestAnimationFrame(() => {
        input2.focus();
      });
    });
  });

  xit('event input', (done) => {
    const VALUE = 'Hello';
    const input = document.createElement('input');
    input.value = '';
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      expect(event.type).toEqual('input');
      expect(event.target).toEqual(input);
      expect(event.currentTarget).toEqual(input);
      expect(event.bubbles).toEqual(false);
      done();
    });

    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('event change', (done) => {
    const VALUE = 'Input 3';
    const input1 = document.createElement('input');
    const input2 = document.createElement('input');
    input1.setAttribute('value', 'Input 1');
    input2.setAttribute('value', 'Input 2');
    document.body.appendChild(input1);
    document.body.appendChild(input2);

    input1.addEventListener('change', function handler(event) {
      expect(input1.value).toEqual(VALUE);
      done();
    });

    input1.focus();

    requestAnimationFrame(() => {
      input1.setAttribute('value', VALUE);
      input2.focus();
    });
  });

  xit('event keyup', (done) => {
    const input = document.createElement('input');
    document.body.appendChild(input);
    input.focus();
    input.addEventListener('keyup', function handler(event) {
      expect(event.code).toEqual('Digit 1');
      expect(event.key).toEqual('1');
      done();
    });
    requestAnimationFrame(() => {
      simulateInputText('1');
    });
  });

  xit('event keydown', (done) => {
    const input = document.createElement('input');
    document.body.appendChild(input);
    input.focus();
    input.addEventListener('keydown', function handler(event) {
      expect(event.code).toEqual('Digit 1');
      expect(event.key).toEqual('1');
      done();
    });
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText('1');
      });
    });
  });

  xit('support inputmode=text', (done) => {
    const VALUE = 'Hello';
    const input = <input inputmode="text" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support inputmode=tel', (done) => {
    const VALUE = '123456789#1';
    const input = <input inputmode="tel" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support inputmode=decimal', (done) => {
    const VALUE = '123456789';
    const input = <input inputmode="decimal" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support inputmode=numeric', (done) => {
    const VALUE = '123456789';
    const input = <input inputmode="numeric" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support inputmode=search', (done) => {
    const VALUE = 'Hello';
    const input = <input inputmode="search" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support inputmode=email', (done) => {
    const VALUE = 'example@example.com';
    const input = <input inputmode="email" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support inputmode=url', (done) => {
    const VALUE = 'example.com';
    const input = <input inputmode="url" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support type=number', (done) => {
    const VALUE = '123456789';
    const input = <input type="number" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support type=number with step', (done) => {
    const VALUE = '123456789.123';
    const input = <input type="number" step = "0.1" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support type=url', (done) => {
    const VALUE = 'example.com';
    const input = <input type="url" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support type=email', (done) => {
    const VALUE = 'example@example.com';
    const input = <input type="email" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support type=tel', (done) => {
    const VALUE = '123456789#1';
    const input = <input type="tel" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        simulateInputText(VALUE);
      });
    });
  });

  xit('support maxlength attribute', (done) => {
    const input = <input maxlength="3" />;
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateInputText('1');
      requestAnimationFrame(() => {
        expect(input.value).toEqual('1');

        simulateInputText('123');
        requestAnimationFrame(() => {
          expect(input.value).toEqual('123');

          simulateInputText('1234');
          requestAnimationFrame(() => {
            expect(input.value).toEqual('123');
            done();
          });
        });
      });
    });
  });

  xit('support maxLength property', (done) => {
    const input = document.createElement('input');
    input.maxLength = 3;
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateInputText('1');
      requestAnimationFrame(() => {
        expect(input.value).toEqual('1');

        simulateInputText('123');
        requestAnimationFrame(() => {
          expect(input.value).toEqual('123');

          simulateInputText('1234');
          requestAnimationFrame(() => {
            expect(input.value).toEqual('123');
            done();
          });
        });
      });
    });
  });

  xit('support work with click', (done) => {
    const input = document.createElement('input');
    input.setAttribute('value', 'Input 1');
    document.body.appendChild(input);
    input.addEventListener('click', function handler() {
      done();
    });

    simulateClick(10, 10);
  });

  it('should return empty string when set value to null', (done) => {
    const input = document.createElement('input');
    document.body.appendChild(input);

    input.addEventListener('onscreen', async () => {
      input.value = '1234';
      expect(input.value).toBe('1234');
      // @ts-ignore
      input.value = null;
      expect(input.value).toBe('');

      done();
    });
  });

  xit('input attribute and property value priority', (done) => {
    const input = createElement('input', {
      placeholder: 'hello world',
      style: {
        height: '50px',
      }
    }) as HTMLInputElement;
    document.body.appendChild(input);

    requestAnimationFrame(() => {
      input.setAttribute('value', 'attribute value');
      expect(input.defaultValue).toBe('attribute value');
      expect(input.value).toBe('attribute value');

      input.defaultValue = 'default value';
      expect(input.defaultValue).toBe('default value');
      expect(input.value).toBe('default value');

      input.value = 'property value';
      expect(input.defaultValue).toBe('default value');
      expect(input.value).toBe('property value');

      input.setAttribute('value', 'attribute value 2');
      expect(input.defaultValue).toBe('attribute value 2');
      // @ts-ignore
      expect(input.value).toBe('property value');

      done();
    });
  });

  it('should works when change display on input element', (done) => {
    const input = createElement('input', {
      style: {
        width: '50px'
      }
    }, []);
    document.body.appendChild(input);
    document.body.appendChild(createElement('span', {}, [createText('AAAAA')]))

    requestAnimationFrame(async () => {
      input.style.display = 'inline-block';
      requestAnimationFrame((() => {

      }))
      await snapshot();
      done();
    });
  });

  it('should set and get selectionStart and selectionEnd correctly', (done) => {
    const input = document.createElement('input');
    input.value = 'Hello World';
    document.body.appendChild(input);

    // Focus the input to make it active
    input.focus();

    // Directly set selectionStart and selectionEnd
    input.selectionStart = 2;
    input.selectionEnd = 5;

    // Verify selectionStart and selectionEnd
    expect(input.selectionStart).toBe(2);
    expect(input.selectionEnd).toBe(5);

    done();
  });

  xit('should prevent input when disabled', (done) => {
    const input = document.createElement('input');
    document.body.appendChild(input);

    input.value = 'initial';
    input.focus();

    requestAnimationFrame(() => {
      simulateInputText('123');

      requestAnimationFrame(() => {
        expect(input.value).toBe('123');

        input.disabled = true;

        requestAnimationFrame(() => {
          simulateInputText('456');

          requestAnimationFrame(() => {
            expect(input.value).toBe('123');

            input.disabled = false;
            requestAnimationFrame(() => {
              simulateInputText('789');

              requestAnimationFrame(() => {
                expect(input.value).toBe('789');
                done();
              });
            });
          });
        });
      });
    });
  });

  xit('should prevent input when disabled attribute is set', (done) => {
    const input = <input disabled />;
    document.body.appendChild(input);

    input.focus();

    requestAnimationFrame(() => {
      simulateInputText('123');

      requestAnimationFrame(() => {
        expect(input.value).toBe('');
        done();
      });
    });
  });
});

describe('Input Sizing Test Cases', () => {
  it('default input with no styling', async () => {
    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Default input';
    document.body.appendChild(input);
    await snapshot();
  });

  it('fixed width only', async () => {
    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Fixed width';
    input.style.width = '200px';
    input.style.padding = '8px 12px';
    input.style.border = '2px solid #51cf66';
    input.style.borderRadius = '6px';
    input.style.fontSize = '16px';
    input.style.background = '#f3fff5';
    input.style.boxShadow = '0 2px 4px rgba(81, 207, 102, 0.1)';
    document.body.appendChild(input);
    await snapshot();
  });

  it('fixed height only', async () => {
    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Fixed height';
    input.style.height = '100px';
    input.style.padding = '10px 14px';
    input.style.border = '2px solid #f59f00';
    input.style.borderRadius = '6px';
    input.style.fontSize = '16px';
    input.style.background = '#fff9f0';
    input.style.boxShadow = '0 2px 4px rgba(245, 159, 0, 0.1)';
    document.body.appendChild(input);
    await snapshot();
  });

  it('both width and height fixed', async () => {
    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Fixed both';
    input.style.width = '200px';
    input.style.height = '80px';
    input.style.padding = '10px 12px';
    input.style.border = '2px solid #9775fa';
    input.style.borderRadius = '6px';
    input.style.fontSize = '16px';
    input.style.background = '#f8f0ff';
    input.style.boxShadow = '0 2px 4px rgba(151, 117, 250, 0.1)';
    document.body.appendChild(input);
    await snapshot();
  });

  it('percentage width', async () => {
    const container = document.createElement('div');
    container.style.width = '100%';
    container.style.padding = '20px';
    container.style.background = '#fff';
    container.style.border = '3px dashed #007AFF';
    container.style.borderRadius = '8px';
    container.style.display = 'flex';
    container.style.alignItems = 'center';
    container.style.gap = '20px';

    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = '50% width';
    input.style.width = '50%';
    input.style.padding = '10px 14px';
    input.style.border = '2px solid #339af0';
    input.style.borderRadius = '6px';
    input.style.fontSize = '16px';
    input.style.background = '#f0f8ff';
    input.style.boxShadow = '0 2px 4px rgba(51, 154, 240, 0.1)';

    container.appendChild(input);
    document.body.appendChild(container);
    await snapshot();
  });

  it('padding effects', async () => {
    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Big padding';
    input.style.padding = '20px';
    input.style.border = '2px solid #ff6b6b';
    input.style.borderRadius = '6px';
    input.style.fontSize = '16px';
    input.style.background = '#fff5f5';
    input.style.boxShadow = '0 2px 4px rgba(255, 107, 107, 0.1)';
    document.body.appendChild(input);
    await snapshot();
  });

  it('font size variations', async () => {
    const container = document.createElement('div');
    container.style.width = '100%';
    container.style.padding = '20px';
    container.style.background = '#fff';
    container.style.border = '3px dashed #007AFF';
    container.style.borderRadius = '8px';
    container.style.display = 'flex';
    container.style.alignItems = 'center';
    container.style.gap = '20px';

    const smallInput = document.createElement('input');
    smallInput.type = 'text';
    smallInput.placeholder = 'Small';
    smallInput.style.fontSize = '12px';
    smallInput.style.padding = '6px 8px';
    smallInput.style.border = '2px solid #20c997';
    smallInput.style.borderRadius = '4px';
    smallInput.style.background = '#f0fff4';

    const normalInput = document.createElement('input');
    normalInput.type = 'text';
    normalInput.placeholder = 'Normal';
    normalInput.style.fontSize = '16px';
    normalInput.style.padding = '8px 10px';
    normalInput.style.border = '2px solid #20c997';
    normalInput.style.borderRadius = '4px';
    normalInput.style.background = '#f0fff4';

    const largeInput = document.createElement('input');
    largeInput.type = 'text';
    largeInput.placeholder = 'Large';
    largeInput.style.fontSize = '24px';
    largeInput.style.padding = '10px 12px';
    largeInput.style.border = '2px solid #20c997';
    largeInput.style.borderRadius = '4px';
    largeInput.style.background = '#f0fff4';

    container.appendChild(smallInput);
    container.appendChild(normalInput);
    container.appendChild(largeInput);
    document.body.appendChild(container);
    await snapshot();
  });

  it('min/max width constraints', async () => {
    const container = document.createElement('div');
    container.style.width = '100%';
    container.style.padding = '20px';
    container.style.background = '#fff';
    container.style.border = '3px dashed #007AFF';
    container.style.borderRadius = '8px';
    container.style.display = 'flex';
    container.style.alignItems = 'center';
    container.style.gap = '20px';

    const minWidthInput = document.createElement('input');
    minWidthInput.type = 'text';
    minWidthInput.placeholder = 'min-width: 300px';
    minWidthInput.style.minWidth = '300px';
    minWidthInput.style.padding = '10px 12px';
    minWidthInput.style.border = '2px solid #6610f2';
    minWidthInput.style.borderRadius = '4px';
    minWidthInput.style.fontSize = '16px';
    minWidthInput.style.background = '#f8f0ff';

    const maxWidthInput = document.createElement('input');
    maxWidthInput.type = 'text';
    maxWidthInput.placeholder = 'max-width: 100px';
    maxWidthInput.style.maxWidth = '100px';
    maxWidthInput.style.padding = '10px 12px';
    maxWidthInput.style.border = '2px solid #6610f2';
    maxWidthInput.style.borderRadius = '4px';
    maxWidthInput.style.fontSize = '16px';
    maxWidthInput.style.background = '#f8f0ff';

    container.appendChild(minWidthInput);
    container.appendChild(maxWidthInput);
    document.body.appendChild(container);
    await snapshot();
  });

  it('complex styling combination', async () => {
    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Complex styling';
    input.style.height = '120px';
    input.style.padding = '15px';
    input.style.fontSize = '18px';
    input.style.border = '3px solid #dc3545';
    input.style.borderRadius = '8px';
    input.style.background = '#fff5f5';
    input.style.lineHeight = '1.4';
    input.style.boxShadow = '0 4px 8px rgba(220, 53, 69, 0.2)';
    document.body.appendChild(input);
    await snapshot();
  });

  it('flex container behavior', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.gap = '15px';
    container.style.padding = '20px';
    container.style.background = '#fff';
    container.style.border = '3px dashed #007AFF';
    container.style.borderRadius = '8px';
    container.style.width = '100%';

    const input1 = document.createElement('input');
    input1.type = 'text';
    input1.placeholder = 'Flex item 1';
    input1.style.flex = '1';
    input1.style.padding = '10px 12px';
    input1.style.border = '2px solid #17a2b8';
    input1.style.borderRadius = '4px';
    input1.style.fontSize = '16px';
    input1.style.background = '#f0fdff';

    const input2 = document.createElement('input');
    input2.type = 'text';
    input2.placeholder = 'Flex item 2';
    input2.style.flex = '1';
    input2.style.padding = '10px 12px';
    input2.style.border = '2px solid #17a2b8';
    input2.style.borderRadius = '4px';
    input2.style.fontSize = '16px';
    input2.style.background = '#f0fdff';

    const input3 = document.createElement('input');
    input3.type = 'text';
    input3.placeholder = 'Flex item 3';
    input3.style.flex = '1';
    input3.style.padding = '10px 12px';
    input3.style.border = '2px solid #17a2b8';
    input3.style.borderRadius = '4px';
    input3.style.fontSize = '16px';
    input3.style.background = '#f0fdff';

    container.appendChild(input1);
    container.appendChild(input2);
    container.appendChild(input3);
    document.body.appendChild(container);
    await snapshot();
  });

  it('long placeholder text overflow', async () => {
    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Very very very very very very long placeholder text that should test text overflow behavior';
    input.style.width = '200px';
    input.style.padding = '10px 12px';
    input.style.border = '2px solid #6c757d';
    input.style.borderRadius = '4px';
    input.style.fontSize = '16px';
    input.style.background = '#f8f9fa';
    document.body.appendChild(input);
    await snapshot();
  });
});

describe('Input type radio', () => {
  xit('basic radio button', async () => {
    const radio = document.createElement('input');
    radio.type = 'radio';
    radio.value = 'option1';
    document.body.appendChild(radio);
    await snapshot();
  });

  xit('checked radio button', async () => {
    const radio = document.createElement('input');
    radio.type = 'radio';
    radio.checked = true;
    document.body.appendChild(radio);
    await snapshot();
  });


  xit('radio button with name group', async () => {
    const radio1 = document.createElement('input');
    const radio2 = document.createElement('input');
    radio1.type = 'radio';
    radio2.type = 'radio';
    radio1.name = 'group1';
    radio2.name = 'group1';
    radio1.checked = true;

    document.body.appendChild(radio1);
    document.body.appendChild(radio2);
    await snapshot();
  });

  xit('should uncheck other radios in same group when one is checked', (done) => {
    const radio1 = document.createElement('input');
    const radio2 = document.createElement('input');
    radio1.type = 'radio';
    radio2.type = 'radio';
    radio1.name = 'group2';
    radio2.name = 'group2';

    document.body.appendChild(radio1);
    document.body.appendChild(radio2);

    radio1.checked = true;
    expect(radio2.checked).toBe(false);

    radio2.checked = true;
    expect(radio1.checked).toBe(false);
    done();
  });

  xit('disabled radio button', async () => {
    const radio = document.createElement('input');
    radio.type = 'radio';
    radio.disabled = true;
    document.body.appendChild(radio);
    await snapshot();
  });

  xit('radio button click event', (done) => {
    const radio = document.createElement('input');
    radio.type = 'radio';
    document.body.appendChild(radio);

    radio.addEventListener('click', function handler() {
      expect(radio.checked).toBe(true);
      done();
    });

    requestAnimationFrame(() => {
      simulateClick(10, 10);
    });
  });

  xit('radio button change event', (done) => {
    const radio = document.createElement('input');
    radio.type = 'radio';
    document.body.appendChild(radio);

    radio.addEventListener('change', function handler() {
      expect(radio.checked).toBe(true);
      done();
    });

    requestAnimationFrame(() => {
      radio.checked = true;
    });
  });
})
