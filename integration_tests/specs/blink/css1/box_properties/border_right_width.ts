describe('CSS1 border-right-width', () => {
  it('border-right-width 0 with silver background', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-right-width: 0;}
        .one {border-right-width: 25px; border-style: solid;}
        .two {border-right-width: thick; border-style: solid;}
        .three {border-right-width: medium; border-style: solid;}
        .four {border-right-width: thin; border-style: solid;}
        .five {border-right-width: 100px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-right-width: 0;}
.one {border-right-width: 25px; border-style: solid;}
.two {border-right-width: thick; border-style: solid;}
.three {border-right-width: medium; border-style: solid;}
.four {border-right-width: thin; border-style: solid;}
.five {border-right-width: 100px;}`)
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

  it('border-right-width 25px solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-right-width: 0;}
        .one {border-right-width: 25px; border-style: solid;}
        .two {border-right-width: thick; border-style: solid;}
        .three {border-right-width: medium; border-style: solid;}
        .four {border-right-width: thin; border-style: solid;}
        .five {border-right-width: 100px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-right-width: 0;}
.one {border-right-width: 25px; border-style: solid;}
.two {border-right-width: thick; border-style: solid;}
.three {border-right-width: medium; border-style: solid;}
.four {border-right-width: thin; border-style: solid;}
.five {border-right-width: 100px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'one'
    }, [
      createText('This element should have a right border width of 25 pixels, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-right-width thick solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-right-width: 0;}
        .one {border-right-width: 25px; border-style: solid;}
        .two {border-right-width: thick; border-style: solid;}
        .three {border-right-width: medium; border-style: solid;}
        .four {border-right-width: thin; border-style: solid;}
        .five {border-right-width: 100px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-right-width: 0;}
.one {border-right-width: 25px; border-style: solid;}
.two {border-right-width: thick; border-style: solid;}
.three {border-right-width: medium; border-style: solid;}
.four {border-right-width: thin; border-style: solid;}
.five {border-right-width: 100px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'two'
    }, [
      createText('This element should have a thick right border width, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-right-width medium solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-right-width: 0;}
        .one {border-right-width: 25px; border-style: solid;}
        .two {border-right-width: thick; border-style: solid;}
        .three {border-right-width: medium; border-style: solid;}
        .four {border-right-width: thin; border-style: solid;}
        .five {border-right-width: 100px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-right-width: 0;}
.one {border-right-width: 25px; border-style: solid;}
.two {border-right-width: thick; border-style: solid;}
.three {border-right-width: medium; border-style: solid;}
.four {border-right-width: thin; border-style: solid;}
.five {border-right-width: 100px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'three'
    }, [
      createText('This element should have a medium right border width, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-right-width thin solid', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-right-width: 0;}
        .one {border-right-width: 25px; border-style: solid;}
        .two {border-right-width: thick; border-style: solid;}
        .three {border-right-width: medium; border-style: solid;}
        .four {border-right-width: thin; border-style: solid;}
        .five {border-right-width: 100px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-right-width: 0;}
.one {border-right-width: 25px; border-style: solid;}
.two {border-right-width: thick; border-style: solid;}
.three {border-right-width: medium; border-style: solid;}
.four {border-right-width: thin; border-style: solid;}
.five {border-right-width: 100px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'four'
    }, [
      createText('This element should have a thin right border width, which will be more obvious if the element is more than one line long.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p);

    await snapshot();
  });

  it('border-right-width 100px without border-style', async () => {
    const style = createElement('style', {}, [
      createText(`
        .zero {background-color: silver; border-right-width: 0;}
        .one {border-right-width: 25px; border-style: solid;}
        .two {border-right-width: thick; border-style: solid;}
        .three {border-right-width: medium; border-style: solid;}
        .four {border-right-width: thin; border-style: solid;}
        .five {border-right-width: 100px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.zero {background-color: silver; border-right-width: 0;}
.one {border-right-width: 25px; border-style: solid;}
.two {border-right-width: thick; border-style: solid;}
.three {border-right-width: medium; border-style: solid;}
.four {border-right-width: thin; border-style: solid;}
.five {border-right-width: 100px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p = createElement('p', {
      className: 'five'
    }, [
      createText('This element should have no border and no extra "padding" on its right side, as no '),
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