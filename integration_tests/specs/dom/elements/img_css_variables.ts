describe('Image CSS variables with display:none', () => {
  it('should update CSS variables correctly when image has display:none', async (done) => {
    // Add CSS with variables
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --img-size: 100px;
        --img-border-color: red;
        --img-border-width: 2px;
      }

      .styled-image {
        width: var(--img-size);
        height: var(--img-size);
        border: var(--img-border-width) solid var(--img-border-color);
      }
    `;
    document.head.appendChild(style);

    const img = document.createElement('img');
    img.className = 'styled-image';

    img.onload = async () => {
      await snapshot();

      // Hide the image
      img.style.display = 'none';

      // Update CSS variables
      document.documentElement.style.setProperty('--img-size', '150px');
      document.documentElement.style.setProperty('--img-border-color', 'blue');
      document.documentElement.style.setProperty('--img-border-width', '4px');

      // Show the image again
      img.style.display = 'block';

      await snapshot();

      // Verify computed styles
      const computedStyle = getComputedStyle(img);
      expect(computedStyle.width).toBe('150px');
      expect(computedStyle.height).toBe('150px');

      done();
    };

    img.src = 'assets/100x100-green.png';
    document.body.appendChild(img);
  });

  xit('should handle CSS variables in media queries with hidden images', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --theme-color: light;
      }

      .themed-image {
        width: 100px;
        height: 100px;
        border: 2px solid black;
      }

      @media (prefers-color-scheme: var(--theme-color)) {
        .themed-image {
          filter: invert(1);
          border-color: white;
        }
      }

      .dark-theme {
        --theme-color: dark;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    const img = document.createElement('img');
    img.className = 'themed-image';

    img.onload = async () => {
      await snapshot();

      // Hide the image
      img.style.display = 'none';

      // Change theme
      container.classList.add('dark-theme');

      // Show the image
      img.style.display = 'block';

      await snapshot();

      done();
    };

    img.src = 'assets/60x60-gg-rr.png';
    container.appendChild(img);
    document.body.appendChild(container);
  });

  it('should handle nested CSS variables with display:none transitions', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --base-size: 50px;
        --size-multiplier: 2;
        --final-size: calc(var(--base-size) * var(--size-multiplier));
        --rotation: 0deg;
      }

      .calculated-image {
        width: var(--final-size);
        height: var(--final-size);
        transform: rotate(var(--rotation));
        border: 3px solid green;
      }
    `;
    document.head.appendChild(style);

    const img = document.createElement('img');
    img.className = 'calculated-image';

    img.onload = async () => {
      await snapshot();

      // Hide and update variables
      img.style.display = 'none';
      document.documentElement.style.setProperty('--base-size', '75px');
      document.documentElement.style.setProperty('--rotation', '45deg');

      // Show again
      img.style.display = 'block';

      await snapshot();

      const computedStyle = getComputedStyle(img);
      expect(computedStyle.width).toBe('150px'); // 75px * 2

      done();
    };

    img.src = 'assets/100x100-green.png';
    document.body.appendChild(img);
  });

  it('should handle CSS variable inheritance through display:none ancestors', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      .parent {
        --parent-border: 2px solid red;
        --parent-size: 150px;
      }

      .child-image {
        width: var(--parent-size);
        height: var(--parent-size);
        border: var(--parent-border);
      }
    `;
    document.head.appendChild(style);

    const parent = document.createElement('div');
    parent.className = 'parent';

    const img = document.createElement('img');
    img.className = 'child-image';

    img.onload = async () => {
      await snapshot();

      // Hide parent
      parent.style.display = 'none';

      // Update parent variables
      parent.style.setProperty('--parent-border', '4px solid blue');
      parent.style.setProperty('--parent-size', '200px');

      // Show parent
      parent.style.display = 'block';

      await snapshot();

      done();
    };

    img.src = 'assets/200x200-green.png';
    parent.appendChild(img);
    document.body.appendChild(parent);
  });

  it('should handle multiple images with shared CSS variables', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --shared-size: 80px;
        --shared-margin: 10px;
      }

      .grid-image {
        width: var(--shared-size);
        height: var(--shared-size);
        margin: var(--shared-margin);
        display: inline-block;
        border: 1px solid gray;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.style.width = '300px';

    let loadCount = 0;
    const images = [];

    for (let i = 0; i < 3; i++) {
      const img = document.createElement('img');
      img.className = 'grid-image';
      img.onload = async () => {
        loadCount++;
        if (loadCount === 3) {
          await snapshot();

          // Hide middle image
          images[1].style.display = 'none';

          // Update variables
          document.documentElement.style.setProperty('--shared-size', '60px');
          document.documentElement.style.setProperty('--shared-margin', '5px');

          // Show middle image
          images[1].style.display = 'inline-block';

          await snapshot();
          done();
        }
      };
      img.src = 'assets/60x60-gg-rr.png';
      images.push(img);
      container.appendChild(img);
    }

    document.body.appendChild(container);
  });
});
