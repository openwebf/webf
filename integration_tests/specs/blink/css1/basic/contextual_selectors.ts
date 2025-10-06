describe('CSS1 Contextual selectors', () => {
  it('contextual selectors with descendant combinators', async () => {
    const style = createElement('style', {}, [
      createText(`
        P {color: navy; font-family: serif;}
        HTML BODY TABLE P {color: purple; font-family: sans-serif;}
        EM, UL LI LI {color: green;}
      `)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`P {color: navy; font-family: serif;}
HTML BODY TABLE P {color: purple; font-family: sans-serif;}
EM, UL LI LI {color: green;}`)
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const p2 = createElement('p', {}, [
      createText('This sentence should be navy serif in the first half of the page, but purple and sans-serif in the table.')
    ]);
    
    const em = createElement('em', {}, [
      createText('green')
    ]);
    
    const p3 = createElement('p', {}, [
      createText('This sentence should be normal for its section, except for the last word, which should be '),
      em,
      createText('.')
    ]);
    
    const em2 = createElement('em', {}, [
      createText('Hello.')
    ]);
    
    const li2 = createElement('li', {}, [
      createText('This should be green.')
    ]);
    
    const ul2 = createElement('ul', {}, [li2]);
    
    const li1 = createElement('li', {}, [
      em2,
      createText('  The first "hello" should be green, but this part should be black.'),
      ul2
    ]);
    
    const ul1 = createElement('ul', {}, [li1]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, ul1);

    await snapshot();
  });
});