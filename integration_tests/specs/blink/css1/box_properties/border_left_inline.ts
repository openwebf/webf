describe('CSS1 border-left inline', () => {
  it('border-left property on inline elements', async () => {
    const p = createElementWithStyle('p', {
      backgroundColor: 'silver',
      marginLeft: '20px'
    }, [
      createText('This paragraph has a background color of silver and a 20-pixel left margin, and it contains inline elements with classes of '),
      createElementWithStyle('span', {
        borderLeft: 'purple double 10px'
      }, [createText('class one')]),
      createText(', which should have a 10-pixel purple double left border; and '),
      createElementWithStyle('span', {
        borderLeft: 'purple thin solid'
      }, [createText('class two')]),
      createText(', which should have a thin solid purple left border. The line-height of the parent element should not change on any line.')
    ]);

    append(BODY, p);
    await snapshot();
  });
});