describe('MediaQuery forced-colors', () => {
  // WPT: css/mediaqueries/forced-colors.html
  it('applies forced-colors active/none rules', async () => {
    const cssText = `
    .mq-box {
      width: 120px;
      height: 120px;
      background-color: rgb(255, 0, 0);
    }

    @media (forced-colors: active) {
      .mq-box {
        background-color: rgb(0, 128, 0);
      }
    }

    @media (forced-colors: none) {
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
    }, [createText('forced-colors')]);
    BODY.appendChild(box);

    await nextFrames(2);
    await snapshot();

    const active = window.matchMedia('(forced-colors: active)').matches;
    const none = window.matchMedia('(forced-colors: none)').matches;
    const booleanContext = window.matchMedia('(forced-colors)').matches;

    expect(active || none).toBe(true);
    expect(active).toBe(!none);
    expect(booleanContext).toBe(!none);

    const expected = active ? 'rgb(0, 128, 0)' : 'rgb(0, 0, 255)';
    expect(getComputedStyle(box).backgroundColor).toBe(expected);
  });
});
