describe('CSS1 display', () => {
  it('p1 - display block', async () => {
    const style = createElement('style', {}, [
      createText('.one {display: block;}')
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.one {display: block;}'));
    const hr = createElement('hr', {}, []);

    const p1 = createElement('p', { className: 'one' }, [
      createText('This sentence should be a block-level element.')
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p1);

    await snapshot();
  });

  it('p2 - display inline first element', async () => {
    const style = createElement('style', {}, [
      createText('.two {display: inline;}')
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.two {display: inline;}'));
    const hr = createElement('hr', {}, []);

    const p2 = createElement('p', { className: 'two' }, [
      createText('This sentence should be part of an inline element, as are the next three.')
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);

    await snapshot();
  });

  it('p3 - display inline second element combined', async () => {
    const style = createElement('style', {}, [
      createText('.two {display: inline;}')
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.two {display: inline;}'));
    const hr = createElement('hr', {}, []);

    const p2 = createElement('p', { className: 'two' }, [
      createText('This sentence should be part of an inline element, as are the next three.')
    ]);

    const p3 = createElement('p', { className: 'two' }, [
      createText('This sentence and the next two are part of a second inline element.  They should therefore appear, along with the sentence above, to be all one paragraph which is four sentences long.  If this is not the case, then the keyword inline is being ignored.')
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);

    await snapshot();
  });

  xit('p4 - display list-item', async () => {
    const style = createElement('style', {}, [
      createText('.three {display: list-item; list-style-type: square; margin-left: 3em;}')
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.three {display: list-item; list-style-type: square; margin-left: 3em;}'));
    const hr = createElement('hr', {}, []);

    const p4 = createElement('p', { className: 'three' }, [
      createText('This sentence should be treated as a list-item, and therefore be rendered however this user agent displays list items (if list-style-type is supported, there will be a square for the item marker).  A 3em left margin has been applied in order to ensure that there is space for the list-item marker.')
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p4);

    await snapshot();
  });

  it('p5 - description before invisible test', async () => {
    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('/* No special styles for this paragraph */'));
    const hr = createElement('hr', {}, []);

    const p5 = createElement('p', {}, [
      createText('The next paragraph should be invisible (if it\'s visible, you\'ll see red text).')
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p5);

    await snapshot();
  });

  it('p6 - display none paragraph', async () => {
    const style = createElement('style', {}, [
      createText('.four {display: none; color: red;}')
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.four {display: none; color: red;}'));
    const hr = createElement('hr', {}, []);

    const p5 = createElement('p', {}, [
      createText('The next paragraph should be invisible (if it\'s visible, you\'ll see red text).')
    ]);

    const p6 = createElement('p', { className: 'four' }, [
      createText('This paragraph should be invisible.')
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p5);
    append(BODY, p6);

    await snapshot();
  });

  it('p7 - display none on span', async () => {
    const style = createElement('style', {}, [
      createText('.four {display: none; color: red;}')
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('.four {display: none; color: red;}'));
    const hr = createElement('hr', {}, []);

    const span = createElement('span', { className: 'four' }, [
      createText('fnord.')
    ]);

    const p7 = createElement('p', {}, [
      createText('There should be no text after the colon: '),
      span
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p7);

    await snapshot();
  });

  it('p8 - display block on italic element', async () => {
    const style = createElement('style', {}, [
      createText('I {display: block;}')
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const descP = createElement('p', {}, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {}, createText('I {display: block;}'));
    const hr = createElement('hr', {}, []);

    const i = createElement('i', {}, [
      createText('in this paragraph')
    ]);

    const p8 = createElement('p', {}, [
      createText('The italicized text '),
      i,
      createText(' should be a block-level element.')
    ]);

    append(BODY, descP);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p8);

    await snapshot();
  });
});
