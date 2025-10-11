describe('CSS1 border-style', () => {
  it('border-style dotted', async () => {
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