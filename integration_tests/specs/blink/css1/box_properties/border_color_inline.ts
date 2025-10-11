describe('CSS1 border-color inline', () => {
  it('border-color property on inline elements', async () => {
    const p = createElementWithStyle('p', {
      backgroundColor: 'silver'
    }, [
      createText('This is an unstyled element, save for the background color, and containing inline elements with a classes of '),
      createElementWithStyle('span', {
        borderColor: 'purple',
        borderStyle: 'solid'
      }, [createText('class one')]),
      createText(', '),
      createElementWithStyle('span', {
        borderColor: 'purple',
        borderWidth: 'medium',
        borderStyle: 'solid'
      }, [createText('class two')]),
      createText(', and '),
      createElementWithStyle('span', {
        borderColor: 'purple green blue yellow',
        borderWidth: 'medium',
        borderStyle: 'solid'
      }, [createText('class three')]),
      createText('. The effect for each inline element should be to have a purple medium-width solid border in the first and second cases, and a purple-green-blue-yellow medium-width solid border in the third. The line-height of the parent element should not change at all, on any line.')
    ]);

    append(BODY, p);
    await snapshot();
  });
});