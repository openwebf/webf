describe('calc-background-position', () => {
  it('should calculate background-position with calc() using positive percentages', async () => {
    // calc(50px + 50%) should resolve to 134px for x (50px + 50% of (200px - 32px))
    // calc(100% - 30px) should resolve to -12px for y (50px - 32px - 30px)
    const element = document.createElement('p');
    setElementStyle(element, {
      height: '50px',
      width: '200px',
      border: 'thin solid',
      backgroundImage: 'url(assets/blue-32x32.png)',
      backgroundRepeat: 'no-repeat',
      backgroundPosition: 'calc(50px + 50%) calc(100% - 30px)',
    });

    append(BODY, element);
    await snapshot();
  });

  it('should calculate background-position with calc() using negative percentages', async () => {
    // calc(-12.5% + 3px) should resolve to -18px for x (-12.5% of (200px - 32px) + 3px)
    // calc(-10px - 50%) should resolve to -19px for y (-10px - 50% of (50px - 32px))
    const element = document.createElement('p');
    setElementStyle(element, {
      height: '50px',
      width: '200px',
      border: 'thin solid',
      backgroundImage: 'url(assets/blue-32x32.png)',
      backgroundRepeat: 'no-repeat',
      backgroundPosition: 'calc(-12.5% + 3px) calc(-10px - 50%)',
    });

    append(BODY, element);
    await snapshot();
  });
});
