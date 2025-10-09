describe('CSS1 font-weight', () => {
  it('font-weight bold', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: bold;}'));
    const hr = createElement('hr', {}, []);
    
    const one = createElementWithStyle('p', {
      fontWeight: 'bold',
      margin: '10px 0'
    }, [
      createText('This sentence should be bold.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, one);

    await snapshot();
  });

  it('font-weight bolder', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: bolder;}'));
    const hr = createElement('hr', {}, []);
    
    const two = createElementWithStyle('p', {
      fontWeight: 'bolder',
      margin: '10px 0'
    }, [
      createText('This sentence should be bolder than normal.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, two);

    await snapshot();
  });

  it('font-weight h4 default', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('/* h4 with default font-weight */'));
    const hr = createElement('hr', {}, []);
    
    const h4 = createElementWithStyle('h4', {
      margin: '10px 0'
    }, [
      createText('This is a heading-4.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, h4);

    await snapshot();
  });

  it('font-weight h4 bolder', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('h4 {font-weight: bolder;}'));
    const hr = createElement('hr', {}, []);
    
    const h4Bolder = createElementWithStyle('h4', {
      fontWeight: 'bolder',
      margin: '10px 0'
    }, [
      createText('This is a bolder heading-4.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, h4Bolder);

    await snapshot();
  });

  it('font-weight b lighter', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('b {font-weight: lighter;}'));
    const hr = createElement('hr', {}, []);
    
    const b = createElementWithStyle('b', {
      fontWeight: 'lighter'
    }, [
      createText('This sentence should be normal (boldface made lighter).')
    ]);
    
    const boldLighter = createElementWithStyle('p', {
      margin: '10px 0'
    }, [b]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, boldLighter);

    await snapshot();
  });

  it('font-weight 100', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: 100;}'));
    const hr = createElement('hr', {}, []);
    
    const four = createElementWithStyle('p', {
      fontWeight: '100',
      margin: '10px 0'
    }, [
      createText('This sentence should be weight 100.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, four);

    await snapshot();
  });

  it('font-weight 300', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: 300;}'));
    const hr = createElement('hr', {}, []);
    
    const five = createElementWithStyle('p', {
      fontWeight: '300',
      margin: '10px 0'
    }, [
      createText('This sentence should be weight 300.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, five);

    await snapshot();
  });

  it('font-weight 500', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: 500;}'));
    const hr = createElement('hr', {}, []);
    
    const six = createElementWithStyle('p', {
      fontWeight: '500',
      margin: '10px 0'
    }, [
      createText('This sentence should be weight 500.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, six);

    await snapshot();
  });

  it('font-weight 700', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: 700;}'));
    const hr = createElement('hr', {}, []);
    
    const seven = createElementWithStyle('p', {
      fontWeight: '700',
      margin: '10px 0'
    }, [
      createText('This sentence should be weight 700.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, seven);

    await snapshot();
  });

  it('font-weight 900', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: 900;}'));
    const hr = createElement('hr', {}, []);
    
    const eight = createElementWithStyle('p', {
      fontWeight: '900',
      margin: '10px 0'
    }, [
      createText('This sentence should be weight 900.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, eight);

    await snapshot();
  });

  it('font-weight bold with normal span', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-weight: bold;} span {font-weight: normal;}'));
    const hr = createElement('hr', {}, []);
    
    const nineSpan = createElementWithStyle('span', {
      fontWeight: 'normal'
    }, [
      createText('normal')
    ]);
    
    const nine = createElementWithStyle('p', {
      fontWeight: 'bold',
      margin: '10px 0'
    }, [
      createText('This sentence should be bold, but the last word in the sentence should be '),
      nineSpan,
      createText('.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, nine);

    await snapshot();
  });
});