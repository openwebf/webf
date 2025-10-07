describe('CSS1 border-right-width inline', () => {
  xit('border-right-width with inline elements', async () => {
    const style = createElement('style', {}, [
      createText(`
        .one {border-right-width: 25px; border-style: solid;}
        .two {border-right-width: thin; border-style: solid;}
        .three {border-right-width: 25px;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElement('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`.one {border-right-width: 25px; border-style: solid;}
.two {border-right-width: thin; border-style: solid;}
.three {border-right-width: 25px;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p2 = createElement('p', {
      className: 'one'
    }, [
      createText('This element has a class of '),
      createElement('tt', {}, [createText('one')]),
      createText('.  However, it contains an '),
      createElement('span', {
        className: 'two'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')])
      ]),
      createText(', which should result in a thin solid border on the right side of the '),
      createElement('strong', {}, [createText('last')]),
      createText(' box of the inline element (and the UA\'s default border on the other three sides).  There is also an '),
      createElement('span', {
        className: 'three'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('three')])
      ]),
      createText(', which should have no right border width or visible border because no border style was set.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);

    await snapshot();
  });
});