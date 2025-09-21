describe('Background shorthand resets', () => {
  it('background: none resets images and subproperties to initial', async (done) => {
    const target = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'left top / 20px 20px no-repeat url(assets/100x100-green.png)',
        backgroundColor: 'red'
      }
    });
    append(BODY, target);

    target.ononscreen = () => {
      // Apply background: none and verify computed values
      target.style.background = 'none';
      const cs = window.getComputedStyle(target);
      expect(cs.getPropertyValue('background-image')).toBe('none');
      expect(cs.getPropertyValue('background-repeat')).toBe('repeat');
      expect(cs.getPropertyValue('background-attachment')).toBe('scroll');
      expect(cs.getPropertyValue('background-position')).toBe('0% 0%');
      // size is a list with / auto in shorthand; computed typically 'auto'
      expect(cs.getPropertyValue('background-size')).toBe('auto');
      // color should reset to transparent as not specified
      expect(cs.getPropertyValue('background-color')).toBe('rgba(0, 0, 0, 0)');
      done();
    };
  });

  it('setting background color via shorthand resets other subproperties', async (done) => {
    const target = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        backgroundImage: 'url(assets/100x100-green.png)',
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'center',
      }
    });
    append(BODY, target);

    target.ononscreen = () => {
      target.style.background = 'rgb(255, 0, 0)';
      const cs = window.getComputedStyle(target);
      expect(cs.getPropertyValue('background-color')).toBe('rgb(255, 0, 0)');
      expect(cs.getPropertyValue('background-image')).toBe('none');
      expect(cs.getPropertyValue('background-repeat')).toBe('repeat');
      expect(cs.getPropertyValue('background-position')).toBe('0% 0%');
      expect(cs.getPropertyValue('background-size')).toBe('auto');
      done();
    };
  });
});

