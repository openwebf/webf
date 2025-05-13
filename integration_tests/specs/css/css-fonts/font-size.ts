describe('FontSize', () => {
  it('should work with english', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontSize: '24px',
      },
      createText('These text should be 24px.')
    );
    append(BODY, p1);

    return snapshot();
  });

  it('should work with chinese', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontSize: '24px',
      },
      createText('24号字。')
    );
    append(BODY, p1);

    return snapshot();
  });

  it('should work with less than 12px', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontSize: '12px',
      },
      createText('These lines should with 12px text size.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontSize: '5px',
      },
      createText('These lines should with 5px text size.')
    );

    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('should work with percentage', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          fontSize: '50px',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
            fontSize: '50%',
          }
        }, [
          createText('Kraken')
        ])
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage after element is attached', async (done) => {
    let div2;
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          fontSize: '50px',
          position: 'relative',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          }
        }, [
          createText('Kraken')
        ]))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div2.style.fontSize = '50%';
      await snapshot();
      done();
    });
  });

  it('works with inheritance', async (done) => {
    let div1;
    let div2;
    let div = createElement('div', {
      style: {
        position: 'relative',
        width: '300px',
        height: '200px',
        backgroundColor: 'grey',
      }
    }, [
      (div1 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightgreen',
        }
      }, [
        createText('inherited font-size')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          fontSize: '16px',
        }
      }, [
        createText('not inherited font-size')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        fontSize: '18px'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.fontSize = '24px';
      await snapshot();
      done();
    });
  });

  it('should works with absolute-size keyword', async () => {
    for (const fontSize of ['xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large', 'xxx-large']) {
      const div = createElement('div', {
        style: {
          fontSize: fontSize
        }
      }, [
        createText(fontSize)
      ]);
      BODY.appendChild(div);
    }

    await snapshot();
  });

  it('should works with relative-size keyword', async () => {
    for (const parentSize of ['16px', '32px', '48px']) {
      const div = createElement('div', {
        style: {
          fontSize: parentSize
        }
      }, [
        createElement('div', {
          style: {
            fontSize: 'smaller'
          }
        }, [createText(`${parentSize} smaller`)]),
        createElement('div', {}, [createText(`${parentSize}`)]),
        createElement('div', {
          style: {
            fontSize: 'larger'
          }
        }, [createText(`${parentSize} larger`)])
      ]);
      BODY.appendChild(div);
    }

    await snapshot();
  });

  it("computed", async (done) => {
    let target;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'font-size': '40px',
          'box-sizing': 'border-box',
        },
      },
      [
        (target = createElement('div', {
          id: 'target',
          style: {
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    function test_relative_size(first, second) {
      const target = document.getElementById('target');
      target!.style.fontSize = first;
      const firstResult = Number(
        getComputedStyle(target!).fontSize.replace('px', '')
      );
      target!.style.fontSize = second;
      const secondResult = Number(
        getComputedStyle(target!).fontSize.replace('px', '')
      );
      expect(firstResult).toBeLessThanOrEqual(secondResult);
    }

    container.addEventListener('onscreen', () => {

      test_relative_size('xx-small', 'x-small');
      test_relative_size('x-small', 'small');
      test_relative_size('small', 'medium');
      test_relative_size('medium', 'large');
      test_relative_size('large', 'x-large');
      test_relative_size('x-large', 'xx-large');
      // Added in Fonts level 4: https://github.com/w3c/csswg-drafts/issues/3907
      test_relative_size('xx-large', 'xxx-large');
  
      // <relative-size>
      test_relative_size('inherit', 'larger');
      test_relative_size('smaller', 'inherit');
  
      // <length-percentage>
      test_computed_value('font-size', '10px');
      test_computed_value('font-size', '20%');
      test_computed_value('font-size', 'calc(30% - 40px)', '-28px');
      test_computed_value('font-size', 'calc(30% + 40px)', '52px');
      test_computed_value('font-size', 'calc(10px - 0.5em)', '-10px');
      test_computed_value('font-size', 'calc(10px + 0.5em)', '30px');
  
      // function test_font_size(attribute, keyword) {
      //   const reference = document.getElementById('reference');
      //   reference!.setAttribute('size', attribute);
      //   const target = document.getElementById('target');
      //   target!.style.fontSize = keyword;
      //   expect(getComputedStyle(target!).fontSize).toBe(getComputedStyle(reference!).fontSize);
      // }
  
      // test_font_size('2', 'small');
      // test_font_size('3', 'medium');
      // test_font_size('4', 'large');
      // test_font_size('5', 'x-large');
      // test_font_size('6', 'xx-large');
      // test_font_size('7', 'xxx-large');

      done();
    });

  })
});
