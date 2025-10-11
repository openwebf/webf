describe('CSS1 border-width', () => {
  it('border-width with various values', async () => {
    const p0 = createElementWithStyle('p', {
      backgroundColor: 'silver',
      borderWidth: '0'
    }, [
      createText('This element has a class of zero.')
    ]);
    
    const p1 = createElementWithStyle('p', {
      borderWidth: '50px',
      borderStyle: 'solid'
    }, [
      createText('This element should have an overall border width of 50 pixels.')
    ]);
    
    const p2 = createElementWithStyle('p', {
      borderWidth: 'thick',
      borderStyle: 'solid'
    }, [
      createText('This element should have a thick overall border width.')
    ]);
    
    const p3 = createElementWithStyle('p', {
      borderWidth: 'medium',
      borderStyle: 'solid'
    }, [
      createText('This element should have a medium overall border width.')
    ]);
    
    const p4 = createElementWithStyle('p', {
      borderWidth: 'thin',
      borderStyle: 'solid'
    }, [
      createText('This element should have a thin overall border width.')
    ]);
    
    const p5 = createElementWithStyle('p', {
      borderWidth: '25px'
    }, [
      createText('This element should have no border and no extra "padding" on any side, as no border-style was set.')
    ]);
    
    append(BODY, p0);
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, p5);
    
    await snapshot();
  });
});