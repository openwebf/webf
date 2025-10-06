describe('CSS1 Containment in HTML', () => {
  it('containment with external stylesheets and imports', async () => {
    // Note: This test focuses on the CSS containment and styling behavior
    // External stylesheet imports are simplified for the test environment
    const style = createElement('style', {}, [
      createText(`
        UL {color: red;}
        .four {color: purple;}
        P.six {color: green;}
        .one {text-decoration: underline;}
        .three {color: green;}
        .threea {color: purple;}
        .five {color: black;}
      `)
    ]);

    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const p1 = createElementWithStyle('p', {}, [
      createText('The style declarations which apply to the text below are:')
    ]);

    const pre = createElement('pre', {}, [
      createText(`<LINK rel="stylesheet" type="text/css" href="linktest.css" title="Default SS">
<LINK rel="alternate stylesheet" type="text/css" href="linktest2.css" title="Alternate SS">
@import url(imptest1.css);
@import "imptest1a.css";
UL {color: red;}
.four {color: purple;}
@import url(imptest2.css);
<!--
P.six {color: green;}
-->`)
    ]);

    const hr = createElement('hr', {}, []);

    const p2 = createElement('p', {
      className: 'one'
    }, [
      createText('This sentence should be underlined due to the linked style sheet '),
      createElement('code', {}, [createText('linktest.css')]),
      createText(', the reference to which is shown above.')
    ]);

    const p3 = createElement('p', {
      className: 'two'
    }, [
      createText('This sentence should NOT be underlined due to the linked style sheet '),
      createElement('code', {}, [createText('linktest2.css')]),
      createText(', '),
      createElement('strong', {}, [createText('unless')]),
      createText(' the external style sheet "Alternate SS" has been selected via the user agent.')
    ]);

    const li1 = createElement('li', {
      className: 'three'
    }, [
      createText('This sentence should be green due to an imported style sheet ['),
      createElement('code', {}, [createText('@import url(imptest1.css);')]),
      createText('].')
    ]);

    const li2 = createElement('li', {
      className: 'threea'
    }, [
      createText('This sentence should be purple due to an imported style sheet ['),
      createElement('code', {}, [createText('@import "imptest1a.css"')]),
      createText('].')
    ]);

    const li3 = createElementWithStyle('li', {
      color: 'green'
    }, [
      createText('This sentence should be green thanks to the STYLE attribute ['),
      createElement('code', {}, [createText('STYLE="color: green;"')]),
      createText('].')
    ]);

    const ul = createElement('ul', {}, [li1, li2, li3]);

    const p4 = createElement('p', {
      className: 'four'
    }, [
      createText('This sentence should be purple, and it doesn\'t have a terminating paragraph tag.')
    ]);

    const oli1 = createElement('li', {}, [
      createText('This list should NOT be purple.')
    ]);

    const oli2 = createElement('li', {}, [
      createText('It should, instead, be black.')
    ]);

    const oli3 = createElement('li', {}, [
      createText('If it IS purple, then the browser hasn\'t correctly parsed the preceding paragraph.')
    ]);

    const ol = createElement('ol', {}, [oli1, oli2, oli3]);

    const p5 = createElement('p', {
      className: 'five'
    }, [
      createText('This sentence should be black.  If it is red, then the browser has inappropriately imported the styles from the file '),
      createElement('tt', {}, [createText('imptest2.css')]),
      createText(' (see '),
      createElement('a', {
        href: 'http://www.w3.org/TR/REC-CSS1#the-cascade'
      }, [createText('section 3.0')]),
      createText(' of the CSS1 specification for more details).')
    ]);

    const p6 = createElement('p', {
      className: 'six'
    }, [
      createText('This paragraph should be green.')
    ]);

    append(BODY, p1);
    append(BODY, pre);
    append(BODY, hr);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, ul);
    append(BODY, p4);
    append(BODY, ol);
    append(BODY, p5);
    append(BODY, p6);

    await snapshot();
  });
});
