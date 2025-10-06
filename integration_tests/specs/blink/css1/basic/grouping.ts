describe('CSS1 Grouping', () => {
  it('grouped selectors with comma separation', async () => {
    const style = createElement('style', {}, [
      createText(`
        .one, .two, .three {color: green;}
      `)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText('.one, .two, .three {color: green;}')
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const p2 = createElement('p', {
      className: 'one'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p3 = createElement('p', {
      className: 'two'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p4 = createElement('p', {
      className: 'three'
    }, [
      createText('This sentence should be green.')
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