describe('MediaQuery prefers-reduced-motion', () => {
  // WPT: css/mediaqueries/prefers-reduced-motion.html
  it('applies prefers-reduced-motion media rules', async () => {
    const cssText = `
    .mq-box {
      width: 120px;
      height: 120px;
      background-color: rgb(255, 0, 0);
    }

    @media (prefers-reduced-motion: reduce) {
      .mq-box {
        background-color: rgb(0, 128, 0);
      }
    }

    @media (prefers-reduced-motion: no-preference) {
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
    }, [createText('prefers-reduced-motion')]);
    BODY.appendChild(box);

    await nextFrames(2);

    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const noPref = window.matchMedia('(prefers-reduced-motion: no-preference)').matches;
    const booleanContext = window.matchMedia('(prefers-reduced-motion)').matches;

    expect(reduce || noPref).toBe(true);
    expect(booleanContext).toBe(!noPref);

    const expected = reduce ? 'rgb(0, 128, 0)' : 'rgb(0, 0, 255)';
    expect(getComputedStyle(box).backgroundColor).toBe(expected);
  });
});
