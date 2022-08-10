/*auto generated*/
describe('child-indexed', () => {
  it('pseudo-class', async () => {
    var check = function (element, selectors, qsRoot) {
      for (var i = 0; i < selectors.length; ++i) {
        var selector = selectors[i][0];
        var expected = selectors[i][1];
        test(function () {
          assert_equals(expected, element.matches(selector));

          if (qsRoot) {
            assert_equals(expected, element === qsRoot.querySelector(selector));
            var qsa = qsRoot.querySelectorAll(selector);
            assert_equals(expected, !!qsa.length && element === qsa[0]);
          }
        }, 'Expected ' +
          element.tagName +
          ' element to ' +
          (expected ? 'match ' : 'not match ') +
          selector +
          ' with matches' +
          (qsRoot ? ', querySelector(), and querySelectorAll()' : ''));
      }
    };

    var rootOfSubtreeSelectors = [
      [':first-child', true],
      [':last-child', true],
      [':only-child', true],
      [':first-of-type', true],
      [':last-of-type', true],
      [':only-of-type', true],
      [':nth-child(1)', true],
      [':nth-child(n)', true],
      [':nth-last-child(1)', true],
      [':nth-last-child(n)', true],
      [':nth-of-type(1)', true],
      [':nth-of-type(n)', true],
      [':nth-last-of-type(1)', true],
      [':nth-last-of-type(n)', true],
      [':nth-child(2)', false],
      [':nth-last-child(2)', false],
      [':nth-of-type(2)', false],
      [':nth-last-of-type(2)', false],
    ];

    check(document.documentElement, rootOfSubtreeSelectors, document);
    check(document.createElement('div'), rootOfSubtreeSelectors);

    var fragment = document.createDocumentFragment();
    var div = document.createElement('div');
    fragment.appendChild(div);
    check(div, rootOfSubtreeSelectors, fragment);

    await matchViewportSnapshot();
  });

  it('no-parent-ref', async () => {
    let p;
    let p_1;
    let p_2;
    let p_3;
    let p_4;
    let p_5;
    let p_6;
    let p_7;
    let p_8;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_1 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_2 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_3 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_4 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_5 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_6 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_7 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    p_8 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Should be green
`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);
    BODY.appendChild(p_2);
    BODY.appendChild(p_3);
    BODY.appendChild(p_4);
    BODY.appendChild(p_5);
    BODY.appendChild(p_6);
    BODY.appendChild(p_7);
    BODY.appendChild(p_8);

    await matchViewportSnapshot();
  });
});
