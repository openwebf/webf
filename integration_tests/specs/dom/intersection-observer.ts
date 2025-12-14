describe('IntersectionObserver', () => {
  function createSpacer(heightPx: number) {
    const spacer = document.createElement('div')
    spacer.style.height = `${heightPx}px`
    return spacer
  }

  function createObserved(id: string, style: Partial<CSSStyleDeclaration> = {}) {
    const el = document.createElement('div')
    el.id = id
    Object.assign(el.style, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      ...style,
    })
    return el
  }

  async function waitForCondition(predicate: () => boolean, timeoutSeconds = 2) {
    const timeoutMs = timeoutSeconds * 1000
    const start = Date.now()
    while (!predicate()) {
      await waitForFrame()
      if (Date.now() - start > timeoutMs) {
        throw new Error('Timeout waiting for condition')
      }
    }
  }

  it('should trigger callback when element intersects', async () => {
    const observed = createObserved('observed', {
      width: '200px',
      height: '200px',
      backgroundColor: 'red',
    })
    document.body.appendChild(observed)

    let lastEntry: IntersectionObserverEntry | null = null
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.target !== observed) continue
          lastEntry = entry
        }
      },
      {
        root: null,
        rootMargin: '0px',
        threshold: [0],
      }
    )

    observer.observe(observed)

    await waitForCondition(() => lastEntry != null)
    expect(lastEntry!.target).toBe(observed)
    expect(lastEntry!.isIntersecting).toBe(true)
    expect(lastEntry!.intersectionRatio).toBeGreaterThan(0)

    observer.disconnect()
  })

  it('fires initial callback even when not intersecting', async () => {
    document.body.appendChild(createSpacer(1000))
    const observed = createObserved('observed_offscreen', {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
    })
    document.body.appendChild(observed)

    let lastEntry: IntersectionObserverEntry | null = null
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.target !== observed) continue
          lastEntry = entry
        }
      },
      { threshold: [0] }
    )

    observer.observe(observed)

    await waitForCondition(() => lastEntry != null)
    expect(lastEntry!.target).toBe(observed)
    expect(lastEntry!.isIntersecting).toBe(false)
    expect(lastEntry!.intersectionRatio).toBe(0)

    observer.disconnect()
  })

  it('updates isIntersecting when scrolling', async () => {
    // Place element far enough so initial state is not intersecting, regardless of viewport size.
    document.body.appendChild(createSpacer(2000))
    const observed = createObserved('observed_scroll', {
      width: '100px',
      height: '100px',
      backgroundColor: 'green',
    })
    document.body.appendChild(observed)
    document.body.appendChild(createSpacer(2000))

    const states: boolean[] = []
    const observer = new IntersectionObserver(
      (newEntries) => {
        for (const entry of newEntries) {
          if (entry.target !== observed) continue
          states.push(entry.isIntersecting)
        }
      },
      { threshold: [0] }
    )
    observer.observe(observed)

    await waitForCondition(() => states.length >= 1)
    expect(states[0]).toBe(false)

    window.scrollTo(0, Math.max(0, observed.offsetTop - 10))
    await waitForCondition(() => states.slice(1).includes(true))

    observer.disconnect()
  })

  it('unobserve stops callbacks for target', async () => {
    const observed = createObserved('observed_unobserve', {
      width: '100px',
      height: '100px',
      backgroundColor: 'purple',
    })
    document.body.appendChild(observed)
    document.body.appendChild(createSpacer(1600))

    let observedEntryCount = 0
    let afterUnobserveCount = 0
    let afterUnobserve = false

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.target !== observed) continue
          observedEntryCount++
          if (afterUnobserve) afterUnobserveCount++
        }
      },
      { threshold: [0] }
    )

    observer.observe(observed)

    await waitForCondition(() => observedEntryCount >= 1)

    window.scrollTo(0, 1200)
    await waitForFrame()
    await waitForCondition(() => observedEntryCount >= 2)

    await waitForFrame()
    observer.unobserve(observed)
    afterUnobserve = true

    window.scrollTo(0, 0)
    await waitForFrame()
    await sleep(0.2)

    expect(afterUnobserveCount).toBe(0)

    observer.disconnect()
  })

  it('disconnect stops callbacks for all targets', async () => {
    const observed = createObserved('observed_disconnect', {
      width: '100px',
      height: '100px',
      backgroundColor: 'orange',
    })
    document.body.appendChild(observed)
    document.body.appendChild(createSpacer(1600))

    let observedEntryCount = 0
    let afterDisconnectCount = 0
    let afterDisconnect = false

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.target !== observed) continue
          observedEntryCount++
          if (afterDisconnect) afterDisconnectCount++
        }
      },
      { threshold: [0] }
    )

    observer.observe(observed)

    await waitForCondition(() => observedEntryCount >= 1)

    await waitForFrame()
    observer.disconnect()
    afterDisconnect = true

    window.scrollTo(0, 1200)
    await waitForFrame()
    window.scrollTo(0, 0)
    await waitForFrame()
    await sleep(0.2)

    expect(afterDisconnectCount).toBe(0)
  })

  it('delivers entries for multiple targets', async () => {
    const observedA = createObserved('observed_a', {
      width: '80px',
      height: '80px',
      backgroundColor: 'red',
    })
    const observedB = createObserved('observed_b', {
      width: '80px',
      height: '80px',
      backgroundColor: 'blue',
    })

    document.body.appendChild(observedA)
    document.body.appendChild(createSpacer(600))
    document.body.appendChild(observedB)
    document.body.appendChild(createSpacer(600))

    const seen = new Set<Element>()
    let resolved = false
    let resolveSeen: (() => void) | null = null
    const seenPromise = new Promise<void>((resolve) => {
      resolveSeen = resolve
    })

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.target === observedA || entry.target === observedB) {
            seen.add(entry.target)
          }
        }

        if (!resolved && seen.size === 2) {
          resolved = true
          observer.disconnect()
          resolveSeen?.()
        }
      },
      { threshold: [0] }
    )

    observer.observe(observedA)
    observer.observe(observedB)

    await Promise.race([
      seenPromise,
      sleep(2).then(() => {
        throw new Error('Timeout waiting for IntersectionObserver entries')
      }),
    ])

    expect(seen.has(observedA)).toBe(true)
    expect(seen.has(observedB)).toBe(true)
  })

  it('img loading=lazy does not load until visible', async () => {
    document.body.appendChild(createSpacer(2000))

    const img = document.createElement('img')
    img.setAttribute('loading', 'lazy')
    img.style.width = '100px'
    img.style.height = '100px'
    img.style.display = 'block'

    let loaded = false
    img.addEventListener('load', () => {
      loaded = true
    })

    // Start the request while still offscreen; should not complete immediately.
    img.src = 'assets/100x100-green.png'
    document.body.appendChild(img)
    document.body.appendChild(createSpacer(2000))

    await sleep(0.8)
    expect(loaded).toBe(false)

    // Scroll the image into view; should load before the 3s fallback kicks in.
    window.scrollTo(0, Math.max(0, img.offsetTop - 10))
    await waitForCondition(() => loaded === true, 2)

    expect(loaded).toBe(true)
  })
})
