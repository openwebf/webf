describe('CSS1 font-size', () => {
  it('font-size unstyled default', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('/* No font-size specified - browser default */'));
    const hr = createElement('hr', {}, []);
    
    const unstyled = createElementWithStyle('p', {
      margin: '10px 0'
    }, [
      createText('This paragraph element is unstyled, so the size of the font in this element is the default size for this user agent.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, unstyled);

    await snapshot();
  });

  it('font-size medium', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: medium;}'));
    const hr = createElement('hr', {}, []);
    
    const one = createElementWithStyle('p', {
      fontSize: 'medium',
      margin: '10px 0'
    }, [
      createText('This sentence has been set to medium, which may or may not be the same size as unstyled text.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, one);

    await snapshot();
  });

  it('font-size larger', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: larger;}'));
    const hr = createElement('hr', {}, []);
    
    const two = createElementWithStyle('p', {
      fontSize: 'larger',
      margin: '10px 0'
    }, [
      createText('This sentence should be larger than unstyled text.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, two);

    await snapshot();
  });

  it('font-size smaller', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: smaller;}'));
    const hr = createElement('hr', {}, []);
    
    const three = createElementWithStyle('p', {
      fontSize: 'smaller',
      margin: '10px 0'
    }, [
      createText('This sentence should be smaller than unstyled text.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, three);

    await snapshot();
  });

  it('font-size xx-small with medium span', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: xx-small;} span {font-size: medium;}'));
    const hr = createElement('hr', {}, []);
    
    const fourSpan = createElementWithStyle('span', {
      fontSize: 'medium'
    }, [
      createText('medium')
    ]);
    
    const four = createElementWithStyle('p', {
      fontSize: 'xx-small',
      margin: '10px 0'
    }, [
      createText('This sentence should be very small, but the last word in the sentence should be '),
      fourSpan,
      createText('.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, four);

    await snapshot();
  });

  it('font-size x-small with medium span', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: x-small;} span {font-size: medium;}'));
    const hr = createElement('hr', {}, []);
    
    const fiveSpan = createElementWithStyle('span', {
      fontSize: 'medium'
    }, [
      createText('medium')
    ]);
    
    const five = createElementWithStyle('p', {
      fontSize: 'x-small',
      margin: '10px 0'
    }, [
      createText('This sentence should be rather small, but the last word in the sentence should be '),
      fiveSpan,
      createText('.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, five);

    await snapshot();
  });

  it('font-size small with medium span', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: small;} span {font-size: medium;}'));
    const hr = createElement('hr', {}, []);
    
    const sixSpan = createElementWithStyle('span', {
      fontSize: 'medium'
    }, [
      createText('medium')
    ]);
    
    const six = createElementWithStyle('p', {
      fontSize: 'small',
      margin: '10px 0'
    }, [
      createText('This sentence should be small, but the last word in the sentence should be '),
      sixSpan,
      createText('.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, six);

    await snapshot();
  });

  it('font-size large with medium span', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: large;} span {font-size: medium;}'));
    const hr = createElement('hr', {}, []);
    
    const sevenSpan = createElementWithStyle('span', {
      fontSize: 'medium'
    }, [
      createText('medium')
    ]);
    
    const seven = createElementWithStyle('p', {
      fontSize: 'large',
      margin: '10px 0'
    }, [
      createText('This sentence should be large, but the last word in the sentence should be '),
      sevenSpan,
      createText('.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, seven);

    await snapshot();
  });

  it('font-size x-large with medium span', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: x-large;} span {font-size: medium;}'));
    const hr = createElement('hr', {}, []);
    
    const eightSpan = createElementWithStyle('span', {
      fontSize: 'medium'
    }, [
      createText('medium')
    ]);
    
    const eight = createElementWithStyle('p', {
      fontSize: 'x-large',
      margin: '10px 0'
    }, [
      createText('This sentence should be rather large, but the last word in the sentence should be '),
      eightSpan,
      createText('.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, eight);

    await snapshot();
  });

  it('font-size xx-large with medium span', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: xx-large;} span {font-size: medium;}'));
    const hr = createElement('hr', {}, []);
    
    const nineSpan = createElementWithStyle('span', {
      fontSize: 'medium'
    }, [
      createText('medium')
    ]);
    
    const nine = createElementWithStyle('p', {
      fontSize: 'xx-large',
      margin: '10px 0'
    }, [
      createText('This sentence should be very large, but the last word in the sentence should be '),
      nineSpan,
      createText('.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, nine);

    await snapshot();
  });

  it('font-size 0.5in', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 0.5in;}'));
    const hr = createElement('hr', {}, []);
    
    const a = createElementWithStyle('p', {
      fontSize: '0.5in',
      margin: '10px 0'
    }, [
      createText('This sentence should be half an inch tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, a);

    await snapshot();
  });

  it('font-size 1cm', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 1cm;}'));
    const hr = createElement('hr', {}, []);
    
    const b = createElementWithStyle('p', {
      fontSize: '1cm',
      margin: '10px 0'
    }, [
      createText('This sentence should be one centimeter tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, b);

    await snapshot();
  });

  it('font-size 10mm', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 10mm;}'));
    const hr = createElement('hr', {}, []);
    
    const c = createElementWithStyle('p', {
      fontSize: '10mm',
      margin: '10px 0'
    }, [
      createText('This sentence should be ten millimeters tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, c);

    await snapshot();
  });

  it('font-size 18pt', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 18pt;}'));
    const hr = createElement('hr', {}, []);
    
    const d = createElementWithStyle('p', {
      fontSize: '18pt',
      margin: '10px 0'
    }, [
      createText('This sentence should be eighteen points tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, d);

    await snapshot();
  });

  it('font-size 1.5pc', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 1.5pc;}'));
    const hr = createElement('hr', {}, []);
    
    const e = createElementWithStyle('p', {
      fontSize: '1.5pc',
      margin: '10px 0'
    }, [
      createText('This sentence should be one and one half picas tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, e);

    await snapshot();
  });

  it('font-size 2em', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 2em;}'));
    const hr = createElement('hr', {}, []);
    
    const f = createElementWithStyle('p', {
      fontSize: '2em',
      margin: '10px 0'
    }, [
      createText('This sentence should be two em tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, f);

    await snapshot();
  });

  it('font-size 3ex', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 3ex;}'));
    const hr = createElement('hr', {}, []);
    
    const g = createElementWithStyle('p', {
      fontSize: '3ex',
      margin: '10px 0'
    }, [
      createText('This sentence should be three ex tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, g);

    await snapshot();
  });

  it('font-size 25px', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 25px;}'));
    const hr = createElement('hr', {}, []);
    
    const h = createElementWithStyle('p', {
      fontSize: '25px',
      margin: '10px 0'
    }, [
      createText('This sentence should be twenty-five pixels tall.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, h);

    await snapshot();
  });

  it('font-size 200%', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: 200%;}'));
    const hr = createElement('hr', {}, []);
    
    const i = createElementWithStyle('p', {
      fontSize: '200%',
      margin: '10px 0'
    }, [
      createText('This sentence should be twice normal size.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, i);

    await snapshot();
  });

  it('font-size negative value ignored', async () => {
    const p = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('p {font-size: -0.5in;}'));
    const hr = createElement('hr', {}, []);
    
    const j = createElementWithStyle('p', {
      fontSize: '-0.5in',
      margin: '10px 0'
    }, [
      createText('This sentence should be normal size, since no negative values are allowed and therefore should be ignored.')
    ]);

    append(BODY, p);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, j);

    await snapshot();
  });
});