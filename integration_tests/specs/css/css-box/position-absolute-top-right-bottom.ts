describe('absolute positioned overlay with top/right/bottom', () => {
  it('should stretch vertically within its containing block', async () => {
    const container = document.createElement('div');
    container.textContent = 'container';

    const tag = document.createElement('div');
    tag.textContent = 'tag';

    container.style.position = 'relative';
    container.style.width = '360px';
    container.style.height = '24px';
    container.style.backgroundColor = 'skyblue';

    tag.style.position = 'absolute';
    tag.style.top = '0';
    tag.style.right = '0';
    tag.style.bottom = '0';
    tag.style.backgroundColor = 'red';
    tag.style.border = '1px solid black';

    container.appendChild(tag);
    document.body.appendChild(container);

    await snapshot();
  });
});

