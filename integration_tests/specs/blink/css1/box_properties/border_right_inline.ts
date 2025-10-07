describe('CSS1 border-right inline', () => {
  it('border-right property on inline elements and list items', async () => {
    const note = createElement('p', {}, [
      createText('Note that all table cells on this page should have a two-pixel solid green border along their right sides. This border applies only to the cells, not the rows which contain them.')
    ]);

    const p1 = createElementWithStyle('p', {
      borderRight: 'purple double 10px'
    }, [
      createText('This paragraph should have a purple, double, 10-pixel right border.')
    ]);

    const p2 = createElementWithStyle('p', {
      borderRight: 'purple thin solid'
    }, [
      createText('This paragraph should have a thin purple right border.')
    ]);

    const ul = createElement('ul', {}, [
      createElement('li', {}, [
        createElementWithStyle('span', {
          borderRight: 'black medium solid'
        }, [createText('This is a list item...')]),
        createElement('ul', {}, [
          createElement('li', {}, [createText('...and this...')]),
          createElement('li', {}, [createText('...is a second list...')]),
          createElement('li', {}, [createText('...nested within the list item.')])
        ])
      ]),
      createElementWithStyle('li', {
        borderRight: 'purple medium solid'
      }, [createText('This is a second list item.')]),
      createElementWithStyle('li', {
        borderRight: 'blue medium solid'
      }, [createText('Each list item in this \'parent\' list should have a medium-width border along its right side, in each of three colors. The first item\'s border should travel the entire height the nested list (to end near the baseline of the line "...nested within the list item."), even though the nested list does not have any border styles set. The borders should line up together at the right edge of the document\'s body, as each list element has a default width of 100%.')])
    ]);

    append(BODY, note);
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, ul);
    await snapshot();
  });
});