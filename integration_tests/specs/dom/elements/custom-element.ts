describe('custom widget element', () => {
  it('use flutter text', async () => {
    const text = document.createElement('flutter-text');
    text.setAttribute('value', 'Hello');
    document.body.appendChild(text);

    await snapshot();

    text.setAttribute('value', 'Hi');
    await snapshot();
  });

  it('should work with html tags', async () => {
    let div = document.createElement('div');
    div.innerHTML = `<flutter-text value="Hello" />`;
    document.body.appendChild(div);
    await snapshot();

    div.innerHTML = `<flutter-text value="Hi"></flutter-text>`;
    await snapshot();
  });

  it('use flutter asset image', async () => {
    const image = document.createElement('flutter-asset-image');
    image.setAttribute('src', 'assets/rabbit.png');
    document.body.appendChild(image);

    await snapshot(0.1);
  });

  it('work with click event', async (done) => {
    const image = document.createElement('flutter-asset-image');
    image.setAttribute('src', 'assets/rabbit.png');
    document.body.appendChild(image);

    image.addEventListener('click', function (e) {
      done();
    });

    await sleep(0.2);

    simulateClick(20, 20);
  });

  it('text node should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    const text = document.createTextNode('text');
    document.body.appendChild(container);
    container.appendChild(text);
    await snapshot();
  });

  it('text node should be child of flutter container and append before container append to body', async () => {
    const container = document.createElement('flutter-container');
    const text = document.createTextNode('text');
    container.appendChild(text);
    document.body.appendChild(container);
    await snapshot();
  });

  it('element should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    const element = document.createElement('div');
    element.style.width = '30px';
    element.style.height = '30px';
    element.style.backgroundColor = 'red';
    container.appendChild(element);
    document.body.appendChild(container);
    await snapshot();
  });

  it('flutter widget should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'text');
    container.appendChild(fluttetText);
    document.body.appendChild(container);

    await snapshot();
  });

  it('flutter widget and dom node should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);

    const element = document.createElement('div');
    element.style.backgroundColor = 'red';
    element.style.textAlign = 'center';
    element.appendChild(document.createTextNode('div element'));
    container.appendChild(element);

    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'text');
    container.appendChild(fluttetText);

    const text = document.createTextNode('text');
    container.appendChild(text);

    await snapshot();
  });

  it('flutter widget should be child of element', async () => {
    const container = document.createElement('div');
    container.style.width = '100px';
    container.style.height = '100px';
    container.style.backgroundColor = 'red';
    const element = document.createElement('flutter-text');
    element.setAttribute('value', 'text');
    container.appendChild(element);
    document.body.appendChild(container);

    await snapshot();
  });

  it('flutter widget should be child of element and the element should be child of flutter widget', async (done) => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);

    const childContainer = document.createElement('div');
    container.appendChild(childContainer);

    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'text');
    childContainer.appendChild(fluttetText);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('flutter widget should work when text removed from this', async (done) => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);
    let textA = document.createTextNode('A');
    container.appendChild(textA);
    await snapshot();
    let textB = document.createTextNode('B');
    setTimeout(async () => {
      container.appendChild(textB);
      await sleep(0.1);
      await snapshot();
      container.removeChild(textA);
      await sleep(0.1);
      await snapshot();
      setTimeout(async () => {
        container.removeChild(textB);
        document.body.removeChild(container);
        requestAnimationFrame(async () => {
          await snapshot();
          done();
        });
      });
    });
  });

  it('flutter widget should work when div and text removed from this', async (done) => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);
    let divA = document.createElement('div');
    let textA = document.createTextNode('A');
    divA.appendChild(textA);
    container.appendChild(divA);
    await sleep(0.1);
    await snapshot();
    let textB = document.createTextNode('B');
    let divB = document.createElement('div');
    divB.appendChild(textB);
    setTimeout(async () => {
      container.appendChild(divB);
      await sleep(0.1);
      await snapshot();
      container.removeChild(divA);
      await sleep(0.1);
      await snapshot();
      setTimeout(async () => {
        container.removeChild(divB);
        document.body.removeChild(container);
        await snapshot();
        done();
      });
    });
  });

  it('flutter widget should work when wrap div and flutter widgets from this', async done => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);
    let buttonA = document.createElement('flutter-button');
    let divA = document.createElement('div');
    let textA = document.createTextNode('A');
    divA.appendChild(textA);
    buttonA.appendChild(divA);
    container.appendChild(buttonA);
    await snapshot();
    let buttonB = document.createElement('flutter-button');
    buttonB.style.height = '100px';
    let textB = document.createTextNode('B');
    let divB = document.createElement('div');
    divB.appendChild(textB);
    buttonB.appendChild(divB);
    setTimeout(async () => {
      container.appendChild(buttonB);
      await snapshot();
      container.removeChild(buttonA);
      await snapshot();
      setTimeout(async () => {
        container.removeChild(buttonB);
        document.body.removeChild(container);
        await snapshot();
        done();
      });
    });
  });

  it('flutter widget should work when wrap div and the div wrap another flutter widgets and this flutter widget also wrap div and text', async done => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);
    let buttonWrapperA = document.createElement('div');
    let buttonA = document.createElement("flutter-button");
    let divA = document.createElement('div');
    let textA = document.createTextNode('A');
    divA.appendChild(textA);
    buttonA.appendChild(divA);
    buttonWrapperA.appendChild(buttonA);
    buttonWrapperA.style.border = '2px solid #000';
    container.appendChild(buttonWrapperA);

    requestAnimationFrame(async () => {
      await snapshot();
      let buttonB = document.createElement('flutter-button');
      let buttonWrapperB = document.createElement('div');
      let textB = document.createTextNode('B');
      let divB = document.createElement('div');
      divB.appendChild(textB);
      buttonB.appendChild(divB);
      buttonWrapperB.appendChild(buttonB);
      setTimeout(async () => {
        container.appendChild(buttonWrapperB);
        requestAnimationFrame(async () => {
          await snapshot();
          container.removeChild(buttonWrapperA);
          await snapshot();
          setTimeout(async () => {
            container.removeChild(buttonWrapperB);
            document.body.removeChild(container);
            await snapshot();
            done();
          });
        })
      });
    });
  });

  it('should work with flutter-listview', async () => {
    const flutterContainer = document.createElement('flutter-listview');
    flutterContainer.style.height = '100vh';
    flutterContainer.style.display = 'block';

    document.body.appendChild(flutterContainer);

    const colors = ['red', 'yellow', 'black', 'blue', 'green'];

    const promise_loading: Promise<void>[] = [];

    for (let i = 0; i < 10; i++) {
      const div = document.createElement('div');
      div.style.width = '100%';
      div.style.border = `1px solid ${colors[i % colors.length]}`;
      div.appendChild(document.createTextNode(`${i}`));

      const img = document.createElement('img');
      img.src = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
      div.appendChild(img);
      img.style.width = '100px';
      promise_loading.push(new Promise((resolve, reject) => {
        img.onload = () => {resolve();}
      }));

      flutterContainer.appendChild(div);
    }
    await Promise.all(promise_loading);

    await snapshot();
  });

  it('getBoundingClientRect should work with items in listview', async (done) => {
    const flutterContainer = document.createElement('flutter-listview');
    flutterContainer.style.height = '100vh';
    flutterContainer.style.display = 'block';

    document.body.appendChild(flutterContainer);

    const div = document.createElement('div');
    div.style.width = '100%';
    div.style.height = '100px';
    div.style.border = `1px solid red`;

    const img = document.createElement('img');
    img.src = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    div.appendChild(img);

    flutterContainer.appendChild(div);

    requestAnimationFrame(async () => {
       const rect = div.getBoundingClientRect();
       expect(rect.height).toEqual(100);
       done();
    });
  });

  it('flutter widget should spread out the parent node when parent node is line-block', async () => {
    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'flutter text');
    fluttetText.style.display = 'inline-block';
    document.body.appendChild(fluttetText);
    document.body.appendChild(document.createTextNode('dom text'));

    await snapshot();
  });

  it('flutter widget should spread out the parent node when parent node is line', async () => {
    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'flutter text');
    fluttetText.style.display = 'inline';
    document.body.appendChild(fluttetText);
    document.body.appendChild(document.createTextNode('dom text'));

    await snapshot();
  });

  it('flutter widget should spread out the parent node when parent node is block', async () => {
    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'flutter text');
    fluttetText.style.display = 'block';
    document.body.appendChild(fluttetText);
    document.body.appendChild(document.createTextNode('dom text'));

    await snapshot();
  });

  it('flutter widget should spread out the parent node when parent node is flex', async () => {
    const div = document.createElement('div');
    div.style.display = 'flex';
    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'flutter text');
    fluttetText.style.display = 'block';
    div.appendChild(fluttetText);
    div.appendChild(document.createTextNode('111'));
    document.body.appendChild(div);

    await snapshot();
  });

  it('flutter widget should spread out the parent node when parent node is sliver', async () => {
    const div = document.createElement('div');
    div.style.display = 'sliver';
    div.style.height = '500px';
    div.appendChild(document.createTextNode('111'));
    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'flutter text');
    fluttetText.style.display = 'block';
    div.appendChild(fluttetText);
    div.appendChild(document.createTextNode('111'));
    document.body.appendChild(div);

    await snapshot();
  });

  it('flutter widgets should works when append widget element inside of widget element m', async () => {
    const form = document.createElement('form');
    form.style.height = '300px';
    for(let i = 0; i < 2; i ++) {
      let div = document.createElement('div');
      let input = document.createElement('input');
      input.value = i.toString();
      div.appendChild(input);
      form.appendChild(div);
    }
    document.body.appendChild(form);

    await sleep(0.1);
    await snapshot();
  });

  it('flutter widgets should inserted at correct location with other DOM elements', async () => {
    const form = document.createElement('form');
    form.style.height = '300px';
    form.appendChild(document.createTextNode('BEFORE CONTAINER.'));
    for(let i = 0; i < 2; i ++) {
      let div = document.createElement('div');
      div.appendChild(document.createTextNode('BEFORE INPUT.'));
      const input = document.createElement('input') as HTMLInputElement;
      input.value = i.toString();
      div.appendChild(input);
      div.appendChild(document.createTextNode('AFTER INPUT.'));
      form.appendChild(div);
    }
    form.appendChild(document.createTextNode('AFTER CONTAINER.'));
    document.body.appendChild(form);
    await sleep(0.1);
    await snapshot();
  });
});

