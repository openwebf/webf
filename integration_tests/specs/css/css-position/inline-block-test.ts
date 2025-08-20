/*
 * Quick test for inline-block shrink-wrap fix
 */

describe('inline-block shrink-wrap test', () => {
  it('inline-block container should shrink to content', async (done) => {
    const app = document.createElement('div');
    app.style.textAlign = 'center';
    app.style.width = '375px';
    app.style.backgroundColor = '#f0f0f0';
    
    const container = document.createElement('div');
    container.id = 'container';
    container.style.position = 'relative';
    container.style.backgroundColor = '#3b82f6';
    container.style.display = 'inline-block';
    
    const image = document.createElement('img');
    image.id = 'image';
    image.style.display = 'block';
    image.style.width = '100px';
    image.style.height = '100px';
    image.src = 'assets/100x100-green.png';
    
    const overlay = document.createElement('div');
    overlay.id = 'overlay';
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.backgroundColor = 'rgba(255, 255, 0, 0.3)';
    overlay.style.minHeight = '25px';
    
    const span = document.createElement('span');
    span.textContent = 'Test';
    
    overlay.appendChild(span);
    container.appendChild(image);
    container.appendChild(overlay);
    app.appendChild(container);
    document.body.appendChild(app);
    
    image.onload = async () => {
      await snapshot();
      
      console.log('=== Inline-block shrink-wrap test results ===');
      console.log('App width:', app.offsetWidth);
      console.log('Container:', {
        left: container.offsetLeft,
        width: container.offsetWidth,
        display: getComputedStyle(container).display
      });
      console.log('Image:', {
        width: image.offsetWidth,
        height: image.offsetHeight
      });
      console.log('Overlay:', {
        width: overlay.offsetWidth,
        height: overlay.offsetHeight
      });
      console.log('Span:', {
        left: span.offsetLeft,
        width: span.offsetWidth
      });
      
      document.body.removeChild(app);
      done();
    };
  });
});