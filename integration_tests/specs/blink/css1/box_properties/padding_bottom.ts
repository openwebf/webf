describe('CSS1 padding-bottom', () => {
  it('padding-bottom 0 with silver background first element', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.zero {background-color: silver; padding-bottom: 0;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.zero {background-color: silver; padding-bottom: 0;}')
    ]);
    
    const p0 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      paddingBottom: '0'
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

  it('padding-bottom 0.5in with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.one {padding-bottom: 0.5in; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.one {padding-bottom: 0.5in; background-color: aqua;}')
    ]);
    
    const p1 = createElementWithStyle('p', {
      paddingBottom: '0.5in',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a bottom padding of half an inch, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p1);
    
    await snapshot();
  });

  it('padding-bottom 25px with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.two {padding-bottom: 25px; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.two {padding-bottom: 25px; background-color: aqua;}')
    ]);
    
    const p2 = createElementWithStyle('p', {
      paddingBottom: '25px',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a bottom padding of 25 pixels, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    
    await snapshot();
  });

  it('padding-bottom 5em with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.three {padding-bottom: 5em; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.three {padding-bottom: 5em; background-color: aqua;}')
    ]);
    
    const p3 = createElementWithStyle('p', {
      paddingBottom: '5em',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a bottom padding of 5 em, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p3);
    
    await snapshot();
  });

  it('padding-bottom 25% with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.four {padding-bottom: 25%; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.four {padding-bottom: 25%; background-color: aqua;}')
    ]);
    
    const p4 = createElementWithStyle('p', {
      paddingBottom: '25%',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a bottom padding of 25%, which is calculated with respect to the width of the parent element.  This will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p4);
    
    await snapshot();
  });

  it('padding-bottom 0 with silver background second element', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.zero {background-color: silver; padding-bottom: 0;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.zero {background-color: silver; padding-bottom: 0;}')
    ]);
    
    const p0_2 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      paddingBottom: '0'
    }, [
      createText('This element has a class of zero.')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p0_2);
    
    await snapshot();
  });

  it('padding-bottom -20px with aqua background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.five {padding-bottom: -20px; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.five {padding-bottom: -20px; background-color: aqua;}')
    ]);
    
    const p5 = createElementWithStyle('p', {
      paddingBottom: '-20px',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have no bottom padding, since negative padding values are not allowed.  Both the content background and the normal padding should be aqua (light blue).')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p5);
    
    await snapshot();
  });
});