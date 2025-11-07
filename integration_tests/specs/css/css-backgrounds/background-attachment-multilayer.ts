describe('Background-attachment multilayer', () => {
  // Different attachment per-layer; keep skipped until supported.
  it('fixed and local attachments on two layers', async () => {
    const scroller = createElement('div', {
      style: {
        width: '260px',
        height: '180px',
        overflow: 'auto',
        border: '1px solid #ccc'
      }
    });

    const content = createElement('div', {
      style: {
        height: '600px',
        backgroundImage: 'url(assets/cat.png), linear-gradient(0deg, #ff0, #0ff)',
        backgroundRepeat: 'no-repeat, repeat',
        backgroundPosition: 'center 40px, 0 0',
        backgroundSize: '120px 90px, 20px 20px',
        backgroundAttachment: 'fixed, local'
      }
    });

    append(scroller, content);
    append(BODY, scroller);
    await snapshot(scroller);
    scroller.scrollTop = 80;
    await waitForFrame();
    await snapshot(scroller);
  });
});

