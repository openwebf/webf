describe('CSS1 padding-left', () => {
  it('padding-left 0 with silver background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.zero {background-color: silver; padding-left: 0;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.zero {background-color: silver; padding-left: 0;}')
    ]);
    
    const p0 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      paddingLeft: '0'
    }, [
      createText('This element has a class of zero.')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p0);
    
    await snapshot();
  });

  it('padding-left 0.5in with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.one {padding-left: 0.5in; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.one {padding-left: 0.5in; background-color: aqua;}')
    ]);
    
    const p1 = createElementWithStyle('p', {
      paddingLeft: '0.5in',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a left padding of half an inch, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p1);
    
    await snapshot();
  });

  it('padding-left 25px with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.two {padding-left: 25px; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.two {padding-left: 25px; background-color: aqua;}')
    ]);
    
    const p2 = createElementWithStyle('p', {
      paddingLeft: '25px',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a left padding of 25 pixels, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    
    await snapshot();
  });

  it('padding-left 5em with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.three {padding-left: 5em; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.three {padding-left: 5em; background-color: aqua;}')
    ]);
    
    const p3 = createElementWithStyle('p', {
      paddingLeft: '5em',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a left padding of 5em, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p3);
    
    await snapshot();
  });

  it('padding-left 25% with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.four {padding-left: 25%; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.four {padding-left: 25%; background-color: aqua;}')
    ]);
    
    const p4 = createElementWithStyle('p', {
      paddingLeft: '25%',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a left padding of 25%, which is calculated with respect to the width of the parent element.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p4);
    
    await snapshot();
  });

  it('padding-left 25px on ul with list items', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.two {padding-left: 25px; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.two {padding-left: 25px; background-color: aqua;}')
    ]);
    
    const li1 = createElement('li', {}, [
      createText('The left padding on this unordered list has been set to 25 pixels, which will require some extra test in order to test.')
    ]);
    
    const li2 = createElementWithStyle('li', {
      paddingLeft: '25px',
      backgroundColor: 'white'
    }, [
      createText('Another list item might not be such a bad idea, either, considering that such things do need to be double-checked.  This list item has its left padding also set to 25 pixels, which should combine with the list\'s padding to make 50 pixels of margin.')
    ]);
    
    const ul = createElementWithStyle('ul', {
      paddingLeft: '25px',
      backgroundColor: 'gray'
    }, [
      li1,
      li2
    ]);

    BODY.style.fontFamily = 'Times';

    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, ul);
    
    await snapshot();
  });

  it('padding-left -20px with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.five {padding-left: -20px; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.five {padding-left: -20px; background-color: aqua;}')
    ]);
    
    const p5 = createElementWithStyle('p', {
      paddingLeft: '-20px',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have no left padding, since negative padding values are not allowed.  Both the content background and the normal padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p5);
    
    await snapshot();
  });
});