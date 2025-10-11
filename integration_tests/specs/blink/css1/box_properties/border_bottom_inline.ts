describe('CSS1 border-bottom inline', () => {
  it('border-bottom property on inline elements', async () => {
    const p = createElementWithStyle('p', {
      backgroundColor: 'silver'
    }, [
      createText('This is an unstyled element, save for the background color, and containing inline elements with classes of '),
      createElementWithStyle('span', {
        borderBottom: 'purple double 10px'
      }, [createText('class one')]),
      createText(', which should have a 10-pixel purple double bottom border; and '),
      createElementWithStyle('span', {
        borderBottom: 'purple thin solid'
      }, [createText('class two')]),
      createText(', which should have a thin solid purple bottom border. The line-height of the parent element should not change on any line.')
    ]);

    append(BODY, p);
    await snapshot();
  });
});