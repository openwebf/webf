function createFilterFixture(styles: Record<string, string> = {}): HTMLDivElement {
  const div = document.createElement('div');
  setElementStyle(div, {
    width: '320px',
    height: '200px',
    margin: '20px auto',
    borderRadius: '16px',
    background: 'center / contain no-repeat url(assets/rabbit.png)',
    backgroundColor: '#f4f4f5',
    boxShadow: '0 0 0 1px rgba(0,0,0,0.05)',
    ...styles
  });
  document.body.appendChild(div);
  return div;
}

describe('CSS Filter Effects', () => {
  it('grayscale', async () => {
    const div = createFilterFixture();
    div.style.filter = 'grayscale(1)';
    await sleep(0.5);
    await snapshot();
  });

  it('blur', async () => {
    const div = createFilterFixture();
    div.style.filter = 'blur(2px)';
    await sleep(0.5);
    await snapshot();
  });

  it('brightness dim', async () => {
    const div = createFilterFixture();
    div.style.filter = 'brightness(0.5)';
    await sleep(0.5);
    await snapshot();
  });

  it('brightness strong', async () => {
    const div = createFilterFixture();
    div.style.filter = 'brightness(1.4)';
    await sleep(0.5);
    await snapshot();
  });

  it('contrast low', async () => {
    const div = createFilterFixture();
    div.style.filter = 'contrast(0.5)';
    await sleep(0.5);
    await snapshot();
  });

  it('hue rotate 90deg', async () => {
    const div = createFilterFixture();
    div.style.filter = 'hue-rotate(90deg)';
    await sleep(0.5);
    await snapshot();
  });

  it('invert', async () => {
    const div = createFilterFixture();
    div.style.filter = 'invert(1)';
    await sleep(0.5);
    await snapshot();
  });

  it('saturate zero', async () => {
    const div = createFilterFixture();
    div.style.filter = 'saturate(0)';
    await sleep(0.5);
    await snapshot();
  });

  it('drop shadow basic', async () => {
    const div = createFilterFixture({ backgroundColor: '#fff' });
    div.style.filter = 'drop-shadow(0 20px 13px rgba(0,0,0,0.3))';
    await sleep(0.5);
    await snapshot();
  });

  it('drop shadow layered color', async () => {
    const div = createFilterFixture({ backgroundColor: '#fff' });
    div.style.filter =
      'drop-shadow(0 20px 13px rgb(0 0 0 / 0.03)) drop-shadow(0 8px 5px rgb(0 0 0 / 0.08)) drop-shadow(0 10px 8px rgba(255,0,0,0.5))';
    await sleep(0.5);
    await snapshot();
  });
});