describe('custom html element', () => {
  it('works with document.createElement', async () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);
    await snapshot();
  });

  it('dart implements getAllBindingPropertyNames works', async () => {
    let sampleElement = document.createElement('sample-element');
    let attributes = Object.keys(sampleElement);
    expect(attributes).toEqual(['classList', 'className', 'clientHeight', 'clientLeft', 'clientTop', 'clientWidth', 'fake', 'offsetHeight', 'offsetLeft', 'offsetTop', 'offsetWidth', 'ping', 'scrollHeight', 'scrollLeft', 'scrollTop', 'scrollWidth', 'asyncFn', 'asyncFnFailed', 'asyncFnNotComplete', 'click', 'fn', 'getBoundingClientRect', 'getElementsByClassName', 'getElementsByTagName', 'scroll', 'scrollBy', 'scrollTo']);
  });

  it('support custom properties in dart directly', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    // @ts-ignore
    expect(sampleElement.ping).toBe('pong');
  });

  it('support call js function but defined in dart directly', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    let arrs = [1, 2, 4, 8, 16];
    // @ts-ignore
    let fn = sampleElement.fn;
    expect(fn.apply(sampleElement, arrs)).toEqual([2, 4, 8, 16, 32]);
    // @ts-ignore
    expect(fn.apply(sampleElement, arrs)).toEqual([2, 4, 8, 16, 32]);
  });

  it('return promise when dart return future async function', async () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);
    // @ts-ignore
    let p = sampleElement.asyncFn(1);
    expect(p instanceof Promise);
    let result = await p;
    expect(result).toBe(1);
    // @ts-ignore
    let p2 = sampleElement.asyncFn('abc');
    expect(await p2).toBe('abc');

    // @ts-ignore
    let p3 = sampleElement.asyncFn([1, 2, 3, 4]);
    expect(await p3).toEqual([1, 2, 3, 4]);

    // @ts-ignore
    let p4 = sampleElement.asyncFn([{ name: 1 }]);
    expect(await p4).toEqual([{ name: 1 }]);
  });

  it('return promise maybe not complete from dart side', async (done) => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);
    // @ts-ignore
    let p = sampleElement.asyncFnNotComplete();
    expect(p instanceof Promise);

    p.then(() => {
      done.fail('should not resolved');
    });

    setTimeout(() => {
      done();
    }, 2000);
  });

  it('return promise error when dart async function throw error', async () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);
    // @ts-ignore
    let p = sampleElement.asyncFnFailed();
    expect(p instanceof Promise);
    try {
      let result = await p;
      throw new Error('should throw');
    } catch (e) {
      expect(e.message.trim()).toBe('Assertion failed: "Asset error"');
    }
  });

  it('property with underscore have no effect', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    // @ts-ignore
    expect(sampleElement._fake).toBe(null);

    // @ts-ignore
    sampleElement._fake = [1, 2, 3, 4, 5];
    // @ts-ignore
    sampleElement._fn = () => 1;
    // @ts-ignore
    sampleElement._self = sampleElement;
    // @ts-ignore
    expect(sampleElement._fake).toEqual([1, 2, 3, 4, 5]);
    // @ts-ignore
    expect(sampleElement._fn()).toBe(1);
    // @ts-ignore
    expect(sampleElement._self === sampleElement);
  });

  it('should work with cloneNode', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    // @ts-ignore
    expect(sampleElement._fake).toBe(null);

    // @ts-ignore
    sampleElement._fake = [1, 2, 3, 4, 5];
    // @ts-ignore
    sampleElement._fn = () => 1;
    // @ts-ignore
    sampleElement._self = sampleElement;
    // @ts-ignore
    expect(sampleElement._fake).toEqual([1, 2, 3, 4, 5]);
    // @ts-ignore
    expect(sampleElement._fn()).toBe(1);
    // @ts-ignore
    expect(sampleElement._self === sampleElement);

    let clone = sampleElement.cloneNode();

    // @ts-ignore
    expect(clone._fake).toEqual([1,2,3,4,5]);
    // @ts-ignore
    expect(clone._fn()).toEqual(1);
    // @ts-ignore
    expect(clone._self).toBe(sampleElement);
  });

  it('should work with checkbox', async (done) => {
    let checkbox = document.createElement('input');
    checkbox.setAttribute('type', 'checkbox');
    document.body.appendChild(checkbox);
    await snapshot();

    await simulateClick(10, 10);

    setTimeout(async () => {
      await snapshot();
      done();
    }, 800);
  });
});
