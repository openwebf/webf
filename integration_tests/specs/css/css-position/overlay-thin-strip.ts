describe('Inline-block image with 2px overlay strip', () => {
  it('renders centered inline-block container with image and 2px full-width overlay', async (done) => {
    // Match body reset from provided HTML
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    // <div style="text-align: center;">
    const wrapper = document.createElement('div');
    wrapper.style.textAlign = 'center';

    // <div id="container" style="position: relative; background-color: #3b82f6; display: inline-block;">
    const container = document.createElement('div');
    container.id = 'container';
    container.style.position = 'relative';
    container.style.backgroundColor = '#3b82f6';
    container.style.display = 'inline-block';

    // <img id="image" ... src="data:image/png;base64,..." />
    const image = document.createElement('img');
    image.id = 'image';
    image.style.border = '10px solid #e5e7eb';
    image.style.maxWidth = '299px';
    image.style.maxHeight = '160px';
    image.style.width = 'auto';
    image.style.height = 'auto';
    image.style.objectFit = 'contain';
    image.style.display = 'block';
    image.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

    // <div id="overlay" style="width: 100%; height: 2px; display: flex; background-color: red;"></div>
    const overlay = document.createElement('div');
    overlay.id = 'overlay';
    overlay.style.width = '100%';
    overlay.style.height = '2px';
    overlay.style.display = 'flex';
    overlay.style.backgroundColor = 'red';

    // Assemble DOM tree
    wrapper.appendChild(container);
    container.appendChild(image);
    container.appendChild(overlay);
    document.body.appendChild(wrapper);

    image.onload = async () => {
      await snapshot();
      done();
    };
  });
});

