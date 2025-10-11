describe('CSS1 ID as selector', () => {
  it('ID selectors with various patterns', async () => {
    const style = createElement('style', {}, [
      createText(`
        #one {color: green;}
        #a1 {color: green;}
        P#two, P#two2 {color: blue;}
        P#three, P#three2 {color: purple;}
        #four {color: green;}
        #a2 {color: green;}
        P#five, P#five2 {color: blue;}
        P#six, P#six2 {color: purple;}
      `)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`#one {color: green;}
#a1 {color: green;}
P#two, P#two2 {color: blue;}
P#three, P#three2 {color: purple;}
#four {color: green;}
#a2 {color: green;}
P#five, P#five2 {color: blue;}
P#six, P#six2 {color: purple;}`)
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const p2 = createElement('p', {
      id: 'one'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p3 = createElement('p', {
      id: 'a1'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p4 = createElement('p', {
      id: 'two'
    }, [
      createText('This paragraph should be blue ['),
      createElement('tt', {}, [createText('ID="two"')]),
      createText('].')
    ]);
    
    const pre2 = createElement('pre', {
      id: 'two2'
    }, [
      createText('This sentence should NOT be blue [PRE ID="two2"].')
    ]);
    
    const pre3 = createElement('pre', {
      id: 'three'
    }, [
      createText('This sentence should be black, not purple [PRE ID="three"].')
    ]);
    
    const li = createElement('li', {
      id: 'three2'
    }, [
      createText('This sentence should NOT be purple.')
    ]);
    
    const ul = createElement('ul', {}, [li]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, pre2);
    append(BODY, pre3);
    append(BODY, ul);

    await snapshot();
  });
});