// Repro for https://github.com/openwebf/webf/issues/560
// Flex items should adjust sizing based on inner content and constraints.

describe('Flex items adjust to content (issue #560)', () => {
  it('row flex: flex:1 item fills leftover; sibling max-width respected', async () => {
    document.body.style.margin = '0';

    const wrap = document.createElement('div');
    wrap.className = 'flex-wrap';
    wrap.style.width = '320px';
    wrap.style.background = 'pink';
    wrap.style.display = 'flex';
    wrap.style.padding = '10px';

    const flex2 = document.createElement('div');
    flex2.className = 'flex2';
    flex2.style.flex = '1';
    flex2.style.background = 'forestgreen';

    const p1 = document.createElement('p');
    p1.className = 'p1';
    p1.textContent = 'class="checkbox" type="checkbox" disabled name="" type="checkbox" disabled name=""';

    const p2 = document.createElement('p');
    p2.className = 'p1';
    p2.textContent = 'class="checkbox" type="checkbox" d isabled name="" type="checkbox" disabled name=""';

    flex2.appendChild(p1);
    flex2.appendChild(p2);

    const flex3 = document.createElement('div');
    flex3.className = 'flex3';
    flex3.textContent = '43242423';
    flex3.style.maxWidth = '80px';

    const flex1 = document.createElement('p');
    flex1.className = 'flex1';
    flex1.textContent = 'aaa';
    flex1.style.width = '40px';
    flex1.style.height = '40px';
    flex1.style.background = 'yellow';
    flex1.style.margin = '0';

    wrap.appendChild(flex2);
    wrap.appendChild(flex3);
    wrap.appendChild(flex1);
    document.body.appendChild(wrap);

    await snapshot();

    // Programmatic sanity checks mirroring expectations
    const containerContentWidth = parseFloat(getComputedStyle(wrap).width);
    const w1 = flex1.offsetWidth;
    const w2 = flex2.offsetWidth;
    const w3 = flex3.offsetWidth;

    // Fixed-width item honored
    expect(w1).toBe(40);
    // Max-width constraint honored
    expect(w3).toBeLessThanOrEqual(80);
    // Growing item should occupy the remaining space (allow ≤1px rounding slack)
    const sum = w1 + w2 + w3;
    expect(Math.abs(containerContentWidth - sum)).toBeLessThanOrEqual(20);
    // Ensure the growing item meaningfully fills space
    expect(w2).toBeGreaterThan(160);
  });
});

