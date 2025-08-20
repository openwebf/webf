describe('FontWeight', () => {
  const WEIGHTS = [
    'normal',
    'medium',
    'light',
    'bold',
    'lighter',
    'bolder',
    'alibaba',
    1,
    100,
    100.6,
    123,
    200,
    300,
    321,
    400,
    500,
    600,
    700,
    800,
    900,
    1000,
    10000,
  ];

  WEIGHTS.forEach(value => {
    it(`should work with ${value}`, () => {
      const p1 = createElementWithStyle(
        'p',
        {
          fontSize: '24px',
          fontWeight: value,
        },
        createText(`These text weight should be ${value}.`)
      );
      const p2 = createElementWithStyle(
        'p',
        {
          fontSize: '24px',
          fontWeight: value,
        },
        createText(`文本的 fontWeight 是: ${value}`)
      );
      append(BODY, p1);
      append(BODY, p2);

      return snapshot();
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
        createText('inherited font-weight')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          fontWeight: 'normal',
        }
      }, [
        createText('not inherited font-weigth')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        fontWeight: 'lighter'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.fontWeight = 'bold';
      await snapshot();
      done();
    });
  });

  it("computed", async () => {
    let target;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
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

    test_computed_value('font-weight', 'normal', '400');
    test_computed_value('font-weight', 'bold', '700');
    test_computed_value('font-weight', '100');
    test_computed_value('font-weight', '200');
    test_computed_value('font-weight', '300');
    test_computed_value('font-weight', '400');
    test_computed_value('font-weight', '500');
    test_computed_value('font-weight', '600');
    test_computed_value('font-weight', '700');
    test_computed_value('font-weight', '800');
    test_computed_value('font-weight', '900');

    // function test_relative(specified, inherited, computed) {
    //     const container = document.getElementById('container');
    //     const target = document.getElementById('target');
    //     container!.style.fontWeight = inherited;
    //     target!.style.fontWeight = specified;
    //     expect(getComputedStyle(target!).fontWeight).toEqual(computed);
    // }

    // test_relative('bolder', '100', '400');
    // test_relative('bolder', '200', '400');
    // test_relative('bolder', '300', '400');
    // test_relative('bolder', '400', '700');
    // test_relative('bolder', '500', '700');
    // test_relative('bolder', '600', '900');
    // test_relative('bolder', '700', '900');
    // test_relative('bolder', '800', '900');
    // test_relative('bolder', '900', '900');

    // test_relative('lighter', '100', '100');
    // test_relative('lighter', '200', '100');
    // test_relative('lighter', '300', '100');
    // test_relative('lighter', '400', '100');
    // test_relative('lighter', '500', '100');
    // test_relative('lighter', '600', '400');
    // test_relative('lighter', '700', '400');
    // test_relative('lighter', '800', '700');
    // test_relative('lighter', '900', '700');
  })
});
