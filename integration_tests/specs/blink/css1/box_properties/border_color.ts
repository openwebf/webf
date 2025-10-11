describe('CSS1 border-color', () => {
  it('border-color with various values', async () => {
    const p1 = createElementWithStyle('p', {
      borderColor: 'purple',
      borderStyle: 'solid'
    }, [
      createText('This element should have a purple border surrounding it.')
    ]);
    
    const p2 = createElementWithStyle('p', {
      borderColor: 'purple',
      borderWidth: 'medium',
      borderStyle: 'solid'
    }, [
      createText('This element should have a medium-width purple border surrounding it.')
    ]);
    
    const p3 = createElementWithStyle('p', {
      borderColor: 'purple green blue yellow',
      borderWidth: 'medium',
      borderStyle: 'solid'
    }, [
      createText('This element should be surrounded by a medium width border which is purple on top, green on the right side, blue on the bottom, and yellow on the left side.')
    ]);
    
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, p3);
    
    await snapshot();
  });
});