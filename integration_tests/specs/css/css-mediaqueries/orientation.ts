describe('MediaQuery orientation', () => {
  // WPT: css/mediaqueries/test_media_queries.html (orientation section)
  it('applies portrait/landscape rules based on viewport', async () => {
    const cssText = `
    .mq-box {
      width: 120px;
      height: 120px;
      background-color: rgb(255, 0, 0);
    }

    @media (orientation: landscape) {
      .mq-box {
        background-color: rgb(0, 128, 0);
      }
    }

    @media (orientation: portrait) {
      .mq-box {
        background-color: rgb(0, 0, 255);
      }
    }
    `;
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.append(style);

    const box = createElement('div', {
      className: 'mq-box'
    }, [createText('orientation')]);
    BODY.appendChild(box);

    await nextFrames(2);

    await resizeViewport(800, 400);
    expect(getComputedStyle(box).backgroundColor).toBe('rgb(0, 128, 0)');

    await resizeViewport(400, 800);
    expect(getComputedStyle(box).backgroundColor).toBe('rgb(0, 0, 255)');

    await resizeViewport(-1, -1);
  });
});
