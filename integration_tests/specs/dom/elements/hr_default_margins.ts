describe('<hr> default margins', () => {
  it('uses 0.5em block margins by default', async () => {
    await resizeViewport(400, 300);

    const prevDocMargin = document.documentElement.style.margin;
    const prevBodyMargin = document.body.style.margin;
    const prevBodyPadding = document.body.style.padding;
    const prevBodyFontSize = document.body.style.fontSize;

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';
      document.body.style.fontSize = '16px';

      const hr = document.createElement('hr');
      hr.id = 'hr';
      document.body.appendChild(hr);

      await waitForOnScreen(hr as any);
      await nextFrames(2);

      const style = getComputedStyle(hr);
      const mt = parseFloat(style.marginTop || '0');
      const mb = parseFloat(style.marginBottom || '0');

      // 0.5em at 16px font-size => 8px.
      expect(Math.abs(mt - 8)).toBeLessThanOrEqual(1);
      expect(Math.abs(mb - 8)).toBeLessThanOrEqual(1);

      await snapshot();
    } finally {
      try {
        (document.getElementById('hr') as HTMLElement | null)?.remove();
      } catch (_) {}
      document.documentElement.style.margin = prevDocMargin;
      document.body.style.margin = prevBodyMargin;
      document.body.style.padding = prevBodyPadding;
      document.body.style.fontSize = prevBodyFontSize;
      await resizeViewport(-1, -1);
    }
  });
});

