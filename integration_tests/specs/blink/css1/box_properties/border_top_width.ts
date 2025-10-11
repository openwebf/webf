describe('CSS1 border-top-width', () => {
  it('border-top-width 0 with silver background', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-top-width: 0;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'zero'
    }, [
      createText('This element has a class of zero.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-top-width 25px solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.one {border-top-width: 25px; border-style: solid;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'one'
    }, [
      createText('This paragraph should have a top border width of 25 pixels.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-top-width thick solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.two {border-top-width: thick; border-style: solid;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'two'
    }, [
      createText('This paragraph should have a thick top border width.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-top-width medium solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.three {border-top-width: medium; border-style: solid;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'three'
    }, [
      createText('This paragraph should have a medium top border width.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-top-width thin solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.four {border-top-width: thin; border-style: solid;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'four'
    }, [
      createText('This paragraph should have a thin top border width.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-top-width 25px without border-style', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.five {border-top-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'five'
    }, [
      createText('This paragraph should have no border and no extra "padding" on its top side, as no '),
      createElement('code', {}, [createText('border-style')]),
      createText(' was set.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-top-width with border-style support note', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-top-width: 0;}
.one {border-top-width: 25px; border-style: solid;}
.two {border-top-width: thick; border-style: solid;}
.three {border-top-width: medium; border-style: solid;}
.four {border-top-width: thin; border-style: solid;}
.five {border-top-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {}, [
      createText('(These will only work if '),
      createElement('code', {}, [createText('border-style')]),
      createText(' is supported.)')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-top-width all values combined', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-top-width: 0;}
        .one {border-top-width: 25px; border-style: solid;}
        .two {border-top-width: thick; border-style: solid;}
        .three {border-top-width: medium; border-style: solid;}
        .four {border-top-width: thin; border-style: solid;}
        .five {border-top-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-top-width: 0;}
.one {border-top-width: 25px; border-style: solid;}
.two {border-top-width: thick; border-style: solid;}
.three {border-top-width: medium; border-style: solid;}
.four {border-top-width: thin; border-style: solid;}
.five {border-top-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p2 = createElement('p', {}, [
      createText('(These will only work if '),
      createElement('code', {}, [createText('border-style')]),
      createText(' is supported.)')
    ]);

    const p3 = createElement('p', {
      className: 'zero'
    }, [
      createText('This element has a class of zero.')
    ]);

    const p4 = createElement('p', {
      className: 'one'
    }, [
      createText('This paragraph should have a top border width of 25 pixels.')
    ]);

    const p5 = createElement('p', {
      className: 'two'
    }, [
      createText('This paragraph should have a thick top border width.')
    ]);

    const p6 = createElement('p', {
      className: 'three'
    }, [
      createText('This paragraph should have a medium top border width.')
    ]);

    const p7 = createElement('p', {
      className: 'four'
    }, [
      createText('This paragraph should have a thin top border width.')
    ]);

    const p8 = createElement('p', {
      className: 'five'
    }, [
      createText('This paragraph should have no border and no extra "padding" on its top side, as no '),
      createElement('code', {}, [createText('border-style')]),
      createText(' was set.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, p5);
    append(BODY, p6);
    append(BODY, p7);
    append(BODY, p8);

    await snapshot();
  });
});