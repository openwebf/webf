describe('Event', () => {
  it('should work with order', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    Object.assign(container1.style, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '40px',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    const container2 = document.createElement('div');
    Object.assign(container2.style, {
      padding: '20px',
      height: '100px',
      backgroundColor: '#f40',
      margin: '40px',
    });
    container2.appendChild(document.createTextNode('DIV 2'));

    container1.appendChild(container2);

    document.body.addEventListener('click', function listener(e) {
      wrapper.appendChild(document.createTextNode('BODY clicked, '));
      document.body.removeEventListener('click', listener);
    });
    container1.addEventListener('click', (e) => {
      wrapper.appendChild(document.createTextNode('DIV 1 clicked, '));
    });
    container2.addEventListener('click', (e) => {
      wrapper.appendChild(document.createTextNode('DIV 2 clicked, '));
    });

    const wrapper = document.createElement('div');
    document.body.appendChild(wrapper);
    wrapper.appendChild(document.createTextNode('Click DIV 2: '));

    container2.click();
    await snapshot();
  });

  it('dispatch event with capture should work in order', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    Object.assign(container1.style, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '40px',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    const container2 = document.createElement('div');
    Object.assign(container2.style, {
      padding: '20px',
      height: '100px',
      backgroundColor: '#f40',
      margin: '40px',
    });
    container2.appendChild(document.createTextNode('DIV 2'));

    container1.appendChild(container2);

    document.body.addEventListener('click', function listener(e) {
      wrapper.appendChild(document.createTextNode('BODY clicked, '));
      document.body.removeEventListener('click', listener);
    });
    document.body.addEventListener('click', function listener(e) {
      wrapper.appendChild(document.createTextNode('BODY Capture, '));
      document.body.removeEventListener('click', listener);
    }, true);
    container1.addEventListener('click', (e) => {
      wrapper.appendChild(document.createTextNode('DIV 1 clicked, '));
    });
    container1.addEventListener('click', (e) => {
      wrapper.appendChild(document.createTextNode('DIV 1 Capture, '));
    }, true);
    container2.addEventListener('click', (e) => {
      wrapper.appendChild(document.createTextNode('DIV 2 clicked, '));
    });
    container2.addEventListener('click', (e) => {
      wrapper.appendChild(document.createTextNode('DIV 2 Capture, '));
    }, true);

    const wrapper = document.createElement('div');
    document.body.appendChild(wrapper);
    wrapper.appendChild(document.createTextNode('Click DIV 2: '));

    container2.click();
    await snapshot();
  });

  it('should trigger event with addEventListener', done => {
    let div = document.createElement('div');
    div.addEventListener('click', done);
    document.body.appendChild(div);
    div.click();
  });

  it('do not trigger click when scrolling', async () => {
    let clickCount = 0;
    let container;
    let list:any = [];
    for (let i = 0; i < 100; i ++) {
      list.push(i);
    }
    let scroller;
    container = createViewElement(
      {
        width: '200px',
        height: '500px',
        flexShrink: 1,
        border: '2px solid #000',
      },
      [
        createViewElement(
          {
            height: '20px',
          },
          []
        ),
        scroller = createViewElement(
          {
            flex: 1,
            width: '200px',
            overflow: 'scroll',
          },
          list.map(index => {
            let element =  createElement('div', {}, [createText(`${index}`)]);
            element.onclick = () => {
              clickCount += 1;
            }
            return element;
          })
        ),
      ]
    );

    BODY.appendChild(container);

    await simulateClick(20, 60);
    await simulateSwipe(20, 100, 20, 20, 0.1);
    expect(clickCount).toBe(1);
  });

  it('text node can not trigger click', async () => {
    let clickCount =  0;
    const text = createText('text');
    BODY.appendChild(text);
    text.addEventListener('click', () => {
      clickCount++;
    });
    await simulateClick(10, 10);
    expect(clickCount).toBe(0);
  });

  it('when the node transforms, the click event triggers the wrong node', async () => {
    let clickText = '';

    const div = document.createElement('div');
    setElementStyle(div, {
      position: 'absolute',
      width: '80px',
      height: '30px',
      backgroundColor: 'red',
    });
    div.addEventListener('click', function listener() {
      clickText = 'red';
      div.removeEventListener('click', listener);
    });

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      position: 'absolute',
      width: '80px',
      height: '30px',
      backgroundColor: 'blue',
      transform: 'translate3d(0px, 60px, 0px) scale(1, 1)',
    });
    div2.addEventListener('click', function listener() {
      clickText = 'blue';
      div2.removeEventListener('click', listener);
    });

    document.body.appendChild(div);
    document.body.appendChild(div2);
    await simulateClick(20, 20);
    expect(clickText).toBe('red');
  });

  it('the event cannot be triggered when the element scrolls to the invisible container range', async () => {
    let clickCount = 0;

    const container = document.createElement('div');

    container.style.overflow = 'hidden';
    container.style.width = '300px';
    container.style.height = '500px';
    container.style.backgroundColor = 'blue';

    document.body.appendChild(container);

    const container2 = document.createElement('div');

    container2.style.overflow = 'scroll';
    container2.style.width = '300px';
    container2.style.height = '500px';
    container2.style.marginTop = '50px';
    container2.style.backgroundColor = 'red';

    const block1 =document.createElement('div');
    block1.style.width = '100px';
    block1.style.height = '100px';
    block1.style.backgroundColor = 'yellow';

    const block =document.createElement('div');
    block.style.width = '100px';
    block.style.height = '100px';
    block.style.backgroundColor = 'green';
    block.addEventListener('click', () => clickCount++);

    const block2 =document.createElement('div');
    block2.style.width = '100px';
    block2.style.height = '700px';
    block2.style.backgroundColor = 'yellow';

    container.appendChild(container2);
    container2.appendChild(block1);
    container2.appendChild(block);
    container2.appendChild(block2);

    container2.scrollTo(0, 150);

    await simulateClick(25, 25);
    await simulateClick(25, 75);
    expect(clickCount).toBe(1);
  })

  it('the event cannot be triggered when the element hidden to the invisible container range', async () => {
    let clickCount = 0;

    const container = document.createElement('div');

    container.style.overflow = 'hidden';
    container.style.width = '100px';
    container.style.height = '100px';
    container.style.backgroundColor = 'blue';

    document.body.appendChild(container);

    const block =document.createElement('div');
    block.style.width = '300px';
    block.style.height = '50px';
    block.style.backgroundColor = 'green';
    block.addEventListener('click', () => clickCount++);
    container.appendChild(block);

    await simulateClick(50, 20);
    await simulateClick(150, 10);
    expect(clickCount).toBe(1);
  })

  it('the event cannot be triggered when the element visibel to the invisible container range', async () => {
    let clickCount = 0;

    const container = document.createElement('div');

    container.style.overflow = 'visible';
    container.style.width = '100px';
    container.style.height = '100px';
    container.style.backgroundColor = 'blue';

    document.body.appendChild(container);

    const block =document.createElement('div');
    block.style.width = '300px';
    block.style.height = '50px';
    block.style.backgroundColor = 'green';
    block.addEventListener('click', () => clickCount++);
    container.appendChild(block);

    await simulateClick(50, 20);
    await simulateClick(150, 20);
    expect(clickCount).toBe(2);
  })

  it('the event cannot be triggered when the element with not overflow to the invisible container range', async () => {
    let clickCount = 0;

    const container = document.createElement('div');

    container.style.width = '100px';
    container.style.height = '100px';
    container.style.backgroundColor = 'blue';

    document.body.appendChild(container);

    const block = document.createElement('div');
    block.style.width = '300px';
    block.style.height = '50px';
    block.style.backgroundColor = 'green';
    block.addEventListener('click', () => clickCount++);
    container.appendChild(block);

    await simulateClick(50, 20);
    await simulateClick(150, 30);
    expect(clickCount).toBe(2);
  })

  it('When the scroll element itself scrolls to the invisible container range, the event cannot be triggered', async () => {
    let clickCount = 0;

    const container = document.createElement('div');

    container.style.overflow = 'hidden';
    container.style.width = '300px';
    container.style.height = '500px';
    container.style.backgroundColor = 'blue';

    document.body.appendChild(container);

    const container2 = document.createElement('div');

    container2.style.overflow = 'scroll';
    container2.style.width = '300px';
    container2.style.height = '500px';
    container2.style.marginTop = '50px';
    container2.style.backgroundColor = 'red';
    container2.addEventListener('click', ()=>clickCount++)

    const block1 =document.createElement('div');
    block1.style.width = '100px';
    block1.style.height = '1000px';
    block1.style.backgroundColor = 'yellow';

    container.appendChild(container2);
    container2.appendChild(block1);

    container2.scrollTo(0, 50);

    await simulateClick(25, 25);
    await simulateClick(25, 75);
    expect(clickCount).toBe(1);
  })

  xit('when scrolling to the boundary, the native gesture should be triggered', async (done) => {
    const container = document.createElement('div');

    container.style.overflow = 'scroll';
    container.style.width = '200px';
    container.style.height = '200px';
    container.style.backgroundColor = 'blue';

    document.body.appendChild(container);

    document.body.addEventListener('nativegesture', async function listener() {
      document.body.removeEventListener('nativegesture', listener);
      done();
    });

    await simulateSwipe(20, 20, 20, 100, 0.1);
  })

  it('when the node is transformed, hittest triggers the correct node', async () => {
    let clickText;
    const container = document.createElement('div');
    container.style.transform = 'translate3d(-33px, 0vw, 0vw)';
    container.style.width = '100px';
    container.style.height = '100px';

    document.body.appendChild(container);

    for(let i = 0; i < 3; i++) {
        const child = document.createElement('div');
        child.style.width = '33px';
        child.style.height = '100px';
        child.style.display='inline-block'
        child.style.backgroundColor = ['yellow','black','blue'][i];
        child.onclick = () => {
          clickText = i;
        }
        container.appendChild(child);
    }

    await simulateClick(10, 10);
    expect(clickText).toBe(1);
  })

  it('should work with createEvent and initEvent', async (done) => {
    const type = 'customtype';

    const div = document.createElement('div');
    div.style.width = '200px';
    div.style.height = '200px';
    div.style.backgroundColor = 'red';

    document.body.appendChild(div);
    div.addEventListener('click', () => {
        const e = document.createEvent('Event');
        e.initEvent(type, true, true);
        div.dispatchEvent(e);
    })

    div.addEventListener(type, () => {
      done();
    });

    div.click();
  });

  it('initEvent set bubbles', async () => {
    const e = document.createEvent('Event');
    e.initEvent('type', true, true);
    expect(e.bubbles).toBe(true);
  });

  it('initEvent set cancelable', async () => {
    const e = document.createEvent('Event');
    e.initEvent('type', true, true);
    expect(e.cancelable).toBe(true);
  });

  it('initEvent set type', async () => {
    const type = 'customtype';
    const e = document.createEvent('Event');
    e.initEvent(type, true, true);
    expect(e.type).toBe(type);
  });

  it('Event Level 0 removal', async () => {
    var el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let ret = '';
    function fn1() {
      ret += '1';
    }
    function fn2() {
      ret += '2';
    }
    el.onclick = fn1;
    el.click();
    await sleep(0.1);

    el.onclick = null;
    el.click();
    await sleep(0.1);

    el.onclick = fn2;
    el.click();
    await sleep(0.1);

    expect(ret).toEqual('12');
  });

  it('Event Level 2 listen multi-times', async () => {
    var el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let ret = '';
    function fn1() {
      ret += '1';
    }
    function fn2() {
      ret += '2';
    }
    el.addEventListener('click', fn1);
    el.addEventListener('click', fn1);
    el.addEventListener('click', fn2);
    el.click();

    await sleep(0.1);

    expect(ret).toEqual('12');
  });

  it('Event Level 2 listen multi-times with removal', async () => {
    var el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let ret = '';
    function fn1() {
      ret += '1';
    }
    function fn2() {
      ret += '2';
    }
    el.addEventListener('click', fn1);
    el.addEventListener('click', fn1);
    el.addEventListener('click', fn2);

    el.removeEventListener('click', fn1);
    el.removeEventListener('click', fn2);
    el.click();

    await sleep(0.1);

    expect(ret).toEqual('');
  });

  it('Add multi event types', async () => {
      var el = createElement('div', {
        style: {
          width: '100px',
          height: '100px',
          background: 'red'
        }
      });
      let ret = '';
      function fn1() {
        ret += '1';
      }
      el.addEventListener('click', fn1);
      el.addEventListener('scroll', fn1);

      el.click();

      await sleep(0.1);
      expect(ret).toEqual('1');
    });
  it('should work with undefined addEventListener options', async () => {
    var el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let ret = '';
    function fn1() {
      ret += '1';
    }
    el.addEventListener('click', fn1, undefined);
    el.addEventListener('scroll', fn1, undefined);

    el.click();
    await sleep(0.1);

    expect(ret).toEqual('1');
  });

  it('ResizeObserver observer one element', async (done)=> {
    const el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    document.body.appendChild(el);
    const observer = new ResizeObserver((entries)=>{
      if(entries) {
        done();
      }
    });
    observer.observe(el);
    el.style.width = '102px';
  });

  it('ResizeObserver observer one element and update twice', async (done)=> {
      const el = createElement('div', {
        style: {
          width: '100px',
          height: '100px',
          background: 'red'
        }
      });
      document.body.appendChild(el);
      const observer = new ResizeObserver((entries)=>{
        if(entries && entries.length > 0 && entries[entries.length-1].contentRect.width == 103) {
          done();
          return;
        }
        done.fail('ResizeObserver size get not right，'+ entries[entries.length-1].contentRect.width);
      });
      observer.observe(el);
      el.style.width = '102px';
      el.style.width = '103px';
    });

  it('ResizeObserver observer two element', async (done)=> {
    const el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    const el2 = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'yellow'
      }
    });
    document.body.appendChild(el);
    document.body.appendChild(el2);
    const observer = new ResizeObserver((entries)=>{
      if(entries && entries.length > 1) {
        done();
        return;
      }
      done.fail('ResizeObserver entries not ture');
    });
    observer.observe(el);
    observer.observe(el2);
    el.style.width = '102px';
    el2.style.width = '102px';
  });




  it('should work with share event object', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    Object.assign(container1.style, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '40px',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    const container2 = document.createElement('div');
    Object.assign(container2.style, {
      padding: '20px',
      height: '100px',
      backgroundColor: '#f40',
      margin: '40px',
    });
    container2.appendChild(document.createTextNode('DIV 2'));

    container1.appendChild(container2);

    document.body.addEventListener('click', function listener(e) {
      wrapper.appendChild(document.createTextNode(e.msg));
      document.body.removeEventListener('click', listener);
    });
    container1.addEventListener('click', (e) => {
      wrapper.appendChild(document.createTextNode(e.msg));
      e.msg = 'DIV 1 has clicked';
    });
    container2.addEventListener('click', (e) => {
      e.msg = 'DIV 2 has clicked, ';
    });

    const wrapper = document.createElement('div');
    document.body.appendChild(wrapper);
    wrapper.appendChild(document.createTextNode('Click DIV 2: '));

    container2.click();
    await snapshot();
  });

  it('shared string props should works', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    container.addEventListener('click', (e) => {
      e['_type'] = '1234';
      expect(e['_type']).toBe('1234');
      expect(e['_type']).toBe('1234');
      expect(e['_type']).toBe('1234');
      expect(e['_type']).toBe('1234');
    });
    container.click();
  });

  it('should work with share event callback', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    Object.assign(container1.style, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '40px',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    const container2 = document.createElement('div');
    Object.assign(container2.style, {
      padding: '20px',
      height: '100px',
      backgroundColor: '#f40',
      margin: '40px',
    });
    container2.appendChild(document.createTextNode('DIV 2'));

    container1.appendChild(container2);

    document.body.addEventListener('click', function listener(e) {
      wrapper.appendChild(document.createTextNode(e.getMsg()));
      document.body.removeEventListener('click', listener);
    });

    function fn () {
      return 'DIV 2 has clicked ';
    }
    container2.addEventListener('click', (e) => {
      e.getMsg = fn;
    });


    const wrapper = document.createElement('div');
    document.body.appendChild(wrapper);
    wrapper.appendChild(document.createTextNode('Click DIV 2: '));

    container2.click();
    await snapshot();
  });

  it('should works when override built-in properties', async () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    Object.assign(container.style, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '40px',
    });
    container.appendChild(document.createTextNode('DIV 1'));

    container.addEventListener('click', (e) => {
      e.preventDefault = () => 'PREVENTED';
    });

    document.body.addEventListener('click', (e) => {
      // @ts-ignore
      document.body.appendChild(document.createTextNode(e.preventDefault()));
    });

    document.body.appendChild(container);

    container.click();
    await snapshot();
  });
  it('ResizeObserver observer one element', async (done)=> {
    const el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    document.body.appendChild(el);
    const observer = new ResizeObserver((entries)=>{
      if(entries) {
        done();
      }
    });
    observer.observe(el);
    el.style.width = '102px';
  });
  it('ResizeObserver observer two element', async (done)=> {
    const el = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    const el2 = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'yellow'
      }
    });
    document.body.appendChild(el);
    document.body.appendChild(el2);
    const observer = new ResizeObserver((entries)=>{
      if(entries && entries.length > 1) {
        done();
      }
    });
    observer.observe(el);
    observer.observe(el2);
    el.style.width = '102px';
    el2.style.width = '102px';
  });

  it('should works with preventDefault in `<a /> element', async (done) => {
    const anchorElement = createElement('a', {}, [createText('')]);
    BODY.append(anchorElement);

    anchorElement.addEventListener('click', async (e) => {
      e.preventDefault();

      BODY.append(createText('Nothing happened'));

      await snapshot();
      done();
    });

    anchorElement.click();
  });

  it('should satisfy react-router event check', (done) => {
    function isModifiedEvent(event: MouseEvent) {
      return !!(event.metaKey || event.altKey || event.ctrlKey || event.shiftKey);
    }
    function shouldProcessLinkClick(event: MouseEvent) {
      return event.button === 0 &&
        // Let browser handle "target=_blank" etc.
        !isModifiedEvent(event) // Ignore clicks with modifier keys
        ;
    }

    const anchorElement = createElement('a', {}, []);
    BODY.append(anchorElement);

    anchorElement.addEventListener('click', async (e) => {
      expect(shouldProcessLinkClick(e));
      done();
    });

    anchorElement.click();
  });

  it('onscreen should fired when add event listener was listenerd', (done) => {
    const div = document.createElement('div');
    document.body.appendChild(div);

    setTimeout(() => {
      div.addEventListener('onscreen', () => {
        done();
      });
    }, 2000);
  });

  it('onscreen should fired on widget element when add event listener was listenered', (done) => {
    const listview = document.createElement('webf-listview');
    document.body.append(listview);

    setTimeout(() => {
      listview.addEventListener('onscreen', () => {
        done();
      });
    }, 2000);
  });
});
