describe('CSS1 padding-left inline', () => {
  xit('padding-left property on inline elements', async () => {
    const p1 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. However, it contains an '),
      createElementWithStyle('span', {
        paddingLeft: '25px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('one')])
      ]),
      createText(' which should result in 25-pixel left padding (which should also be a light blue) only in the '),
      createElement('strong', {}, [createText('first')]),
      createText(' line in which the inline box appears.')
    ]);

    const p2 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. However, it contains an '),
      createElementWithStyle('span', {
        paddingLeft: '-10px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')])
      ]),
      createText(' which should result in -10px left padding (which should also be a light blue) only in the '),
      createElement('strong', {}, [createText('first')]),
      createText(' line in which the inline box appears.')
    ]);

    append(BODY, p1);
    append(BODY, p2);
    await snapshot();
  });
});
