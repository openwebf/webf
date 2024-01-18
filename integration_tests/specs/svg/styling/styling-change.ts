import _ from 'lodash';

const defaultRect = {
  fill: 'green',
  x: '10',
  y: '10',
  width: '100',
  height: '100',
  rx: '5',
  ry: '5',
}

const cases: Record<string, [
  element: string,
  defaultAttributes: Record<string, string>,
  from: string,
  to: string
]> = {
  width: [
    'rect',
    defaultRect,
    '10', '190'
  ],
  height: [
    'rect',
    defaultRect,
    '10', '190'
  ],
  fill: [
    'rect',
    defaultRect,
    'red', 'green',
  ],
  stroke: [
    'path', {
      'fill': 'none',
      'stroke': 'black',
      'stroke-width': '10',
      'd': 'M 10,10 L 100,10 L 100,100 L 10,100 Z'
    },
    'red',
    'green'
  ],
  'stroke-width': [
    'rect',
    {
      ...defaultRect,
      stroke: 'green'
    },
    '1',
    '20'
  ],
  d: [
    'path',
    {
      'stroke': 'black',
      'stroke-width': '10',
    },
    'M 10,10 L 190,10', 'M 10,100 L 190,100'
  ],
  x: [
    'rect',
    defaultRect,
    '10', '90'
  ],
  y: [
    'rect',
    defaultRect,
    '10', '90'
  ],
  rx: [
    'rect',
    {
      ...defaultRect,
      ry: '40'
    },
    '0', '40'
  ],
  ry: [
    'rect',
    {
      ...defaultRect,
      rx: '40',
    },
    '0', '40'
  ],
  'fill-rule': [
    'path',
    {
      fill: 'green',
      d: 'M110,0  h90 v90 h-90 z M130,20 h50 v50 h-50 z'
    },
    'nonzero', 'evenodd'
  ],
  'stroke-linecap': [
    'path',
    {
      d: 'M 10,100 L 190,100',
      'stroke-width': '20',
      'stroke': 'green'
    },
    'butt', 'square'
  ],
  'stroke-linejoin': [
    'path',
    {
      d: 'M10,50 a20,20 0,0,0 20,-30 a30,30 0 0 1 20,35',
      'stroke-width': '20',
      'stroke': 'green'
    },
    'miter', 'round'
  ]
}

describe('Style change', () => {
  beforeAll(() => {
    resizeViewport(200, 200)
  })

  afterAll(() => {
    resizeViewport()
  })

  for (const [styleName, [element, defaltAttributes, from, to]] of Object.entries(cases)) {
    it(`should support "${styleName}" from "${from}" to "${to}"`, async () => {
      const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
      svg.style.width = '200px';
      svg.style.height = '200px';
      svg.setAttribute('viewBox', '0 0 200 200')
      const ele = document.createElementNS('http://www.w3.org/2000/svg', element);
      for (const [attr, value] of Object.entries(defaltAttributes)) {
        ele.setAttribute(attr, value);
      }
      ele.setAttribute(styleName, from)
      document.body.appendChild(svg)
      svg.appendChild(ele);

      await snapshot(svg, `./snapshots/svg/styling/should support_${styleName}_from_${_.snakeCase(from)}_to_${_.snakeCase(to)}`);

      ele.setAttribute(styleName, to);

      await snapshot(svg, `./snapshots/svg/styling/should support_${styleName}_from_${_.snakeCase(from)}_to_${_.snakeCase(to)}`);
    })
  }
})
