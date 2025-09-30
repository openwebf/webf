describe('Stacking Context - Articles/Sections z-index', () => {
  it('articles and sections z-index ordering', async () => {
    // Helper to create element with base styles
    function styled<K extends keyof HTMLElementTagNameMap>(tag: K, id?: string): HTMLElementTagNameMap[K] {
      const el = document.createElement(tag);
      if (id) el.id = id;
      // Base CSS from spec snippet: apply to articles/sections generally
      if (tag === 'article' || tag === 'section') {
        (el as HTMLElement).style.opacity = '0.85';
        (el as HTMLElement).style.position = 'relative';
        // Give each container a size to produce visible overlap when absolutely positioned siblings are added
        (el as HTMLElement).style.width = '140px';
        (el as HTMLElement).style.height = '140px';
        (el as HTMLElement).style.margin = '8px';
      }
      return el as any;
    }

    // container1
    const container1 = styled('article', 'container1');
    container1.style.zIndex = '5';
    container1.style.background = 'rgba(52, 152, 219, 0.85)'; // blue-ish
    const c1h1 = document.createElement('h1');
    c1h1.textContent = 'Article element #1';
    const c1code = document.createElement('code');
    c1code.innerHTML = 'position: relative;<br/>z-index: 5;';
    container1.appendChild(c1h1);
    container1.appendChild(c1code);

    // container2
    const container2 = styled('article', 'container2');
    container2.style.zIndex = '2';
    container2.style.background = 'rgba(46, 204, 113, 0.85)'; // green-ish
    const c2h1 = document.createElement('h1');
    c2h1.textContent = 'Article Element #2';
    const c2code = document.createElement('code');
    c2code.innerHTML = 'position: relative;<br/>z-index: 2;';
    container2.appendChild(c2h1);
    container2.appendChild(c2code);

    // container3
    const container3 = styled('article', 'container3');
    // Override per snippet: absolute and z-index: 4
    container3.style.position = 'absolute';
    container3.style.zIndex = '4';
    container3.style.top = '24px';
    container3.style.left = '150px';
    container3.style.background = 'rgba(155, 89, 182, 0.85)'; // purple-ish

    // container4 inside container3
    const container4 = styled('section', 'container4');
    container4.style.zIndex = '6';
    container4.style.background = 'rgba(241, 196, 15, 0.85)'; // yellow-ish
    const c4h1 = document.createElement('h1');
    c4h1.textContent = 'Section Element #4';
    const c4code = document.createElement('code');
    c4code.innerHTML = 'position: relative;<br/>z-index: 6;';
    container4.appendChild(c4h1);
    container4.appendChild(c4code);

    // Heading and code for container3 itself
    const c3h1 = document.createElement('h1');
    c3h1.textContent = 'Article Element #3';
    const c3code = document.createElement('code');
    c3code.innerHTML = 'position: absolute;<br/>z-index: 4;';

    // container5 inside container3
    const container5 = styled('section', 'container5');
    container5.style.zIndex = '1';
    container5.style.background = 'rgba(231, 76, 60, 0.85)'; // red-ish
    const c5h1 = document.createElement('h1');
    c5h1.textContent = 'Section Element #5';
    const c5code = document.createElement('code');
    c5code.innerHTML = 'position: relative;<br/>z-index: 1;';
    container5.appendChild(c5h1);
    container5.appendChild(c5code);

    // container6 inside container3 (absolute)
    const container6 = styled('section', 'container6');
    container6.style.position = 'absolute';
    container6.style.zIndex = '3';
    container6.style.top = '16px';
    container6.style.left = '150px';
    container6.style.background = 'rgba(230, 126, 34, 0.85)'; // orange-ish
    const c6h1 = document.createElement('h1');
    c6h1.textContent = 'Section Element #6';
    const c6code = document.createElement('code');
    c6code.innerHTML = 'position: absolute;<br/>z-index: 3;';
    container6.appendChild(c6h1);
    container6.appendChild(c6code);

    // Build DOM structure as specified
    container3.appendChild(container4);
    container3.appendChild(c3h1);
    container3.appendChild(c3code);
    container3.appendChild(container5);
    container3.appendChild(container6);

    document.body.appendChild(container1);
    document.body.appendChild(container2);
    document.body.appendChild(container3);

    await snapshot();
  });
});
