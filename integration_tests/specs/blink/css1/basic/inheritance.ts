describe('CSS1 Inheritance', () => {
  it('CSS inheritance with nested elements', async () => {
    const style = createElement('style', {}, [
      createText(`
        BODY {
          color: green;
          overflow: hidden;
        }
        H3 {color: blue;}
        EM {color: purple;}
        .one {font-style: italic;}
        .two {text-decoration: underline;}
        #two {color: navy;}
        .three {color: purple;}
      `)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`BODY {color: green;}
H3 {color: blue;}
EM {color: purple;}
.one {font-style: italic;}
.two {text-decoration: underline;}
#two {color: navy;}
.three {color: purple;}`)
    ]);
    
    const hr = createElement('hr', {}, []);
    
    const h3_1 = createElement('h3', {}, [
      createText('This sentence should show '),
      createElement('strong', {}, [createText('blue')]),
      createText(' and '),
      createElement('em', {}, [createText('purple')]),
      createText('.')
    ]);
    
    const h3_2 = createElement('h3', {}, [
      createText('This sentence should be '),
      createElement('span', {
        className: 'one'
      }, [createText('blue')]),
      createText(' throughout.')
    ]);
    
    const p2 = createElement('p', {}, [
      createText('This should be green except for the '),
      createElement('em', {}, [createText('emphasized words')]),
      createText(', which should be purple.')
    ]);
    
    const h3_3 = createElement('h3', {
      className: 'two'
    }, [
      createText('This should be blue and underlined.')
    ]);
    
    const p3 = createElement('p', {
      className: 'two'
    }, [
      createText('This sentence should be underlined, including '),
      createElement('tt', {}, [createText('this part')]),
      createText(', '),
      createElement('i', {}, [createText('this part')]),
      createText(', '),
      createElement('em', {}, [createText('this part')]),
      createText(', and '),
      createElement('strong', {}, [createText('this part')]),
      createText('.')
    ]);
    
    const p4 = createElement('p', {
      className: 'two',
      id: 'two'
    }, [
      createText('This sentence should also be underlined, as well as dark blue (navy), '),
      createElement('tt', {}, [createText('including this part')]),
      createText('.')
    ]);
    
    const p5 = createElement('p', {
      className: 'three'
    }, [
      createText('This sentence should be purple, including '),
      createElement('strong', {}, [createText('this part')]),
      createText(' and '),
      createElementWithStyle('span', {
        textDecoration: 'underline'
      }, [createText('this part (which is spanned)')]),
      createText('.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, h3_1);
    append(BODY, h3_2);
    append(BODY, p2);
    append(BODY, h3_3);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, p5);

    await snapshot();
  });
});