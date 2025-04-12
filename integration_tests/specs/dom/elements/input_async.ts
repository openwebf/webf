describe('Tempoary Tags input async', () => {
  it('input text can set height', async (done) => {
    const input = document.createElement('input');
    // @ts-ignore
    input.value_async = 'helloworld';
    document.body.appendChild(input);
    await snapshot();
    input.style.height = '100px';
    await snapshot();
    done();
  });
});

describe('Tags input async', () => {

  it('type password', async (done) => {
    const div = document.createElement('div');
    const input = document.createElement('input');

    // @ts-ignore
    input.type_async = 'password';
    // @ts-ignore
    input.value_async = 'HelloWorld';
    // @ts-ignore
    input.placeholder_async = "This is placeholder.";

    div.appendChild(input);
    document.body.appendChild(div);

    await snapshot();
    done();
  });

  xit('event input', async (done) => {
    const VALUE = 'Hello';
    const input = document.createElement('input');
    // @ts-ignore
    input.value_async = '';
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      // @ts-ignore
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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

    input1.addEventListener('change', async function handler(event) {
      // @ts-ignore
      let v = await input1.value_async
      expect(v).toEqual(VALUE);
      done();
    });

    input1.focus();

    requestAnimationFrame(() => {
      input1.setAttribute('value', VALUE);
      input2.focus();
    });
  });

  xit('support inputmode=text', (done) => {
    const VALUE = 'Hello';
    const input = <input inputmode="text" />;
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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
    const VALUE = '123456789';
    const input = <input inputmode="tel" />;
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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
    input.addEventListener('input', async function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      let v = await input.value_async
      expect(v).toEqual(VALUE);
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

  xit('support maxlength', (done) => {
    const input = <input maxlength="3" />;
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateInputText('1');
      requestAnimationFrame(async () => {
        let v = await input.value_async
        expect(v).toEqual('1');

        simulateInputText('123');
        requestAnimationFrame(async () => {
          let v = await input.value_async
          expect(v).toEqual('123');

          simulateInputText('1234');
          requestAnimationFrame(async () => {
            let v = await input.value_async
            expect(v).toEqual('123');
            done();
          });
        });
      });
    });
  });


  it('should return empty string when set value to null', async (done) => {
    const input = document.createElement('input');
    document.body.appendChild(input);

    input.addEventListener('onscreen', async () => {
      input.value = '1234';
      // @ts-ignore
      let v = await input.value_async
      expect(v).toBe('1234');
      // @ts-ignore
      input.value_async = null;
      // @ts-ignore
      v = await input.value_async
      expect(v).toBe('');
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

    requestAnimationFrame(async () => {
      input.setAttribute('value', 'attribute value');
      // @ts-ignore
      let defaultValue = await input.defaultValue_async
      // @ts-ignore
      let value = await input.value_async
      expect(defaultValue).toBe('attribute value');
      expect(value).toBe('attribute value');
      
      // @ts-ignore
      input.defaultValue_async = 'default value';
      // @ts-ignore
      defaultValue = await input.defaultValue_async
      // @ts-ignore
      value = await input.value_async
      expect(defaultValue).toBe('default value');
      expect(value).toBe('default value');

      // @ts-ignore
      input.value_async = 'property value';
      // @ts-ignore
      defaultValue = await input.defaultValue_async
      // @ts-ignore
      value = await input.value_async
      expect(defaultValue).toBe('default value');
      expect(value).toBe('property value');

      input.setAttribute('value', 'attribute value 2');
       // @ts-ignore
       defaultValue = await input.defaultValue_async
       // @ts-ignore
       value = await input.value_async
      expect(defaultValue).toBe('attribute value 2');
      // @ts-ignore
      expect(value).toBe('property value');

      done();
    });
  });
});
