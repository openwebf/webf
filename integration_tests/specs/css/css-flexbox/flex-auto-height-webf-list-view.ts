describe('flex auto-height inside webf-list-view bounded constraints', () => {
  it('flex item should shrink-wrap instead of stretching to max-height', async () => {
    document.body.style.margin = '0';
    document.body.style.padding = '0';
    document.body.style.background = '#fff';

    const list = document.createElement('webf-list-view');
    list.setAttribute('shrink-wrap', 'true');
    (list as HTMLElement).style.display = 'block';

    // A row flex container with align-items: stretch but no definite height.
    // Under sliver/list constraints, items often receive a finite maxHeight.
    // The child should NOT treat that bounded maxHeight as a definite height
    // and stretch its auto height.
    const item = document.createElement('div');
    item.style.cssText = `
      display: flex;
      flex-direction: row;
      align-items: stretch;
      justify-content: center;
      width: 360px;
      padding: 8px;
      background: #f3f6fb;
      box-sizing: border-box;
    `;

    const container = document.createElement('div');
    container.id = 'container';
    container.style.cssText = `
      display: flex;
      flex-direction: row;
      justify-content: center;
      align-items: center;
      width: 100%;
      padding-top: 16px;
      padding-bottom: 40px;
      background: rgba(255, 0, 0, 0.10);
      box-sizing: border-box;
      font-family: Arial, sans-serif;
    `;

    const left = document.createElement('span');
    left.style.cssText = `
      display: inline-block;
      width: 40px;
      height: 1px;
      background: #666;
      box-sizing: border-box;
    `;

    const middle = document.createElement('div');
    middle.style.cssText = `
      padding: 0 16px;
      font-size: 16px;
      line-height: 24px;
      color: #666;
      box-sizing: border-box;
    `;
    middle.textContent = 'aaa';

    const right = document.createElement('span');
    right.style.cssText = left.style.cssText;

    container.appendChild(left);
    container.appendChild(middle);
    container.appendChild(right);
    item.appendChild(container);
    list.appendChild(item);
    document.body.appendChild(list);

    // Give widget elements time to mount and layout.
    await sleep(0.2);

    const expected = 16 + 40 + Math.max(left.offsetHeight, middle.offsetHeight, right.offsetHeight);
    expect(Math.abs(container.offsetHeight - expected)).toBeLessThanOrEqual(2);
    expect(container.offsetHeight).toBeLessThan(200);

    await snapshot();
  });
});
