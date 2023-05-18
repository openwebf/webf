// WPT
import { PROPERTIES, assertPresentationAttributeIsSupported } from './presentation-attributes'

describe('SVG presentation attributes irrelevant', () => {
  beforeEach(() => {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    document.body.appendChild(svg);
    // presentation-attributes is depond on global svg
    globalThis.svg = svg
  })

  for (let p in PROPERTIES) {
    // if (CSS.supports(p, "initial")) {
    if (PROPERTIES[p].irrelevantElement) {
      test(function() {
        assertPresentationAttributeIsSupported(PROPERTIES[p].irrelevantElement, p, PROPERTIES[p].value, p);
      }, `${p} presentation attribute supported on an irrelevant element`);
    }
  }
})
