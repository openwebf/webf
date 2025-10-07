describe('CSS1 border', () => {
  it('border with medium black solid', async () => {
    const p = createElementWithStyle('p', {
      border: 'medium black solid'
    }, [
      createText('This paragraph should have a medium black solid border all the way around.')
    ]);
    
    append(BODY, p);
    await snapshot();
  });

  xit('border with thin maroon ridge', async () => {
    const p = createElementWithStyle('p', {
      border: 'thin maroon ridge'
    }, [
      createText('This paragraph should have a thin maroon ridged border all the way around.')
    ]);
    
    append(BODY, p);
    await snapshot();
  });

  xit('border with 10px teal outset', async () => {
    const p = createElementWithStyle('p', {
      border: '10px teal outset'
    }, [
      createText('This paragraph should have a ten-pixel-wide teal outset border all the way around.')
    ]);
    
    append(BODY, p);
    await snapshot();
  });

  xit('border with 10px olive inset', async () => {
    const p = createElementWithStyle('p', {
      border: '10px olive inset'
    }, [
      createText('This paragraph should have a ten-pixel-wide olive inset border all the way around.')
    ]);
    
    append(BODY, p);
    await snapshot();
  });

  it('border with 10px maroon without style', async () => {
    const p = createElementWithStyle('p', {
      border: '10px maroon'
    }, [
      createText('This paragraph should have no border around it, as the border-style was not set, and it should not be offset in any way.')
    ]);
    
    append(BODY, p);
    await snapshot();
  });

  xit('border with maroon double', async () => {
    const p = createElementWithStyle('p', {
      border: 'maroon double'
    }, [
      createText('This paragraph should have a medium maroon double border around it, even though border-width was not explicitly set.')
    ]);
    
    append(BODY, p);
    await snapshot();
  });

  it('border with invalid declaration', async () => {
    const p = createElementWithStyle('p', {
      border: 'left red solid'
    }, [
      createText('This paragraph should have no border around it, as its declaration is invalid and should be ignored.')
    ]);
    
    append(BODY, p);
    await snapshot();
  });

  it('border with 0px on image', async () => {
    const p = createElement('p', {}, [
      createText('The following image is also an anchor which points to a target on this page, but it should not have a border around it: '),
      createElementWithStyle('img', {
        border: '0px'
      })
    ]);
    
    append(BODY, p);
    await snapshot();
  });
});