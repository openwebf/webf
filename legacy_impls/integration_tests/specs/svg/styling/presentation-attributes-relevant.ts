// WPT
import { PROPERTIES, assertPresentationAttributeIsSupported } from './presentation-attributes'

describe('SVG presentation attributes relevant', () => {
  beforeEach(() => {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    document.body.appendChild(svg);
    // presentation-attributes is depond on global svg
    globalThis.svg = svg
  })

  for (let p in PROPERTIES) {
    // if (CSS.supports(p, "initial")) {
    test(function () {
      assertPresentationAttributeIsSupported(PROPERTIES[p].relevantElement, p, PROPERTIES[p].value, p);
    }, `${p} presentation attribute supported on a relevant element`);
    // }
  }
})
