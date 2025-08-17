describe('Overlay behavior without absolute positioning', () => {
  it('overlay without position absolute container inline-block', async done => {
    const app = document.createElement('div');
    app.style.textAlign = 'center';

    const container = document.createElement('div');
    container.id = 'container';
    container.style.position = 'relative';
    container.style.backgroundColor = '#3b82f6';
    container.style.display = 'inline-block';

    const image = document.createElement('img');
    image.id = 'image';
    image.style.border = '1px solid #e5e7eb';
    image.style.maxWidth = '299px';
    image.style.maxHeight = '160px';
    image.style.width = 'auto';
    image.style.height = 'auto';
    image.style.objectFit = 'contain';
    image.style.borderRadius = '0.5rem';
    image.style.display = 'block';
    image.src = 'assets/100x100-green.png';

    const overlay = document.createElement('div');
    overlay.id = 'div1';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    // NO position: absolute
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.border = '1px solid #ef4444';
    overlay.style.backgroundColor = 'rgba(255, 255, 0, 0.3)'; // Semi-transparent yellow

    const span = document.createElement('span');
    span.id = 'span';
    span.style.border = '1px solid #22c55e';
    span.textContent = '1Icon';

    app.appendChild(container);
    container.appendChild(image);
    container.appendChild(overlay);
    overlay.appendChild(span);
    document.body.appendChild(app);

    image.onload = async () => {
      await snapshot();

      console.log('=== Without position:absolute ===');
      console.log('Container:', {
        left: container.offsetLeft,
        top: container.offsetTop,
        width: container.offsetWidth,
        height: container.offsetHeight,
        display: getComputedStyle(container).display
      });
      console.log('Image:', {
        left: image.offsetLeft,
        top: image.offsetTop,
        width: image.offsetWidth,
        height: image.offsetHeight
      });
      console.log('Overlay (div1):', {
        left: overlay.offsetLeft,
        top: overlay.offsetTop,
        width: overlay.offsetWidth,
        height: overlay.offsetHeight,
        position: getComputedStyle(overlay).position,
        display: getComputedStyle(overlay).display
      });
      console.log('Span:', {
        left: span.offsetLeft,
        top: span.offsetTop,
        width: span.offsetWidth,
        height: span.offsetHeight
      });
      done();
    };
  });

  it('overlay without position absolute', async done => {
    const app = document.createElement('div');
    app.style.textAlign = 'center';
    
    const container = document.createElement('div');
    container.id = 'container';
    container.style.position = 'relative';
    container.style.backgroundColor = '#3b82f6';
    
    const image = document.createElement('img');
    image.id = 'image';
    image.style.border = '1px solid #e5e7eb';
    image.style.maxWidth = '299px';
    image.style.maxHeight = '160px';
    image.style.width = 'auto';
    image.style.height = 'auto';
    image.style.objectFit = 'contain';
    image.style.borderRadius = '0.5rem';
    image.style.display = 'block';
    image.src = 'assets/100x100-green.png';
    
    const overlay = document.createElement('div');
    overlay.id = 'div1';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    // NO position: absolute
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.border = '1px solid #ef4444';
    overlay.style.backgroundColor = 'rgba(255, 255, 0, 0.3)'; // Semi-transparent yellow
    
    const span = document.createElement('span');
    span.id = 'span';
    span.style.border = '1px solid #22c55e';
    span.textContent = '1Icon';
    
    app.appendChild(container);
    container.appendChild(image);
    container.appendChild(overlay);
    overlay.appendChild(span);
    document.body.appendChild(app);
    
    image.onload = async () => {
      await snapshot();
      
      console.log('=== Without position:absolute ===');
      console.log('Container:', {
        width: container.offsetWidth,
        height: container.offsetHeight,
        display: getComputedStyle(container).display
      });
      console.log('Image:', {
        width: image.offsetWidth,
        height: image.offsetHeight
      });
      console.log('Overlay (div1):', {
        width: overlay.offsetWidth,
        height: overlay.offsetHeight,
        position: getComputedStyle(overlay).position,
        display: getComputedStyle(overlay).display
      });
      console.log('Span:', {
        width: span.offsetWidth,
        height: span.offsetHeight
      });
      
      // Key differences when position:absolute is removed:
      // 1. Overlay is in normal flow, so container height includes both image and overlay
      // 2. Overlay width:100% is relative to container's content width
      // 3. Overlay height:100% might not work as expected without explicit container height
      
      done();
    };
  });
  
  it('comparison with explicit container size', done => {
    const container = document.createElement('div');
    container.style.position = 'relative';
    container.style.width = '200px';
    container.style.height = '150px';
    container.style.backgroundColor = 'blue';
    
    const content = document.createElement('div');
    content.style.width = '50px';
    content.style.height = '50px';
    content.style.backgroundColor = 'green';
    
    const overlay = document.createElement('div');
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    // NO position: absolute
    overlay.style.backgroundColor = 'rgba(255, 0, 0, 0.3)';
    overlay.style.border = '2px solid red';
    
    container.appendChild(content);
    container.appendChild(overlay);
    document.body.appendChild(container);
    
    requestAnimationFrame(async () => {
      await snapshot();
      
      console.log('With explicit container size:');
      console.log('Container:', container.offsetWidth, 'x', container.offsetHeight);
      console.log('Content:', content.offsetWidth, 'x', content.offsetHeight);
      console.log('Overlay:', overlay.offsetWidth, 'x', overlay.offsetHeight);
      
      done();
    });
  });
});