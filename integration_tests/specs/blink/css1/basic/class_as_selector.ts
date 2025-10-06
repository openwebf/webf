describe('CSS1 Class as selector', () => {
  it('class selectors with various patterns', async () => {
    const style = createElement('style', {}, [
      createText(`
        .one {color: green;}
        .1 {color: red;}
        .a1 {color: green;}
        P.two {color: purple;}
      `)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`.one {color: green;}
.1 {color: red;}
.a1 {color: green;}
P.two {color: purple;}`)
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const p2 = createElement('p', {
      className: 'one'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p3 = createElement('p', {
      className: '1'
    }, [
      createText('This sentence should be black, not red-- class selectors cannot begin with digits in CSS1.')
    ]);
    
    const p4 = createElement('p', {
      className: 'a1'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p5 = createElement('p', {
      className: 'two'
    }, [
      createText('This sentence should be purple.')
    ]);
    
    const pre2 = createElement('pre', {
      className: 'two'
    }, [
      createText('This sentence should NOT be purple.')
    ]);
    
    const li = createElement('li', {
      className: 'two'
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
    append(BODY, p5);
    append(BODY, pre2);
    append(BODY, ul);

    await snapshot();
  });
});