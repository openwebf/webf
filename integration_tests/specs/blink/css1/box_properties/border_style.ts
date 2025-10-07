describe('CSS1 border-style', () => {
  xit('border-style dotted', async () => {
    const style = createElement('style', {}, [
      createText(`
        .one {border-style: dotted; border-color: black; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.one {border-style: dotted; border-color: black; border-width: thick;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'one'
    }, [
      createText('This paragraph should have a thick black dotted border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-style dashed', async () => {
    const style = createElement('style', {}, [
      createText(`
        .two {border-style: dashed; border-color: black; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.two {border-style: dashed; border-color: black; border-width: thick;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'two'
    }, [
      createText('This paragraph should have a thick black dashed border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-style solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .three {border-style: solid; border-color: black; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.three {border-style: solid; border-color: black; border-width: thick;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'three'
    }, [
      createText('This paragraph should have a thick black solid border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  xit('border-style double', async () => {
    const style = createElement('style', {}, [
      createText(`
        .four {border-style: double; border-color: black; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .four {border-style: double; border-color: black; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'four'
    }, [
      createText('This paragraph should have a thick black double border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  xit('border-style groove', async () => {
    const style = createElement('style', {}, [
      createText(`
        .five {border-style: groove; border-color: olive; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .five {border-style: groove; border-color: olive; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'five'
    }, [
      createText('This paragraph should have a thick olive groove border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  xit('border-style ridge', async () => {
    const style = createElement('style', {}, [
      createText(`
        .six {border-style: ridge; border-color: olive; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .six {border-style: ridge; border-color: olive; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'six'
    }, [
      createText('This paragraph should have a thick olive ridge border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  xit('border-style inset', async () => {
    const style = createElement('style', {}, [
      createText(`
        .seven {border-style: inset; border-color: olive; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .seven {border-style: inset; border-color: olive; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'seven'
    }, [
      createText('This paragraph should have a thick olive inset border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  xit('border-style outset', async () => {
    const style = createElement('style', {}, [
      createText(`
        .eight {border-style: outset; border-color: olive; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .eight {border-style: outset; border-color: olive; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'eight'
    }, [
      createText('This paragraph should have a thick olive outset border all the way around.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  xit('border-style double groove combination', async () => {
    const style = createElement('style', {}, [
      createText(`
        .nine {border-style: double groove; border-color: purple; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .nine {border-style: double groove; border-color: purple; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'nine'
    }, [
      createText('This paragraph should have thick double top and bottom borders, and thick grooved side borders. The color of all four sides should be based on purple.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  xit('border-style four value combination', async () => {
    const style = createElement('style', {}, [
      createText(`
        .ten {border-style: double groove ridge inset; border-color: purple; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .ten {border-style: double groove ridge inset; border-color: purple; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'ten'
    }, [
      createText('This paragraph should have, in clockwise order from the top, a double, grooved, ridged, and inset thick border. The color of all four sides should be based on purple.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-style none', async () => {
    const style = createElement('style', {}, [
      createText(`
        .eleven {border-style: none; border-color: red; border-width: thick;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`
        .eleven {border-style: none; border-color: red; border-width: thick;}
      `)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'eleven'
    }, [
      createText('This paragraph should have no border at all.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });
});