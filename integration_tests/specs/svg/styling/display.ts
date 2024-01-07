describe('SVG support display style', () => {
  beforeEach(() => {
    resizeViewport(120, 70)
  })

  afterEach(() => {
    resizeViewport()
  })

  it('should support toggle display', async () => {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    const rect1 = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    const rect2 = document.createElementNS('http://www.w3.org/2000/svg', 'rect');

    svg.setAttribute('viewBox', '0 0 120 70')
    svg.style.width = '120px'
    svg.style.height = '70px'

    rect1.setAttribute('x', '10')
    rect1.setAttribute('y', '10')
    rect1.setAttribute('width', '50')
    rect1.setAttribute('height', '50')
    rect1.setAttribute('fill', 'blue')

    rect2.setAttribute('x', '60')
    rect2.setAttribute('y', '10')
    rect2.setAttribute('width', '50')
    rect2.setAttribute('height', '50')
    rect2.setAttribute('fill', 'green')

    svg.appendChild(rect1)
    svg.appendChild(rect2)

    document.body.appendChild(svg)

    await snapshot()

    rect1.style.display = 'none'

    await snapshot()

    rect1.style.display = ''

    await snapshot()
  })
})
