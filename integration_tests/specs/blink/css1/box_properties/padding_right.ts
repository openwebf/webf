describe('CSS1 padding-right', () => {
  it('padding-right 0 with silver background', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.zero {background-color: silver; padding-right: 0;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.zero {background-color: silver; padding-right: 0;}')
    ]);
    
    const p0 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      paddingRight: '0'
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

  it('padding-right 0.5in with aqua background and text-align right', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.one {padding-right: 0.5in; text-align: right; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.one {padding-right: 0.5in; text-align: right; background-color: aqua;}')
    ]);
    
    const p1 = createElementWithStyle('p', {
      paddingRight: '0.5in',
      textAlign: 'right',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a right padding of half an inch, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).  The text has been right-aligned in order to make the right padding easier to see.')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p1);
    
    await snapshot();
  });

  it('padding-right 25px with aqua background and text-align right', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.two {padding-right: 25px; text-align: right; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.two {padding-right: 25px; text-align: right; background-color: aqua;}')
    ]);
    
    const p2 = createElementWithStyle('p', {
      paddingRight: '25px',
      textAlign: 'right',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a right padding of 25 pixels, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).  The text has been right-aligned in order to make the right padding easier to see.')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    
    await snapshot();
  });

  it('padding-right 5em with aqua background and text-align right', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.three {padding-right: 5em; text-align: right; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.three {padding-right: 5em; text-align: right; background-color: aqua;}')
    ]);
    
    const p3 = createElementWithStyle('p', {
      paddingRight: '5em',
      textAlign: 'right',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a right padding of 5 em, which will require extra text in order to test.  Both the content background and the padding should be aqua (light blue).  The text has been right-aligned in order to make the right padding easier to see.')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p3);
    
    await snapshot();
  });

  it('padding-right 25% with aqua background and text-align right', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.four {padding-right: 25%; text-align: right; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.four {padding-right: 25%; text-align: right; background-color: aqua;}')
    ]);
    
    const p4 = createElementWithStyle('p', {
      paddingRight: '25%',
      textAlign: 'right',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have a right padding of 25%, which is calculated with respect to the width of the parent element.  Both the content background and the padding should be aqua (light blue).  The text has been right-aligned in order to make the right padding easier to see.')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p4);
    
    await snapshot();
  });

  it('padding-right 25px on ul with list items', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.two {padding-right: 25px; text-align: right; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.two {padding-right: 25px; text-align: right; background-color: aqua;}')
    ]);
    
    const li1 = createElement('li', {}, [
      createText('The right padding on this unordered list has been set to 25 pixels, which will require some extra text in order to test.')
    ]);
    
    const li2 = createElementWithStyle('li', {
      paddingRight: '25px',
      textAlign: 'right',
      backgroundColor: 'white'
    }, [
      createText('This list item has a right padding of 25 pixels, which will appear to the left of the gray padding of the UL element.')
    ]);
    
    const ul = createElementWithStyle('ul', {
      paddingRight: '25px',
      textAlign: 'right',
      backgroundColor: 'gray'
    }, [
      li1,
      li2
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, ul);
    
    await snapshot();
  });

  it('padding-right -20px with aqua background and text-align right', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.five {padding-right: -20px; text-align: right; background-color: aqua;}'));
    const hr = createElement('hr', {}, []);
    
    const style = createElement('style', {}, [
      createText('.five {padding-right: -20px; text-align: right; background-color: aqua;}')
    ]);
    
    const p5 = createElementWithStyle('p', {
      paddingRight: '-20px',
      textAlign: 'right',
      backgroundColor: 'aqua'
    }, [
      createText('This element should have no right padding, since negative padding values are not allowed.  Both the content background and the normal padding should be aqua (light blue).  The text has been right-aligned in order to make the lack of right padding easier to see.')
    ]);
    
    append(BODY, style);
    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p5);
    
    await snapshot();
  });
});