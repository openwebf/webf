describe('CSS1 Important Declarations', () => {
  it('important declarations override normal and id selectors', async () => {
    const style = createElement('style', {}, [
      createText(`
        P {color: green !important;}
        P {color: red;}
        P#id1 {color: purple;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`P {color: green ! important;}
P {color: red;}
P#id1 {color: purple;}`)
    ]);

    const hr = createElement('hr', {}, []);

    const p2 = createElement('p', {}, [
      createText('This sentence should be green, because the declaration marked important should override any other normal declaration for the same element, even if it occurs later in the stylesheet.')
    ]);

    const p3 = createElement('p', {
      id: 'id1'
    }, [
      createText('This sentence should also be green, even though it has an ID of '),
      createElement('tt', {}, [createText('id1')]),
      createText(', which would ordinarily make it purple.  This is because declarations marked important have more weight than normal declarations given in a STYLE attribute.')
    ]);

    const p4 = createElement('p', {
      style: 'color: red;'
    }, [
      createText('This sentence should also be green, even though it has a STYLE attribute declaring it to be red.  This is because declarations marked important have more weight than normal declarations given in a STYLE attribute.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);

    await snapshot();
  });
});
