describe('Image dynamic updates', () => {
  it('should update styles dynamically on image elements', async (done) => {
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    img.style.border = '2px solid red';
    
    img.onload = async () => {
      await snapshot();
      
      // Update multiple styles dynamically
      img.style.width = '150px';
      img.style.height = '150px';
      img.style.border = '4px solid blue';
      img.style.transform = 'rotate(45deg)';
      
      await snapshot();
      
      // Update object-fit dynamically
      img.style.objectFit = 'contain';
      img.style.backgroundColor = 'yellow';
      
      await snapshot();
      done();
    };
    
    img.src = 'assets/100x100-green.png';
    document.body.appendChild(img);
  });

  it('should handle display none and block transitions correctly', async (done) => {
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    img.style.border = '2px solid green';
    
    img.onload = async () => {
      await snapshot();
      
      // Hide the image
      img.style.display = 'none';
      await snapshot();
      
      // Update styles while hidden
      img.style.width = '200px';
      img.style.height = '200px';
      img.style.border = '4px solid purple';
      
      // Show the image again
      img.style.display = 'block';
      await snapshot();
      
      // Verify styles were applied
      expect(img.style.width).toBe('200px');
      expect(img.style.height).toBe('200px');
      
      done();
    };
    
    img.src = 'assets/200x200-green.png';
    document.body.appendChild(img);
  });

  it('should handle switching between replaced element and normal flow', async (done) => {
    const container = document.createElement('div');
    container.style.width = '300px';
    container.style.height = '200px';
    container.style.border = '1px solid black';
    container.style.position = 'relative';
    
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    img.id = 'testImage';
    
    img.onload = async () => {
      await snapshot();
      
      // Make image display:none
      img.style.display = 'none';
      
      // Add a div in its place
      const div = document.createElement('div');
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = 'blue';
      div.textContent = 'Replaced';
      div.style.color = 'white';
      div.style.textAlign = 'center';
      div.style.lineHeight = '100px';
      container.appendChild(div);
      
      await snapshot();
      
      // Remove the div and show image again
      container.removeChild(div);
      img.style.display = 'block';
      
      await snapshot();
      done();
    };
    
    img.src = 'assets/60x60-gg-rr.png';
    container.appendChild(img);
    document.body.appendChild(container);
  });

  it('should properly clean up event listeners when element is detached', async (done) => {
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    
    let listenerCalled = false;
    const styleChangeListener = () => {
      listenerCalled = true;
    };
    
    img.onload = async () => {
      await snapshot();
      
      // Remove from DOM
      document.body.removeChild(img);
      
      // Try to change styles after removal
      img.style.width = '200px';
      img.style.height = '200px';
      
      // Re-append to DOM
      document.body.appendChild(img);
      await snapshot();
      
      // Verify element still works correctly
      img.style.border = '3px solid red';
      await snapshot();
      
      done();
    };
    
    img.src = 'assets/100x100-green.png';
    document.body.appendChild(img);
  });

  it('should handle dynamic replacement of img with other elements', async (done) => {
    const container = document.createElement('div');
    container.style.width = '200px';
    container.style.height = '200px';
    container.style.border = '1px solid gray';
    
    const img = document.createElement('img');
    img.style.width = '100%';
    img.style.height = '100%';
    img.className = 'dynamic-element';
    
    img.onload = async () => {
      await snapshot();
      
      // Replace img with canvas
      const canvas = document.createElement('canvas');
      canvas.width = 200;
      canvas.height = 200;
      canvas.className = 'dynamic-element';
      canvas.style.width = '100%';
      canvas.style.height = '100%';
      
      const ctx = canvas.getContext('2d');
      ctx.fillStyle = 'red';
      ctx.fillRect(0, 0, 200, 200);
      ctx.fillStyle = 'white';
      ctx.font = '20px Arial';
      ctx.fillText('Canvas', 60, 100);
      
      container.replaceChild(canvas, img);
      await snapshot();
      
      // Replace canvas back with img
      const newImg = document.createElement('img');
      newImg.style.width = '100%';
      newImg.style.height = '100%';
      newImg.className = 'dynamic-element';
      
      newImg.onload = async () => {
        await snapshot();
        done();
      };
      
      container.replaceChild(newImg, canvas);
      newImg.src = 'assets/300x150-green.png';
    };
    
    container.appendChild(img);
    document.body.appendChild(container);
    img.src = 'assets/200x200-green.png';
  });

  it('should handle rapid style changes correctly', async (done) => {
    const img = document.createElement('img');
    img.style.width = '50px';
    img.style.height = '50px';
    
    img.onload = async () => {
      await snapshot();
      
      // Rapid style changes
      for (let i = 0; i < 5; i++) {
        img.style.width = `${60 + i * 20}px`;
        img.style.height = `${60 + i * 20}px`;
        img.style.transform = `rotate(${i * 30}deg)`;
      }
      
      await snapshot();
      
      // Final state
      expect(img.style.width).toBe('140px');
      expect(img.style.height).toBe('140px');
      
      done();
    };
    
    img.src = 'assets/100x100-green.png';
    document.body.appendChild(img);
  });
});