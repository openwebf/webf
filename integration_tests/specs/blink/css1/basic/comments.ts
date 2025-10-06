describe('CSS1 Comments', () => {
  it('CSS comments in various forms', async () => {
    const style = createElement('style', {}, [
      createText(`
        /* This is a CSS1 comment. */
        .one {color: green;} /* Another comment */
        /* The following should not be used:
        .two {color: red;} */
        .three {color: green; /* color: red; */}
        /**
        .four {color: red;} */
        .five {color: green;}
        /**/
        .six {color: green;}
        /*********/
        .seven {color: green;}
        /* a comment **/
        .eight {color: green;}
      `)
    ]);
    
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);
    
    const pre = createElement('pre', {}, [
      createText(`/* This is a CSS1 comment. */
.one {color: green;} /* Another comment */
/* The following should not be used:
.two {color: red;} */
.three {color: green; /* color: red; */}
/**
.four {color: red;} */
.five {color: green;}
/**/
.six {color: green;}
/*********/
.seven {color: green;}
/* a comment **/
.eight {color: green;}`)
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
      createText('This sentence should be black.')
    ]);
    
    const p4 = createElement('p', {
      className: 'three'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p5 = createElement('p', {
      className: 'four'
    }, [
      createText('This sentence should be black.')
    ]);
    
    const p6 = createElement('p', {
      className: 'five'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p7 = createElement('p', {
      className: 'six'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p8 = createElement('p', {
      className: 'seven'
    }, [
      createText('This sentence should be green.')
    ]);
    
    const p9 = createElement('p', {
      className: 'eight'
    }, [
      createText('This sentence should be green.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, p5);
    append(BODY, p6);
    append(BODY, p7);
    append(BODY, p8);
    append(BODY, p9);

    await snapshot();
  });
});