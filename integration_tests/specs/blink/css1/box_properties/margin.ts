describe('CSS1 margin', () => {
  it('margin 0 with silver background', async () => {
    setElementStyle(BODY, {
      overflow: 'hidden'
    });

    const p = createElementWithStyle('p', {
      backgroundColor: 'silver',
      margin: '0'
    }, [
      createText('This element has a class of zero.')
    ]);

    append(BODY, p);
    await snapshot();
  });

  it('margin 0.5in with aqua background', async () => {
    setElementStyle(BODY, {
      overflow: 'hidden'
    });

    const p = createElementWithStyle('p', {
      margin: '0.5in',
      backgroundColor: 'aqua'
    }, [
      createText('This sentence should have an overall margin of half an inch, which will require extra text in order to test.')
    ]);

    append(BODY, p);
    await snapshot();
  });

  it('margin 25px with aqua background', async () => {
    setElementStyle(BODY, {
      overflow: 'hidden'
    });

    const p = createElementWithStyle('p', {
      margin: '25px',
      backgroundColor: 'aqua'
    }, [
      createText('This sentence should have an overall margin of 25 pixels, which will require extra text in order to test.')
    ]);

    append(BODY, p);
    await snapshot();
  });

  it('margin 5em with aqua background', async () => {
    setElementStyle(BODY, {
      overflow: 'hidden'
    });

    const p = createElementWithStyle('p', {
      margin: '5em',
      backgroundColor: 'aqua'
    }, [
      createText('This sentence should have an overall margin of 5 em, which will require extra text in order to test.')
    ]);

    append(BODY, p);
    await snapshot();
  });

  it('margin 25% with aqua background', async () => {
    setElementStyle(BODY, {
      overflow: 'hidden'
    });

    const p = createElementWithStyle('p', {
      margin: '25%',
      backgroundColor: 'aqua'
    }, [
      createText('This sentence should have an overall margin of 25%, which is calculated with respect to the width of the parent element. This will require extra text in order to test.')
    ]);

    append(BODY, p);
    await snapshot();
  });

  it('margin 25px on ul with list items', async () => {
    setElementStyle(BODY, {
      overflow: 'hidden'
    });

    const ul = createElementWithStyle('ul', {
      margin: '25px',
      backgroundColor: 'aqua'
    }, [
      createElement('li', {}, [
        createText('This list has a margin of 25px, and a light blue background.')
      ]),
      createElement('li', {}, [
        createText('Therefore, it ought to have such a margin.')
      ]),
      createElementWithStyle('li', {
        margin: '25px'
      }, [
        createText('This list item has a margin of 25px, which should cause it to be offset in some fashion.')
      ]),
      createElement('li', {}, [
        createText('This list item has no special styles applied to it.')
      ])
    ]);

    append(BODY, ul);
    await snapshot();
  });

  it('margin -10px with aqua background', async () => {
    setElementStyle(BODY, {
      overflow: 'hidden'
    });

    const p = createElementWithStyle('p', {
      margin: '-10px',
      backgroundColor: 'aqua'
    }, [
      createText('This paragraph has an overall margin of -10px, which should make it wider than usual as well as shift it upward and pull subsequent text up toward it, and a light blue background. In all other respects, however, the element should be normal. No styles have been applied to it besides the negative margin and the background color.')
    ]);

    append(BODY, p);
    await snapshot();
  });
});
