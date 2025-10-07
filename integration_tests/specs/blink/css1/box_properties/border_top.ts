describe('CSS1 border-top', () => {
  it('border-top with various styles', async () => {
    const p1 = createElementWithStyle('p', {
      borderTop: 'purple double 10px'
    }, [
      createText('This paragraph should have a purple, double, 10-pixel top border.')
    ]);
    
    const p2 = createElementWithStyle('p', {
      borderTop: 'purple thin solid'
    }, [
      createText('This paragraph should have a thin purple top border.')
    ]);
    
    const ul = createElement('ul', {}, [
      createElementWithStyle('li', {
        borderTop: 'black medium solid'
      }, [
        createText('This is a list item...'),
        createElement('ul', {}, [
          createElement('li', {}, [createText('...and this...')]),
          createElement('li', {}, [createText('...is a second list...')]),
          createElement('li', {}, [createText('...nested within the list item.')])
        ])
      ]),
      createElementWithStyle('li', {
        borderTop: 'black medium solid'
      }, [
        createText('This is a second list item.')
      ]),
      createElementWithStyle('li', {
        borderTop: 'black medium solid'
      }, [
        createText('Each list item in this list should have a medium-width black border at its top.')
      ])
    ]);
    
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, ul);
    
    await snapshot();
  });
});