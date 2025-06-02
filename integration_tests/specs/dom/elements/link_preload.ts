describe('Link preload', () => {
  // Test SVG preload functionality
  it('should preload SVG images and reuse for multiple img elements', async (done) => {
    // Create preload links for SVG images
    const preloadLink1 = document.createElement('link');
    preloadLink1.rel = 'preload';
    preloadLink1.as = 'image';
    preloadLink1.href = 'assets/js-icon.svg';
    preloadLink1.type = 'image/svg+xml';
    document.head.appendChild(preloadLink1);

    const preloadLink2 = document.createElement('link');
    preloadLink2.rel = 'preload';
    preloadLink2.as = 'image';
    preloadLink2.href = 'assets/1x1-green.svg';
    preloadLink2.type = 'image/svg+xml';
    document.head.appendChild(preloadLink2);

    // Wait a bit for preload to complete
    await sleep(0.5);

    let loadedCount = 0;
    const totalImages = 6;

    const checkComplete = () => {
      loadedCount++;
      if (loadedCount === totalImages) {
        snapshot().then(() => done());
      }
    };

    // Create multiple img elements using the same preloaded SVG resources
    for (let i = 0; i < 3; i++) {
      const img1 = document.createElement('img');
      img1.src = 'assets/js-icon.svg';
      img1.style.width = '50px';
      img1.style.height = '50px';
      img1.style.display = 'inline-block';
      img1.style.margin = '5px';
      img1.addEventListener('load', checkComplete);
      document.body.appendChild(img1);

      const img2 = document.createElement('img');
      img2.src = 'assets/1x1-green.svg';
      img2.style.width = '50px';
      img2.style.height = '50px';
      img2.style.display = 'inline-block';
      img2.style.margin = '5px';
      img2.addEventListener('load', checkComplete);
      document.body.appendChild(img2);
    }
  });

  it('should preload PNG images', async (done) => {
    const preloadLink = document.createElement('link');
    preloadLink.rel = 'preload';
    preloadLink.as = 'image';
    preloadLink.href = 'assets/100x100-green.png';
    document.head.appendChild(preloadLink);

    // Wait for preload
    await sleep(0.3);

    const img = document.createElement('img');
    img.src = 'assets/100x100-green.png';
    img.style.width = '100px';
    img.style.height = '100px';
    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });
    document.body.appendChild(img);
  });

  it('should handle multiple preload links for the same resource', async (done) => {
    // Create multiple preload links for the same resource
    const preloadLink1 = document.createElement('link');
    preloadLink1.rel = 'preload';
    preloadLink1.as = 'image';
    preloadLink1.href = 'assets/60x60-green.png';
    document.head.appendChild(preloadLink1);

    const preloadLink2 = document.createElement('link');
    preloadLink2.rel = 'preload';
    preloadLink2.as = 'image';
    preloadLink2.href = 'assets/60x60-green.png';
    document.head.appendChild(preloadLink2);

    await sleep(0.3);

    const img = document.createElement('img');
    img.src = 'assets/60x60-green.png';
    img.style.width = '60px';
    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });
    document.body.appendChild(img);
  });

  it('should not affect non-preloaded images', async (done) => {
    // Load an image without preload
    const img = document.createElement('img');
    img.src = 'assets/50x50-green.png';
    img.style.width = '50px';
    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });
    img.addEventListener('error', () => {
      done.fail('Image failed to load');
    });
    document.body.appendChild(img);
  });

  it('should handle preload with relative URLs', async (done) => {
    const preloadLink = document.createElement('link');
    preloadLink.rel = 'preload';
    preloadLink.as = 'image';
    preloadLink.href = './assets/red.png';
    document.head.appendChild(preloadLink);

    await sleep(0.3);

    const img = document.createElement('img');
    img.src = './assets/red.png';
    img.style.width = '50px';
    img.style.height = '50px';
    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });
    document.body.appendChild(img);
  });

  it('should only preload when as="image"', async (done) => {
    const preloadLink = document.createElement('link');
    preloadLink.rel = 'preload';
    preloadLink.as = 'script'; // Not an image
    preloadLink.href = 'assets/100x100-blue.png';
    document.head.appendChild(preloadLink);

    await sleep(0.3);

    // This should still load normally (not from preload)
    const img = document.createElement('img');
    img.src = 'assets/100x100-blue.png';
    img.style.width = '100px';
    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });
    document.body.appendChild(img);
  });

  it('should handle dynamic href changes', async (done) => {
    const preloadLink = document.createElement('link');
    preloadLink.rel = 'preload';
    preloadLink.as = 'image';
    preloadLink.href = 'assets/green.png';
    document.head.appendChild(preloadLink);

    await sleep(0.2);

    // Change href
    preloadLink.href = 'assets/blue-32x32.png';

    await sleep(0.2);

    const img = document.createElement('img');
    img.src = 'assets/blue-32x32.png';
    img.style.width = '32px';
    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });
    document.body.appendChild(img);
  });

  it('should work with disconnected link elements', async (done) => {
    const preloadLink = document.createElement('link');
    preloadLink.rel = 'preload';
    preloadLink.as = 'image';
    preloadLink.href = 'assets/20x50-green.png';
    document.head.appendChild(preloadLink);

    await sleep(0.2);

    // Remove the link element
    document.head.removeChild(preloadLink);

    // Image should still benefit from preload
    const img = document.createElement('img');
    img.src = 'assets/20x50-green.png';
    img.style.width = '20px';
    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });
    document.body.appendChild(img);
  });

  it('should handle CSS background images with preload', async (done) => {
    const preloadLink = document.createElement('link');
    preloadLink.rel = 'preload';
    preloadLink.as = 'image';
    preloadLink.href = 'assets/cat.png';
    document.head.appendChild(preloadLink);

    await sleep(0.3);

    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundImage = 'url(assets/cat.png)';
    div.style.backgroundSize = 'cover';
    document.body.appendChild(div);

    // Wait for background image to render
    await sleep(0.5);
    await snapshot();
    done();
  });
});
