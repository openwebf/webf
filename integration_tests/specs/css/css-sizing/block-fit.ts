/*auto generated*/
describe('block-fit', () => {
  it('content-as-initial-ref', async (done) => {
    let child;
    let parent;
    parent = createElement(
      'div',
      {
        class: 'parent',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('img', {
          class: 'child',
          src:
            'assets/60x60-green.png',
          style: {
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(parent);

    child.onload = async () => {
      await snapshot(0.1);
      done();
    }
  });
  it('content-as-initial', async (done) => {
    let child;
    let parent;
    parent = createElement(
      'div',
      {
        class: 'parent',
        style: {
          height: 'fit-content',
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('img', {
          class: 'child',
          src:
            'assets/60x60-green.png',
          style: {
            'max-height': '100%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(parent);

    onImageLoad(child, async () => {
      await snapshot(0.1);
      const rect = child.getBoundingClientRect();
      expect(rect.width).toBeGreaterThan(0);
      expect(rect.height).toBeGreaterThan(0);
      done();
    });
  });
});
