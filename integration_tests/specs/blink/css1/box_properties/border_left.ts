describe('CSS1 border-left', () => {
  it('border-left with various styles', async () => {
    // Apply margin-left to all paragraphs
    const pStyle = {
      marginLeft: '20px'
    };
    
    const p1 = createElementWithStyle('p', {
      ...pStyle,
      borderLeft: 'purple double 10px'
    }, [
      createText('This paragraph should have a purple, double, 10-pixel left border.')
    ]);
    
    const p2 = createElementWithStyle('p', {
      ...pStyle,
      borderLeft: 'purple thin solid'
    }, [
      createText('This paragraph should have a thin purple left border.')
    ]);
    
    const ul = createElement('ul', {}, [
      createElementWithStyle('li', {
        borderLeft: 'black medium solid'
      }, [
        createText('This is a list item...'),
        createElement('ul', {}, [
          createElement('li', {}, [createText('...and this...')]),
          createElement('li', {}, [createText('...is a second list...')]),
          createElement('li', {}, [createText('...nested within the list item.')])
        ])
      ]),
      createElementWithStyle('li', {
        borderLeft: 'purple medium solid'
      }, [
        createText('This is a second list item.')
      ]),
      createElementWithStyle('li', {
        borderLeft: 'blue medium solid'
      }, [
        createText('Each list item in this \'parent\' list should have a medium-width border along its left side, in each of three colors. The first item\'s border should travel the entire height the nested list (to end near the baseline of the line "...nested within the list item."), even though the nested list does not have any border styles set.')
      ])
    ]);
    
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, ul);
    
    await snapshot();
  });
});