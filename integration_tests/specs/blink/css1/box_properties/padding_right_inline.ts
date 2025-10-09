describe('CSS1 padding-right inline', () => {
  it('padding-right property on inline elements', async () => {
    const p1 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. However, it contains an '),
      createElementWithStyle('span', {
        paddingRight: '25px',
        textAlign: 'right',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('one')])
      ]),
      createText(', which should result in 25-pixel right padding (which should also be light blue) only in the '),
      createElement('strong', {}, [createText('last')]),
      createText(' line in which the inline box appears.')
    ]);

    const p2 = createElementWithStyle('p', {
      backgroundColor: 'gray'
    }, [
      createText('This element is unstyled save for a background color of gray. However, it contains an '),
      createElementWithStyle('span', {
        paddingRight: '-10px',
        textAlign: 'right',
        backgroundColor: 'aqua'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')])
      ]),
      createText(', which should result in no right padding, since negative padding values are not allowed, in the '),
      createElement('strong', {}, [createText('last')]),
      createText(' line in which the inline box appears.')
    ]);

    append(BODY, p1);
    append(BODY, p2);
    await snapshot();
  });
});
