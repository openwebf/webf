describe('CSS1 padding inline', () => {
  it('padding shorthand property on inline elements', async () => {
    const p1 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      padding: '0'
    }, [
      createText('This element has a class of zero.')
    ]);

    const p2 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        padding: '25px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('one')]),
        createText(', giving it an aqua background and a 25px padding')
      ]),
      createText('. Padding on inline elements does not affect line-height calculations, so all lines in this element should have the same line-height. There may be implementation-specific limits on how much of the padding the user agent is able to display above and below each line. However, there should be at least 25px of padding to the left side of the inline box in the first line it appears, and 25px of padding to the right side of the inline element box in the last line where it appears.')
    ]);

    const p3 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      padding: '0'
    }, [
      createText('This element has a class of zero.')
    ]);

    const p4 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        padding: '-10px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')]),
        createText(', giving it an aqua background and no padding, since negative padding values are not allowed')
      ]),
      createText('. Padding on inline elements does not affect line-height calculations, so all lines in this element should have the same line-height.')
    ]);

    const p5 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      padding: '0'
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
