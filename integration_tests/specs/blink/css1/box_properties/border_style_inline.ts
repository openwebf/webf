describe('CSS1 border-style inline', () => {
  it('border-style property on inline elements', async () => {
    const p = createElementWithStyle('p', {
      backgroundColor: 'silver'
    }, [
      createText('This is an unstyled element, save for the background color, and it contains inline elements with classes of '),
      createElementWithStyle('span', {
        borderStyle: 'dashed',
        borderColor: 'black',
        borderWidth: 'thick'
      }, [createText('class one')]),
      createText(', which will result in a dashed thick black border; '),
      createElementWithStyle('span', {
        borderStyle: 'groove',
        borderColor: 'red',
        borderWidth: 'thick'
      }, [createText('class two')]),
      createText(', which should result in a grooved thick purple border, and '),
      createElementWithStyle('span', {
        borderStyle: 'none',
        borderColor: 'purple',
        borderWidth: 'thick'
      }, [createText('class three')]),
      createText(', which should result in no border at all. The line-height of the parent element should not change, on any line.')
    ]);

    append(BODY, p);
    await snapshot();
  });
});