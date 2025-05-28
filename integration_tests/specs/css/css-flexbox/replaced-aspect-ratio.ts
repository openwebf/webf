describe('RenderReplaced elements with aspect ratio in flex layout', () => {
  it('should correctly handle image aspect ratio in horizontal flex layout', async () => {
    // Create a flex container with horizontal direction
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'row';
    container.style.width = '350px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';
    container.style.backgroundColor = '#f0f0f0';

    // Create an image element with intrinsic aspect ratio
    const img = document.createElement('img');
    img.src = 'assets/100x100-blue.png'; // 1:1 aspect ratio
    img.style.flex = '1';
    img.style.aspectRatio = '1 / 1'; // Explicitly set aspect ratio

    // Add elements to DOM
    container.appendChild(img);
    document.body.appendChild(container);

    // Wait for image to load
    await new Promise(resolve => {
      img.onload = resolve;
    });

    // Take first snapshot
    await snapshot();

    // Change container width to test aspect ratio preservation
    container.style.width = '600px';

    // Take snapshot after width change
    await snapshot();
  });

  it('should maintain aspect ratio for image when flexed', async () => {
    // Create a flex container
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '500px';
    container.style.height = '300px';
    container.style.border = '2px solid black';

    // Create an image with explicit flex properties
    const img = document.createElement('img');
    img.src = 'assets/300x150-green.png'; // 2:1 aspect ratio
    img.style.flex = '1';
    img.style.aspectRatio = '2 / 1'; // Explicitly set aspect ratio

    // Add to DOM
    container.appendChild(img);
    document.body.appendChild(container);

    // Wait for image to load
    await new Promise(resolve => {
      img.onload = resolve;
    });

    // Take snapshot
    await snapshot();

    // Change container dimensions
    container.style.width = '300px';
    container.style.height = '350px';

    // Take snapshot after container resize
    await snapshot();
  });

  xit('should handle multiple replaced elements with different aspect ratios', async () => {
    // Create a flex container
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'row';
    container.style.width = '600px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';
    container.style.gap = '10px';

    // Create first image - 1:1 aspect ratio
    const img1 = document.createElement('img');
    img1.src = 'assets/100x100-blue.png';
    img1.style.flex = '1';
    img1.style.aspectRatio = '1 / 1';

    // Create second image - 2:1 aspect ratio
    const img2 = document.createElement('img');
    img2.src = 'assets/300x150-green.png';
    img2.style.flex = '2';
    img2.style.aspectRatio = '2 / 1';

    // Add to DOM
    container.appendChild(img1);
    container.appendChild(img2);
    document.body.appendChild(container);

    // Wait for images to load
    await Promise.all([
      new Promise(resolve => { img1.onload = resolve; }),
      new Promise(resolve => { img2.onload = resolve; })
    ]);

    // Take snapshot
    await snapshot();

    // Change container width
    container.style.width = '350px';

    // Take snapshot after width change
    await snapshot();

    // Change flex properties
    img1.style.flex = '2';
    img2.style.flex = '1';

    // Take final snapshot after flex change
    await snapshot();
  });

  xit('should handle canvas element with aspect ratio in flex layout', async () => {
    // Create a flex container
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '500px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';

    // Create canvas with aspect ratio
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 100;
    canvas.style.flex = '1';
    canvas.style.aspectRatio = '2 / 1';
    canvas.style.border = '1px solid blue';

    // Draw something on canvas
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = 'lightblue';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = 'blue';
    ctx.fillRect(50, 25, 100, 50);

    // Add to DOM
    container.appendChild(canvas);
    document.body.appendChild(container);

    // Take snapshot
    await snapshot();

    // Change container width
    container.style.width = '300px';

    // Take snapshot after width change
    await snapshot();
  });
});
