describe('CSS1 border-bottom', () => {
  it('border-bottom with various styles', async () => {
    const p1 = createElementWithStyle('p', {
      borderBottom: 'purple double 10px'
    }, [
      createText('This paragraph should have a purple, double, 10-pixel bottom border.')
    ]);
    
    const p2 = createElementWithStyle('p', {
      borderBottom: 'purple thin solid'
    }, [
      createText('This paragraph should have a thin purple bottom border.')
    ]);
    
    const ul = createElement('ul', {}, [
      createElementWithStyle('li', {
        borderBottom: 'black medium solid'
      }, [
        createText('This is a list item...'),
        createElement('ul', {}, [
          createElement('li', {}, [createText('...and this...')]),
          createElement('li', {}, [createText('...is a second list...')]),
          createElement('li', {}, [createText('...nested within the list item.')])
        ])
      ]),
      createElementWithStyle('li', {
        borderBottom: 'black medium solid'
      }, [
        createText('This is a second list item.')
      ]),
      createElementWithStyle('li', {
        borderBottom: 'black medium solid'
      }, [
        createText('Each list item in this list should have a medium-width black border at its bottom, which for the first item means that it should appear '),
        createElement('em', {}, [createText('beneath')]),
        createText(' the nested list (below the line "...nested within the list item.").')
      ])
    ]);
    
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, ul);
    
    await snapshot();
  });
});