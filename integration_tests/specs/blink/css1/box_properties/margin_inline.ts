describe('CSS1 margin inline', () => {
  xit('margin shorthand property on inline elements', async () => {
    const p1 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      margin: '0'
    }, [
      createText('This element has a class of zero.')
    ]);

    const p2 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        margin: '25px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('one')]),
        createText(', giving it an aqua background and a 25px margin')
      ]),
      createText('. Margins on inline elements does not affect line-height calculations, so all lines in this element should have the same line-height. However, there should be a 25px margin to the left side of the inline box in the first line it appears, and a 25px margin to the right side of the inline element box in the last line where it appears.')
    ]);

    const p3 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      margin: '0'
    }, [
      createText('This element has a class of zero.')
    ]);

    const p4 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        margin: '-10px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')]),
        createText(', giving it an aqua background and a -10px margin')
      ]),
      createText('. Margins on inline elements does not affect line-height calculations, so all lines in this element should have the same line-height. However, there should be a -10px margin to the left side of the inline box in the first line it appears, and a -10px margin to the right side of the inline element box in the last line where it appears.')
    ]);

    const p5 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      margin: '0'
    }, [
      createText('This element has a class of zero.')
    ]);

    append(BODY, p1);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, p5);
    await snapshot();
  });
});
