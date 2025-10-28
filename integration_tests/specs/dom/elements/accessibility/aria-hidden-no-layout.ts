describe('Accessibility: aria-hidden should not affect layout/paint', () => {
  it('toggling aria-hidden leaves layout unchanged', async () => {
    const container = document.createElement('div');
    container.style.width = '200px';
    container.style.border = '1px solid #ccc';
    container.style.padding = '8px';

    const a = document.createElement('a');
    a.href = '#';
    a.textContent = 'Learn More';
    a.style.display = 'inline-block';
    a.style.padding = '4px 8px';

    container.appendChild(a);
    document.body.appendChild(container);

    await snapshot();

    // Hide from a11y tree but keep visual unchanged
    a.setAttribute('aria-hidden', 'true');
    await snapshot();
  });
});

