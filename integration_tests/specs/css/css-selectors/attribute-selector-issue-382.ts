// Repro for https://github.com/openwebf/webf/issues/382
// Attribute selector with ancestor attribute should match descendant reliably

describe('Attribute selector with ancestor attribute (issue #382)', () => {
  it('descendant .at matches when ancestor .content has data attribute (same and different on intermediates)', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .content[data-v-69423fe3] .at { color: green; }
      .content { font-size: 45px; font-weight: 400; line-height: 63px; }
      body { margin: 0; }
    `;
    document.head.appendChild(style);

    // Case 1: intermediate element has the SAME attribute
    const container1 = document.createElement('div');
    container1.className = 'content';
    container1.setAttribute('data-v-69423fe3', '');

    const mid1 = document.createElement('span');
    mid1.setAttribute('data-v-69423fe3', '');

    const at1 = document.createElement('span');
    at1.className = 'at';
    at1.textContent = '@隔壁村一狗';

    mid1.appendChild(at1);
    container1.appendChild(mid1);

    // Case 2: intermediate element has a DIFFERENT attribute
    const container2 = document.createElement('div');
    container2.className = 'content';
    container2.setAttribute('data-v-69423fe3', '');

    const mid2 = document.createElement('span');
    mid2.setAttribute('data-v-69423fe3-different', '');

    const at2 = document.createElement('div');
    at2.className = 'at';
    at2.textContent = '@隔壁村三狗';

    mid2.appendChild(at2);
    container2.appendChild(mid2);

    document.body.appendChild(container1);
    document.body.appendChild(container2);

    // Visual assertion
    await snapshot();

    // Programmatic assertions
    const color1 = getComputedStyle(at1).color;
    const color2 = getComputedStyle(at2).color;
    expect(color1).toBe('rgb(0, 128, 0)');
    expect(color2).toBe('rgb(0, 128, 0)');
  });
});

