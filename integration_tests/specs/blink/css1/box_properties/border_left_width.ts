describe('CSS1 border-left-width', () => {
  it('border-left-width 0 with silver background', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-left-width: 0;}
        .one {border-left-width: 50px; border-style: solid;}
        .two {border-left-width: thick; border-style: solid;}
        .three {border-left-width: medium; border-style: solid;}
        .four {border-left-width: thin; border-style: solid;}
        .five {border-left-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-left-width: 0;}
.one {border-left-width: 50px; border-style: solid;}
.two {border-left-width: thick; border-style: solid;}
.three {border-left-width: medium; border-style: solid;}
.four {border-left-width: thin; border-style: solid;}
.five {border-left-width: 25px;}`)
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

  it('border-left-width 50px solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-left-width: 0;}
        .one {border-left-width: 50px; border-style: solid;}
        .two {border-left-width: thick; border-style: solid;}
        .three {border-left-width: medium; border-style: solid;}
        .four {border-left-width: thin; border-style: solid;}
        .five {border-left-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-left-width: 0;}
.one {border-left-width: 50px; border-style: solid;}
.two {border-left-width: thick; border-style: solid;}
.three {border-left-width: medium; border-style: solid;}
.four {border-left-width: thin; border-style: solid;}
.five {border-left-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'one'
    }, [
      createText('This element should have a left border width of 50 pixels, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-left-width thick solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-left-width: 0;}
        .one {border-left-width: 50px; border-style: solid;}
        .two {border-left-width: thick; border-style: solid;}
        .three {border-left-width: medium; border-style: solid;}
        .four {border-left-width: thin; border-style: solid;}
        .five {border-left-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-left-width: 0;}
.one {border-left-width: 50px; border-style: solid;}
.two {border-left-width: thick; border-style: solid;}
.three {border-left-width: medium; border-style: solid;}
.four {border-left-width: thin; border-style: solid;}
.five {border-left-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'two'
    }, [
      createText('This element should have a thick left border width, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-left-width medium solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-left-width: 0;}
        .one {border-left-width: 50px; border-style: solid;}
        .two {border-left-width: thick; border-style: solid;}
        .three {border-left-width: medium; border-style: solid;}
        .four {border-left-width: thin; border-style: solid;}
        .five {border-left-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-left-width: 0;}
.one {border-left-width: 50px; border-style: solid;}
.two {border-left-width: thick; border-style: solid;}
.three {border-left-width: medium; border-style: solid;}
.four {border-left-width: thin; border-style: solid;}
.five {border-left-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'three'
    }, [
      createText('This element should have a medium left border width, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-left-width thin solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-left-width: 0;}
        .one {border-left-width: 50px; border-style: solid;}
        .two {border-left-width: thick; border-style: solid;}
        .three {border-left-width: medium; border-style: solid;}
        .four {border-left-width: thin; border-style: solid;}
        .five {border-left-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-left-width: 0;}
.one {border-left-width: 50px; border-style: solid;}
.two {border-left-width: thick; border-style: solid;}
.three {border-left-width: medium; border-style: solid;}
.four {border-left-width: thin; border-style: solid;}
.five {border-left-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'four'
    }, [
      createText('This element should have a thin left border width, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-left-width 25px without border-style', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-left-width: 0;}
        .one {border-left-width: 50px; border-style: solid;}
        .two {border-left-width: thick; border-style: solid;}
        .three {border-left-width: medium; border-style: solid;}
        .four {border-left-width: thin; border-style: solid;}
        .five {border-left-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-left-width: 0;}
.one {border-left-width: 50px; border-style: solid;}
.two {border-left-width: thick; border-style: solid;}
.three {border-left-width: medium; border-style: solid;}
.four {border-left-width: thin; border-style: solid;}
.five {border-left-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'five'
    }, [
      createText('This element should have no border and no extra "padding" on its left side, as no '),
      createElement('code', {}, [createText('border-style')]),
      createText(' was set.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });
});