describe('CSS1 border-width inline', () => {
  it('border-width property on inline elements', async () => {
    const p = createElementWithStyle('p', {
      borderWidth: '25px',
      borderStyle: 'solid'
    }, [
      createText('This element has a class of '),
      createElement('tt', {}, [createText('one')]),
      createText('. However, it contains an '),
      createElementWithStyle('span', {
        borderWidth: 'thin',
        borderStyle: 'solid'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('two')])
      ]),
      createText(', which should result in a thin solid border on each side of each box in the inline element. There is also an '),
      createElementWithStyle('span', {
        borderWidth: '25px'
      }, [
        createText('inline element of class '),
        createElement('tt', {}, [createText('three')])
      ]),
      createText(', which should have no border width because no border style was set.')
    ]);

    append(BODY, p);
    await snapshot();
  });
});