describe('Absolute overlay layout max width', () => {
  xit('inline-block container with image and absolute overlay', async done => {
    // Recreate the React app layout scenario
    const app = document.createElement('div');
    app.style.textAlign = 'center';
    
    const container = document.createElement('div');
    container.id = 'container';
    container.style.position = 'relative';
    container.style.backgroundColor = '#3b82f6'; // blue-500
    container.style.display = 'inline-block'; // Key: this makes it shrink-wrap
    
    const image = document.createElement('img');
    image.id = 'image';
    image.style.border = '1px solid #e5e7eb';
    image.style.maxWidth = '299px';
    image.style.maxHeight = '160px';
    image.style.width = 'auto';
    image.style.height = 'auto';
    image.style.objectFit = 'contain';
    image.style.borderRadius = '0.5rem';
    image.src = 'assets/100x100-green.png';
    
    const overlay = document.createElement('div');
    overlay.id = 'div1';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    overlay.style.position = 'absolute';
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.top = '0';
    overlay.style.border = '1px solid #ef4444'; // red-500
    
    const span = document.createElement('span');
    span.id = 'span';
    span.style.border = '1px solid #22c55e'; // green-500
    span.textContent = '1Icon';
    
    app.appendChild(container);
    container.appendChild(image);
    container.appendChild(overlay);
    overlay.appendChild(span);
    document.body.appendChild(app);
    
    image.onload = async () => {
      await snapshot();
      
      console.log('Layout measurements:');
      console.log('Image:', image.offsetWidth, 'x', image.offsetHeight);
      console.log('Container:', container.offsetWidth, 'x', container.offsetHeight);
      console.log('Overlay:', overlay.offsetWidth, 'x', overlay.offsetHeight);
      console.log('Span:', span.offsetWidth, 'x', span.offsetHeight);
      
      // Verify the layout behavior that's problematic
      // 1. Container should wrap the image size when inline-block
      // 2. Overlay should cover the entire container
      // 3. Span should be centered within overlay
      
      done();
    };
  });
  
  it('explicit sized container with absolute overlay', done => {
    // Test with explicit container size for comparison
    const container = document.createElement('div');
    container.style.position = 'relative';
    container.style.width = '200px';
    container.style.height = '150px';
    container.style.backgroundColor = 'blue';
    
    const overlay = document.createElement('div');
    overlay.style.position = 'absolute';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    overlay.style.top = '0';
    overlay.style.left = '0';
    overlay.style.border = '2px solid red';
    overlay.style.boxSizing = 'border-box';
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    
    const content = document.createElement('div');
    content.textContent = 'Centered';
    content.style.border = '1px solid green';
    
    container.appendChild(overlay);
    overlay.appendChild(content);
    document.body.appendChild(container);
    
    requestAnimationFrame(async () => {
      await snapshot();
      
      console.log('Explicit size test:');
      console.log('Container:', container.offsetWidth, 'x', container.offsetHeight);
      console.log('Overlay:', overlay.offsetWidth, 'x', overlay.offsetHeight);
      
      expect(overlay.offsetWidth).toBe(200);
      expect(overlay.offsetHeight).toBe(150);
      
      done();
    });
  });
  
  it('max-width image sizing behavior', done => {
    // Test how max-width affects image sizing
    const container = document.createElement('div');
    container.style.border = '1px solid black';
    
    const image = document.createElement('img');
    image.style.maxWidth = '299px';
    image.style.maxHeight = '160px';
    image.style.width = 'auto';
    image.style.height = 'auto';
    image.style.display = 'block';
    image.src = 'assets/100x100-green.png'; // 100x100 image
    
    container.appendChild(image);
    document.body.appendChild(container);
    
    image.onload = async () => {
      await snapshot();
      
      console.log('Image max-width test:');
      console.log('Natural size:', image.naturalWidth, 'x', image.naturalHeight);
      console.log('Rendered size:', image.offsetWidth, 'x', image.offsetHeight);
      console.log('Max constraints: 299x160');
      
      // 100x100 image should not be constrained by 299x160 max
      expect(image.offsetWidth).toBe(100);
      expect(image.offsetHeight).toBe(100);
      
      done();
    };
  });
});