describe('CSS1 border inline', () => {
  it('border shorthand property on inline elements', async () => {
    const p = createElementWithStyle('p', {
      backgroundColor: 'silver'
    }, [
      createText('This is an unstyled element, save for the background color, and containing inline elements with a classes of '),
      createElementWithStyle('span', {
        border: '10px teal outset'
      }, [createText('class one')]),
      createText(', which should result in a 10-pixel outset teal border; and '),
      createElementWithStyle('span', {
        border: '10px olive inset'
      }, [createText('class two')]),
      createText(', which should result in a 10-pixel inset olive border. The line-height of the parent element should not change on any line.')
    ]);

    append(BODY, p);
    await snapshot();
  });
});