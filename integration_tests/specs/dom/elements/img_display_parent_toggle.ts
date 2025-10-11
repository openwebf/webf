describe('img visibility when parent toggles display (issue #111)', () => {
  it('should render when parent changes from display:none to block', async (done) => {
    // Wrapper to mimic multiple screens
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    wrapper.style.width = '240px';
    wrapper.style.height = '180px';
    wrapper.style.border = '1px solid #ccc';

    const screen1 = document.createElement('div');
    screen1.textContent = '第1屏';
    screen1.style.height = '40px';
    screen1.style.display = 'block';
    screen1.style.background = '#eef';

    // Screen2 hidden initially
    const screen2 = document.createElement('div');
    screen2.id = 'u2';
    screen2.style.display = 'none';
    screen2.style.position = 'relative';
    screen2.style.width = '100%';
    screen2.style.height = '140px';
    screen2.style.background = '#efe';

    const title = document.createElement('div');
    title.textContent = '第2屏';
    title.style.height = '20px';
    title.style.lineHeight = '20px';
    title.style.background = '#ddd';

    const img = document.createElement('img');
    img.className = 'prize__fireworks';
    img.style.position = 'absolute';
    img.style.top = '10%';
    img.style.left = '0';
    img.style.width = '100%';
    img.style.height = '80%';
    img.style.objectFit = 'contain';
    img.alt = '';

    img.onload = async () => {
      // Hidden state snapshot (image loaded but not visible)
      await snapshot();

      // Show the hidden parent; image should render correctly
      screen2.style.display = 'block';

      // Wait a frame and snapshot visible state
      requestAnimationFrame(async () => {
        await snapshot(0.2);
        done();
      });
    };

    // Build DOM tree
    screen2.appendChild(title);
    screen2.appendChild(img);
    wrapper.appendChild(screen1);
    wrapper.appendChild(screen2);
    document.body.appendChild(wrapper);

    // Start loading while parent is hidden
    img.src = 'assets/10frames-1s.gif';
  });
});

