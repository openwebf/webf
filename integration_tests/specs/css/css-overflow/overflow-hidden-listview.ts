describe('overflow hidden inside webf-listview', () => {
  it('child with overflow hidden and margins should size correctly', async () => {
    // Regression: overflow:hidden children inside webf-listview had their
    // content height collapsed to 0, leaving only margins in the wrapper size.
    const listview = createElement('webf-listview', {
      style: {
        width: '300px',
        height: '400px',
        background: '#eee',
      }
    });

    // Child with overflow:hidden, margins, and padding — the exact pattern
    // that triggered the bug where RenderLayoutBoxWrapper used scrollableSize
    // (Size.zero) instead of the child's actual laid-out size.
    const card = createElement('div', {
      style: {
        marginTop: '16px',
        marginBottom: '20px',
        padding: '24px 20px',
        overflow: 'hidden',
        background: '#3b82f6',
        borderRadius: '12px',
      }
    }, [
      createElement('div', {
        style: {
          fontSize: '20px',
          fontWeight: '700',
          color: '#fff',
        }
      }, [createText('Title')]),
      createElement('p', {
        style: {
          fontSize: '14px',
          color: 'rgba(255,255,255,0.85)',
          margin: '0',
          lineHeight: '1.5',
        }
      }, [createText('Description text that should be visible inside the card.')])
    ]);

    listview.appendChild(card);
    BODY.appendChild(listview);

    await sleep(0.2);

    // The card's offsetHeight must include padding + content, not just 0.
    // With 24px top padding + content + 24px bottom padding, it should be
    // well above the collapsed value of 0 (which produced a wrapper of 36 = margins only).
    expect(card.offsetHeight).toBeGreaterThan(48);

    await snapshot();
  });

  it('child with overflow hidden and position relative should size correctly', async () => {
    // The original bug scenario: overflow:hidden + position:relative with
    // absolutely-positioned decorative elements inside.
    const listview = createElement('webf-listview', {
      style: {
        width: '300px',
        height: '400px',
        background: '#f5f5f5',
      }
    });

    const hero = createElement('div', {
      style: {
        marginTop: '16px',
        marginBottom: '20px',
        padding: '24px 20px',
        borderRadius: '20px',
        background: 'linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%)',
        position: 'relative',
        overflow: 'hidden',
      }
    }, [
      // Absolutely positioned decorative circle (should not affect height)
      createElement('div', {
        style: {
          position: 'absolute',
          top: '-20px',
          right: '-20px',
          width: '100px',
          height: '100px',
          borderRadius: '50%',
          backgroundColor: 'rgba(255,255,255,0.1)',
        }
      }),
      // Normal flow content that determines height
      createElement('div', {
        style: {
          fontSize: '24px',
          fontWeight: '800',
          color: '#fff',
          marginBottom: '8px',
        }
      }, [createText('WebF Showcase')]),
      createElement('p', {
        style: {
          fontSize: '14px',
          color: 'rgba(255,255,255,0.85)',
          margin: '0',
          lineHeight: '1.5',
        }
      }, [createText('Explore components, CSS features, and more.')])
    ]);

    listview.appendChild(hero);
    BODY.appendChild(listview);

    await sleep(0.2);

    // The hero card must reflect its full content height (padding + text content),
    // not collapse to 0 due to the overflow:hidden scrollable wrapper.
    expect(hero.offsetHeight).toBeGreaterThan(60);

    await snapshot();
  });

  it('mixed children with and without overflow hidden should all size correctly', async () => {
    const listview = createElement('webf-listview', {
      style: {
        width: '300px',
        height: '500px',
        background: '#fafafa',
      }
    });

    // Child 1: overflow:hidden with margins
    const child1 = createElement('div', {
      style: {
        margin: '10px 0',
        padding: '20px',
        overflow: 'hidden',
        background: '#4caf50',
        borderRadius: '8px',
        color: '#fff',
      }
    }, [createText('Overflow hidden child')]);

    // Child 2: normal child without overflow
    const child2 = createElement('div', {
      style: {
        margin: '10px 0',
        padding: '20px',
        background: '#2196f3',
        borderRadius: '8px',
        color: '#fff',
      }
    }, [createText('Normal child')]);

    // Child 3: overflow:hidden child after normal child
    const child3 = createElement('div', {
      style: {
        margin: '10px 0',
        padding: '20px',
        overflow: 'hidden',
        background: '#ff9800',
        borderRadius: '8px',
        color: '#fff',
      }
    }, [createText('Another overflow hidden child')]);

    listview.appendChild(child1);
    listview.appendChild(child2);
    listview.appendChild(child3);
    BODY.appendChild(listview);

    await sleep(0.2);

    // All three children should have similar heights (padding + text content).
    // The overflow:hidden children must not collapse.
    expect(child1.offsetHeight).toBeGreaterThan(20);
    expect(child2.offsetHeight).toBeGreaterThan(20);
    expect(child3.offsetHeight).toBeGreaterThan(20);

    // The overflow:hidden children should be roughly the same height as the normal one,
    // since they have identical padding and single-line text content.
    const tolerance = 5;
    expect(Math.abs(child1.offsetHeight - child2.offsetHeight)).toBeLessThanOrEqual(tolerance);
    expect(Math.abs(child3.offsetHeight - child2.offsetHeight)).toBeLessThanOrEqual(tolerance);

    // Child 2 should be positioned below child 1, not overlapping.
    expect(child2.offsetTop).toBeGreaterThan(child1.offsetTop + child1.offsetHeight - 1);

    await snapshot();
  });
});
