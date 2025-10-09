describe('CSS1 Cascading Order', () => {
  it('cascading order with element and descendant selectors', async () => {
    const linkStyle = createElement('style', {}, [
      createText(`LI {text-decoration: underline;}`)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(linkStyle);

    const style = createElement('style', {}, [
      createText(`
        LI {color: purple;}
        UL LI {color: blue;}
        UL LI LI {color: gray;}
      `)
    ]);
    
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`LI {color: purple;}
UL LI {color: blue;}
UL LI LI {color: gray;}`)
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const ul1 = createElement('ul', {}, []);
    
    const li1 = createElement('li', {}, [
      createText('This list item should be blue...')
    ]);
    
    const li2 = createElement('li', {}, [
      createText('...and so should this; neither should be purple.')
    ]);
    
    const ul2 = createElement('ul', {}, []);
    
    const li3 = createElement('li', {}, [
      createText('This list item should be gray...')
    ]);
    
    const li4 = createElement('li', {}, [
      createText('...as should this....')
    ]);
    
    append(ul2, li3);
    append(ul2, li4);
    
    append(ul1, li1);
    append(ul1, li2);
    append(ul1, ul2);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, ul1);

    await snapshot();
  });

  it('cascading order with class and id selectors', async () => {
    const linkStyle = createElement('style', {}, [
      createText(`LI {text-decoration: underline;}`)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(linkStyle);

    const style = createElement('style', {}, [
      createText(`
        UL LI {color: blue;}
        UL LI LI {color: gray;}
        LI.red {color: green;}
        UL LI.mar {color: #660000;}
        UL LI#gre {color: green;}
      `)
    ]);
    
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`UL LI {color: blue;}
UL LI LI {color: gray;}
LI.red {color: green;}
UL LI.mar {color: #660000;}
UL LI#gre {color: green;}`)
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const ul1 = createElement('ul', {}, []);
    
    const ul2 = createElement('ul', {}, []);
    
    const li5 = createElement('li', {
      className: 'red'
    }, [
      createText('...but this one should be green.')
    ]);
    
    append(ul2, li5);
    
    const li6 = createElement('li', {
      className: 'mar'
    }, [
      createText('This ought to be dark red...')
    ]);
    
    const li7 = createElement('li', {
      id: 'gre'
    }, [
      createText('...this green...')
    ]);
    
    const li8 = createElement('li', {}, [
      createText('...and this blue.')
    ]);
    
    append(ul1, ul2);
    append(ul1, li6);
    append(ul1, li7);
    append(ul1, li8);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, ul1);

    await snapshot();
  });

  it('cascading order with inline style and duplicate class rules', async () => {
    const style = createElement('style', {}, [
      createText(`
        .test {color: blue;}
        .test {color: purple;}
      `)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`.test {color: blue;}
.test {color: purple;}`)
    ]);
    
    const hr = createElement('hr', {}, []);

    const p2 = createElement('p', {
      style: 'color: blue;'
    }, [
      createText('This sentence should be blue (STYLE attr.).')
    ]);
    
    const p3 = createElement('p', {
      className: 'test'
    }, [
      createText('This sentence should be purple ['),
      createElement('code', {}, [createText('class="test"')]),
      createText('].')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);

    await snapshot();
  });

  it('cascading order with text-decoration override', async () => {
    const linkStyle = createElement('style', {}, [
      createText(`LI {text-decoration: underline;}`)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(linkStyle);

    const style = createElement('style', {}, [
      createText(`.one {text-decoration: line-through;}`)
    ]);
    
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`<LINK rel="stylesheet" type="text/css" HREF="../resources/linktest.css">
.one {text-decoration: line-through;}`)
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const p4 = createElement('p', {
      className: 'one'
    }, [
      createText('This text should be stricken (overriding the imported underline; only works if LINKed sheets are supported).')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p4);

    await snapshot();
  });
});