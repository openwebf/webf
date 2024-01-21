/**
 * Test DOM API for Element:
 * - EventTarget.prototype.addEventListener
 * - EventTarget.prototype.removeEventListener
 * - EventTarget.prototype.dispatchEvent
 */
describe('DOM EventTarget', () => {
  it('should work', async () => {
    let clickTime = 0;
    const div = document.createElement('div');

    const clickHandler = () => {
      clickTime++;
    };
    div.addEventListener('click', clickHandler);

    document.body.appendChild(div);
    div.click();
    div.click();

    await sleep(0.1);

    div.removeEventListener('click', clickHandler);

    await sleep(0.1);
    div.click();
    await sleep(0.1);

    // Only 2 times recorded.
    expect(clickTime).toBe(2);
  });

  it('addEventListener should work normally', (done) => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', () => {
      done();
    });
    document.body.appendChild(div);
    div.click();
  });

  it('addEventListener should work without connected into element tree', async done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', () => {
      done();
    });
    div.click();
    await snapshot(0.1);
  });

  it('addEventListener should work with multi event handler', async done => {
    let count = 0;
    let div1 = createElementWithStyle('div', {});
    let div2 = createElementWithStyle('div', {});
    div1.addEventListener('click', () => {
      count++;
    });

    div2.addEventListener('click', () => {
      count++;
      if (count == 2) {
        done();
      }
    });

    BODY.appendChild(div1);
    BODY.appendChild(div2);
    div1.click();
    div2.click();
    await sleep(0.1);
  });

  it('addEventListener should work with removeEventListeners', async () => {
    let div = createElementWithStyle('div', {});
    let count = 0;
    function onClick() {
      count++;
      div.removeEventListener('click', onClick);
    }
    div.addEventListener('click', onClick);

    BODY.appendChild(div);
    div.click();
    div.click();
    div.click();
    await sleep(0.1);
    div.addEventListener('click', onClick);
    expect(count).toBe(1);
  });

  it('should work with build in property handler', async (done) => {
    let div = createElementWithStyle('div', {});
    div.onclick = () => {
      done();
    };
    BODY.appendChild(div);
    div.click();
    await sleep(0.1);
  });

  it('event object should have type', async done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', (event: any) => {
      expect(event.type).toBe('click');
      done();
    });
    BODY.appendChild(div);
    div.click();
    await sleep(0.1);
  });

  it('event object target should equal to element itself', async done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', (event: any) => {
      expect(div === event.target);
      done();
    });
    BODY.appendChild(div);
    div.click();
    await sleep(0.1);
  });

  it('event object currentTarget should equal to element itself', async done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', (event: any) => {
      expect(div === event.currentTarget);
      done();
    });
    BODY.appendChild(div);
    div.click();
    await sleep(0.1);
  });

  it('trigger twice when onclick and bind addEventListener', async () => {
    let div = createElementWithStyle('div', {});
    let count = 0;
    div.addEventListener('click', (event: any) => {
      count++;
    });
    div.onclick = () => {
      count++;
    }
    BODY.appendChild(div);
    div.click();
    await sleep(0.1);
    expect(count).toBe(2);
  });

  it('stop propagation', async () => {
    let count1 = 0, count2 = 0;

    const div1 = document.createElement('div');
    const div2 = document.createElement('div');
    div1.appendChild(div2);
    div1.addEventListener('click', (event) => {
      count1++;
    });
    div2.addEventListener('click', (event) => {
      count2++;
      event.stopPropagation();
    });
    document.body.appendChild(div1);

    div2.click();
    div2.click();
    await sleep(0.1);

    expect(count1).toBe(0);
    expect(count2).toBe(2);
  });

  it('stop immediately propagation', () => {
    const div = document.createElement('div');
    document.body.appendChild(div);

    let shouldNotBeTrue = false;

    div.addEventListener('click', (event: Event) => {
      event.stopImmediatePropagation();
    });
    div.addEventListener('click', () => {
      // Unreach code.
      shouldNotBeTrue = true;
    });
    expect(shouldNotBeTrue).toEqual(false);
  });


  it('removeEventListener should work', async (done) => {
    let num = 0;
    var ele = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    document.body.appendChild(ele);
    ele.addEventListener('click', fn1);
    ele.removeEventListener('click', fn1);
    ele.addEventListener('click', fn2);

    function fn1() {
      num++;
    }

    function fn2() {
      num++;
      expect(num).toEqual(1);
      done();
    }

    ele.click();
    await sleep(0.1);
  });

});
