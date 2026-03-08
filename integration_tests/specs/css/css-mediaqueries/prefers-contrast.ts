describe('MediaQuery prefers-contrast', () => {
  // WPT: css/mediaqueries/prefers-contrast.html
  it('applies prefers-contrast media rules', async () => {
    const cssText = `
    .mq-box {
      width: 120px;
      height: 120px;
      background-color: rgb(255, 0, 0);
    }

    @media (prefers-contrast: more) {
      .mq-box {
        background-color: rgb(0, 128, 0);
      }
    }

    @media (prefers-contrast: less) {
      .mq-box {
        background-color: rgb(0, 0, 255);
      }
    }

    @media (prefers-contrast: custom) {
      .mq-box {
        background-color: rgb(255, 165, 0);
      }
    }

    @media (prefers-contrast: no-preference) {
      .mq-box {
        background-color: rgb(128, 128, 128);
      }
    }
    `;
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.append(style);

    const box = createElement('div', {
      className: 'mq-box'
    }, [createText('prefers-contrast')]);
    BODY.appendChild(box);

    await nextFrames(2);

    const more = window.matchMedia('(prefers-contrast: more)').matches;
    const less = window.matchMedia('(prefers-contrast: less)').matches;
    const custom = window.matchMedia('(prefers-contrast: custom)').matches;
    const noPref = window.matchMedia('(prefers-contrast: no-preference)').matches;
    const booleanContext = window.matchMedia('(prefers-contrast)').matches;

    const matches = [more, less, custom, noPref].filter(Boolean);
    expect(matches.length).toBe(1);
    expect(noPref).toBe(!booleanContext);

    const expected = more
      ? 'rgb(0, 128, 0)'
      : less
        ? 'rgb(0, 0, 255)'
        : custom
          ? 'rgb(255, 165, 0)'
          : 'rgb(128, 128, 128)';

    expect(getComputedStyle(box).backgroundColor).toBe(expected);
  });
});
