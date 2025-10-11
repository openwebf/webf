describe('Inline-block container with absolute overlay', () => {
  it('centers inline-block, image 100x100, absolute overlay covers and centers span', async (done) => {
    // Match body reset from provided HTML
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    // <div style="text-align: center;">
    const wrapper = document.createElement('div');
    wrapper.style.textAlign = 'center';

    // <div id="container" style="position: relative; display: inline-block; background: #3b82f6;">
    const container = document.createElement('div');
    container.id = 'container';
    container.style.position = 'relative';
    container.style.display = 'inline-block';
    container.style.background = '#3b82f6';

    // <img id="image" ... width:100px; height:100px; object-fit:contain; display:block; border:1px solid #e5e7eb; src=data:...>
    const image = document.createElement('img');
    image.id = 'image';
    image.style.display = 'block';
    image.style.border = '1px solid #e5e7eb';
    image.style.width = '100px';
    image.style.height = '100px';
    image.style.objectFit = 'contain';
    image.src = 'assets/10x10-green.png';

    // <div id="overlay" style="position:absolute; top:0; left:0; width:100%; height:100%; display:flex; align-items:center; justify-content:center; border:1px solid #ef4444;">
    const overlay = document.createElement('div');
    overlay.id = 'overlay';
    overlay.style.position = 'absolute';
    overlay.style.top = '0';
    overlay.style.left = '0';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.border = '1px solid #ef4444';

    // <span id="span" style="border: 1px solid #22c55e;">1Icon</span>
    const span = document.createElement('span');
    span.id = 'span';
    span.style.border = '1px solid #22c55e';
    span.textContent = '1Icon';

    // Assemble
    overlay.appendChild(span);
    container.appendChild(image);
    container.appendChild(overlay);
    wrapper.appendChild(container);
    document.body.appendChild(wrapper);

    image.onload = async () => {
      await snapshot();
      done();
    };
  });
});

