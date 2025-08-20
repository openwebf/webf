/*
 * Test for inline-block shrink-wrap behavior
 * This test demonstrates the issue where inline-block containers don't properly shrink-wrap to their content
 */

describe('inline-block shrink-wrap', () => {
  it('inline-block container should shrink-wrap to content width', async (done) => {
    const app = document.createElement('div');
    app.style.textAlign = 'center';
    app.style.width = '375px'; // Simulate viewport width
    app.style.backgroundColor = '#f0f0f0';
    
    const container = document.createElement('div');
    container.id = 'container';
    container.style.position = 'relative';
    container.style.backgroundColor = '#3b82f6';
    container.style.display = 'inline-block';
    container.style.border = '1px solid black';
    
    const image = document.createElement('img');
    image.id = 'image';
    image.style.display = 'block';
    image.style.width = '100px';
    image.style.height = '100px';
    image.src = 'assets/100x100-green.png';
    
    container.appendChild(image);
    app.appendChild(container);
    document.body.appendChild(app);
    
    image.onload = async () => {
      await snapshot();
      
      const appRect = app.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();
      const imageRect = image.getBoundingClientRect();
      
      console.log('=== Inline-block shrink-wrap test ===');
      console.log('App:', {
        width: app.offsetWidth,
        textAlign: getComputedStyle(app).textAlign
      });
      console.log('Container:', {
        left: container.offsetLeft,
        width: container.offsetWidth,
        display: getComputedStyle(container).display
      });
      console.log('Image:', {
        width: image.offsetWidth,
        height: image.offsetHeight
      });
      
      // Container should shrink-wrap to image width (plus borders)
      expect(container.offsetWidth).toBeCloseTo(image.offsetWidth + 2, 1); // +2 for borders
      
      // Container should be centered due to text-align: center
      const expectedLeft = (app.offsetWidth - container.offsetWidth) / 2;
      expect(container.offsetLeft).toBeCloseTo(expectedLeft, 1);
      
      console.log('Expected container width:', image.offsetWidth + 2);
      console.log('Actual container width:', container.offsetWidth);
      console.log('Expected container left:', expectedLeft);
      console.log('Actual container left:', container.offsetLeft);
      
      document.body.removeChild(app);
      done();
    };
  });

  it('inline-block with multiple children should shrink-wrap correctly', async (done) => {
    const app = document.createElement('div');
    app.style.textAlign = 'center';
    app.style.width = '400px';
    
    const container = document.createElement('div');
    container.style.display = 'inline-block';
    container.style.backgroundColor = '#eee';
    container.style.border = '2px solid red';
    
    const img = document.createElement('img');
    img.style.display = 'block';
    img.style.width = '150px';
    img.style.height = '100px';
    img.src = 'assets/100x100-green.png';
    
    const text = document.createElement('div');
    text.style.width = '150px';
    text.textContent = 'Text content';
    
    container.appendChild(img);
    container.appendChild(text);
    app.appendChild(container);
    document.body.appendChild(app);
    
    img.onload = async () => {
      await snapshot();
      
      // Container should shrink to the width of its widest child
      expect(container.offsetWidth).toBeCloseTo(150 + 4, 1); // 150px + 4px borders
      
      console.log('Container width with multiple children:', container.offsetWidth);
      
      document.body.removeChild(app);
      done();
    };
  });

  it('inline-block with flex child should still shrink-wrap', async (done) => {
    const app = document.createElement('div');
    app.style.textAlign = 'center';
    app.style.width = '375px';
    
    const container = document.createElement('div');
    container.style.position = 'relative';
    container.style.display = 'inline-block';
    container.style.backgroundColor = '#3b82f6';
    
    const image = document.createElement('img');
    image.style.display = 'block';
    image.style.width = '100px';
    image.style.height = '100px';
    image.src = 'assets/100x100-green.png';
    
    const flexChild = document.createElement('div');
    flexChild.style.display = 'flex';
    flexChild.style.alignItems = 'center';
    flexChild.style.justifyContent = 'center';
    flexChild.style.backgroundColor = 'rgba(255, 255, 0, 0.3)';
    flexChild.style.minHeight = '50px';
    
    const span = document.createElement('span');
    span.textContent = 'Flex content';
    
    flexChild.appendChild(span);
    container.appendChild(image);
    container.appendChild(flexChild);
    app.appendChild(container);
    document.body.appendChild(app);
    
    image.onload = async () => {
      await snapshot();
      
      console.log('=== Inline-block with flex child ===');
      console.log('Container width:', container.offsetWidth);
      console.log('Image width:', image.offsetWidth);
      console.log('Flex child width:', flexChild.offsetWidth);
      
      // Container should shrink to image width (100px)
      expect(container.offsetWidth).toBeCloseTo(100, 5);
      
      // Flex child should take container's width
      expect(flexChild.offsetWidth).toBe(container.offsetWidth);
      
      document.body.removeChild(app);
      done();
    };
  });
});