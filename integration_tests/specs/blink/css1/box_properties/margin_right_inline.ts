describe('CSS1 margin-right inline', () => {
  xit('margin-right property on inline elements', async () => {
    const p1 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. However, it contains an '),
      createElementWithStyle('span', {
        marginRight: '25px',
        textAlign: 'right',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('one')])
      ]),
      createText(', which should result in 25-pixel right margin only in the '),
      createElement('strong', {}, [createText('last')]),
      createText(' line in which the inline box appears.')
    ]);

    const p2 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. However, it contains an '),
      createElementWithStyle('span', {
        marginRight: '-10px',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')])
      ]),
      createText(', which should result in -10px right margin only in the '),
      createElement('strong', {}, [createText('last')]),
      createText(' line in which the inline box appears.')
    ]);

    append(BODY, p1);
    append(BODY, p2);
    await snapshot();
  });
});
