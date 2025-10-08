describe('CSS1 padding-bottom inline', () => {
  xit('padding-bottom property on inline elements', async () => {
    const p1 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        paddingBottom: '25px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('one')]),
        createText(', giving it an aqua background and a 25px bottom padding')
      ]),
      createText('. Padding on inline elements does not affect line-height calculations, so all lines in this element should have the same line-height. There may be implementation-specific limits on how much of the padding the user agent is able to display.')
    ]);

    const p2 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        paddingBottom: '-10px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')]),
        createText(', giving it an aqua background and no bottom padding, since negative padding values are not allowed')
      ]),
      createText('. Padding on inline elements does not affect line-height calculations, so all lines in this element should have the same line-height.')
    ]);

    append(BODY, p1);
    append(BODY, p2);
    await snapshot();
  });
});
