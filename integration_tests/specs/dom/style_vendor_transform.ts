// Repro for https://github.com/openwebf/webf/issues/532
// Reading an unsupported style property from element.style should yield undefined,
// not an empty string. Standard properties should exist and be empty when unset.

describe('Element.style vendor transform properties (issue #532)', () => {
  it('unsupported vendor-prefixed properties are undefined; standard exists', async () => {
    const el = document.createElement('div');

    // Standard property should exist on CSSStyleDeclaration and be empty when unset.
    expect(el.style.transform).toBe('');

    // Vendor-prefixed properties should be undefined if not supported/implemented.
    // Access via bracket to avoid TS lib type narrowing.
    const styleAny = el.style as any;
    expect(styleAny['webkitTransform']).toBeUndefined();
    expect(styleAny['MozTransform']).toBeUndefined();
    expect(styleAny['msTransform']).toBeUndefined();
    expect(styleAny['OTransform']).toBeUndefined();

    // Simulate common vendor detection logic from the issue body.
    const transformNames: Record<string, string> = {
      webkit: 'webkitTransform',
      Moz: 'MozTransform',
      O: 'OTransform',
      ms: 'msTransform',
      standard: 'transform',
    };
    let picked: string | false = false;
    for (const key in transformNames) {
      if (styleAny[transformNames[key]] !== undefined) {
        picked = key;
        break;
      }
    }

    // Expect the standard property to be detected.
    expect(picked).toBe('standard');

    // Minimal DOM attach + snapshot for parity with other specs.
    document.body.appendChild(el);
  });
});

