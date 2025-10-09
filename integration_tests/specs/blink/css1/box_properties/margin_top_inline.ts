describe('CSS1 margin-top inline', () => {
  it('margin-top property on inline elements', async () => {
    const p1 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        marginTop: '25px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('one')]),
        createText(', giving it an aqua background and a 25px top margin')
      ]),
      createText('. Margins on inline elements do not affect line-height calculations, so all lines in this element should have the same line-height.')
    ]);

    const p2 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. It contains an '),
      createElementWithStyle('span', {
        marginTop: '-10px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')]),
        createText(', giving the inline element an aqua background and a -10px top margin')
      ]),
      createText('. Margins on inline elements do not affect line-height calculations, so all lines in this element should have the same line-height.')
    ]);

    append(BODY, p1);
    append(BODY, p2);
    await snapshot();
  });
});
