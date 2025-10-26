describe('flutter-intrinsic sizing', () => {
  it('flow: expands to nested element size', async () => {
    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';
    host.style.padding = '0';
    host.style.margin = '0';
    host.style.border = '0';

    const content = document.createElement('div');
    content.style.width = '123px';
    content.style.height = '45px';
    content.style.background = '#eee';

    host.appendChild(content);
    document.body.appendChild(host);

    await waitForOnScreen(host);
    await sleep(0.05);

    // 10+8 + nested + 8 + 10 = nested + 36
    expect(host.offsetWidth).toBe(content.offsetWidth + 36);
    expect(host.offsetHeight).toBe(content.offsetHeight);
    await snapshot();
  });

  it('flex item: uses nested size as its flex base (no stretch)', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.alignItems = 'flex-start';
    container.style.gap = '0px';

    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';
    host.style.padding = '0';
    host.style.margin = '0';
    host.style.border = '0';

    const content = document.createElement('div');
    content.style.width = '80px';
    content.style.height = '30px';
    content.style.background = '#eee';
    host.appendChild(content);

    // A sibling flex item to avoid container collapsing assumptions
    const sibling = document.createElement('div');
    sibling.style.width = '40px';
    sibling.style.height = '10px';
    sibling.style.background = 'red';

    container.appendChild(host);
    container.appendChild(sibling);
    document.body.appendChild(container);

    await waitForOnScreen(container);
    await sleep(0.05);

    // 10+8 + nested + 8 + 10 = nested + 36
    expect(host.offsetWidth).toBe(content.offsetWidth + 36);
    expect(host.offsetHeight).toBe(content.offsetHeight);
    await snapshot();
  });

  it('image (replaced): respects intrinsic/explicit size', async () => {
    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';

    const img = document.createElement('img');
    // Use a 1x1 PNG data URL and scale via attributes to deterministic size
    img.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    img.width = 50; // CSS width 50px
    img.height = 40; // CSS height 40px

    host.appendChild(img);
    document.body.appendChild(host);

    await waitForOnScreen(host);
    await sleep(0.05);

    // 10+8 + nested + 8 + 10 = nested + 36
    expect(host.offsetWidth).toBe(img.offsetWidth + 36);
    expect(host.offsetHeight).toBe(img.offsetHeight);
    await snapshot();
  });

  it('text content: host equals text span size', async () => {
    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';
    host.style.padding = '0';
    host.style.margin = '0';
    host.style.border = '0';

    const span = document.createElement('span');
    span.textContent = 'Hello Intrinsic';
    span.style.whiteSpace = 'nowrap';
    // Optional: larger font to get measurable width/height.
    span.style.fontSize = '20px';

    host.appendChild(span);
    document.body.appendChild(host);

    await waitForOnScreen(host);
    await sleep(0.05);

    // Both are measured by the same engine; sizes should match.
    // 10+8 + nested + 8 + 10 = nested + 36
    expect(host.offsetWidth).toBe(span.offsetWidth + 36);
    expect(host.offsetHeight).toBe(span.offsetHeight);
    await snapshot();
  });

  it('IntrinsicHeight: expands to nested element height', async () => {
    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';
    host.style.padding = '0';
    host.style.margin = '0';
    host.style.border = '0';

    const content = document.createElement('div');
    // Width arbitrary; height drives intrinsic height.
    content.style.width = '10px';
    content.style.height = '120px';
    content.style.background = '#ddd';

    host.appendChild(content);
    document.body.appendChild(host);

    await waitForOnScreen(host);
    await sleep(0.05);

    expect(host.offsetHeight).toBe(content.offsetHeight);
    await snapshot();
  });

  it('IntrinsicWidth + IntrinsicHeight: expand both dimensions', async () => {
    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';
    host.style.padding = '0';
    host.style.margin = '0';
    host.style.border = '0';

    const content = document.createElement('div');
    content.style.width = '150px';
    content.style.height = '80px';
    content.style.background = '#aac';

    host.appendChild(content);
    document.body.appendChild(host);

    await waitForOnScreen(host);
    await sleep(0.05);

    // 10+8 + nested + 8 + 10 = nested + 36
    expect(host.offsetWidth).toBe(content.offsetWidth + 36);
    expect(host.offsetHeight).toBe(content.offsetHeight);
    await snapshot();
  });

  it('IntrinsicHeight (flex): host height equals nested height', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.alignItems = 'flex-start'; // avoid cross-axis stretch
    container.style.gap = '0px';

    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';
    host.style.padding = '0';
    host.style.margin = '0';
    host.style.border = '0';

    const content = document.createElement('div');
    content.style.width = '40px';
    content.style.height = '70px';
    content.style.background = '#e0e0e0';
    host.appendChild(content);

    const spacer = document.createElement('div');
    spacer.style.width = '10px';
    spacer.style.height = '10px';
    container.appendChild(host);
    container.appendChild(spacer);
    document.body.appendChild(container);

    await waitForOnScreen(container);
    await sleep(0.05);

    expect(host.offsetHeight).toBe(content.offsetHeight);
    await snapshot();
  });

  it('IntrinsicHeight (image): host height equals image height', async () => {
    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';

    const img = document.createElement('img');
    img.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    img.style.display = 'block';
    img.style.width = '50px';
    img.style.height = '60px';

    host.appendChild(img);
    document.body.appendChild(host);

    await waitForOnScreen(host);
    await sleep(0.05);

    expect(host.offsetHeight).toBe(img.offsetHeight);
    await snapshot();
  });

  it('IntrinsicHeight (text): host height equals text height', async () => {
    const host = document.createElement('flutter-intrinsic-container');
    host.style.display = 'inline-block';
    host.style.padding = '0';
    host.style.margin = '0';
    host.style.border = '0';

    const span = document.createElement('span');
    span.textContent = 'Intrinsic height text';
    span.style.display = 'inline-block';
    span.style.fontSize = '18px';
    span.style.whiteSpace = 'nowrap';

    host.appendChild(span);
    document.body.appendChild(host);

    await waitForOnScreen(host);
    await sleep(0.05);

    expect(host.offsetHeight).toBe(span.offsetHeight);
    await snapshot();
  });
});
