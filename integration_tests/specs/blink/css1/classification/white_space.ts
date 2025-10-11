describe('CSS1 Test Suite: 5.6.2 white-space', () => {
  it('should test white-space property values', async () => {
    // Add CSS styles
    const style = document.createElement('style');
    style.textContent = `
      body {overflow: hidden;}
      .one {white-space: pre;}
      .two {white-space: nowrap;}
      .three {white-space: normal;}
    `;
    document.head.appendChild(style);

    const container = createElementWithStyle('div', {});

    // Description paragraph
    const descP = createElementWithStyle('p', {});
    descP.textContent = 'The style declarations which apply to the text below are:';
    container.appendChild(descP);

    // Style declarations
    const pre = createElementWithStyle('pre', {});
    pre.textContent = `.one {white-space: pre;}
.two {white-space: nowrap;}
.three {white-space: normal;}`;
    container.appendChild(pre);

    // HR separator
    const hr = createElementWithStyle('hr', {});
    container.appendChild(hr);

    // Test white-space: pre
    const p1 = createElementWithStyle('p', { className: 'one' });
    p1.textContent = `This sentence should     show extra space  where there    would ordinarily         not be any.
     There should also be preservation of returns
as this sentence
     very clearly demonstrates.`;
    container.appendChild(p1);

    // Test white-space: nowrap
    const p2 = createElementWithStyle('p', { className: 'two' });
    p2.textContent = 'This sentence should not word-wrap, no matter how long the sentence is, as it has been set to nowrap and that should have the obvious effect.';
    container.appendChild(p2);

    // Test mixed white-space values
    const p3 = createElementWithStyle('p', { className: 'one' });
    p3.appendChild(document.createTextNode('This sentence      should     show extra   space, '));
    const span = createElementWithStyle('span', { className: 'three' });
    span.textContent = 'except in the       second half';
    p3.appendChild(span);
    p3.appendChild(document.createTextNode('.'));
    container.appendChild(p3);

    document.body.appendChild(container);
    await snapshot();
  });
});