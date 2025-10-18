// Repro for https://github.com/openwebf/webf-enterprise/issues/82
// Ensure getBoundingClientRect() works for attached elements and CSS calc() widths compute as expected.

describe('getBoundingClientRect + calc() widths (enterprise #82)', () => {
  it('returns rect for attached element and resolves calc((100% - 20px) / 3)', async () => {
    document.body.style.margin = '0';

    const container = document.createElement('div');
    container.id = 'container';
    container.style.width = '300px';
    container.style.background = 'blue';
    container.style.padding = '0';
    container.style.border = '0';

    const trigger = document.createElement('div');
    trigger.textContent = 'get style';
    trigger.onclick = () => {
      // Should not throw
      const r = container.getBoundingClientRect();
      (container as any)._lastRect = r;
    };

    const t1 = document.createElement('div');
    t1.style.background = 'red';
    t1.style.height = '20px';
    t1.style.width = 'calc((100% - 20px) / 3)';

    const t2 = document.createElement('div');
    t2.style.background = 'red';
    t2.style.height = '20px';
    t2.style.width = 'calc(80px / 3)';

    container.appendChild(document.createTextNode('container'));
    container.appendChild(trigger);
    container.appendChild(t1);
    container.appendChild(t2);
    document.body.appendChild(container);

    await sleep(0.05);

    // Measuring should not assert/crash and width should be > 0
    const rect = container.getBoundingClientRect();
    expect(rect.width).toBeGreaterThan(0);

    const cw = container.clientWidth; // 300
    const w1 = parseFloat(getComputedStyle(t1).width);
    const w2 = parseFloat(getComputedStyle(t2).width);
    const expectW1 = (cw - 20) / 3;
    const expectW2 = 80 / 3;
    expect(Math.abs(w1 - expectW1)).toBeLessThanOrEqual(1);
    expect(Math.abs(w2 - expectW2)).toBeLessThanOrEqual(1);

    await snapshot();
  });

  it('measuring inside a button click handler does not crash', async (done) => {
    const container = document.createElement('div');
    container.id = 'container2';
    container.style.width = '200px';
    container.style.background = 'lightblue';

    const btn = document.createElement('button');
    btn.textContent = 'measure';
    btn.onclick = async () => {
      const r = container.getBoundingClientRect();
      (btn as any).dataset.w = String(r.width);


      const measured = parseFloat((btn as any).dataset.w || '0');
      expect(measured).toBeGreaterThan(0);

      await snapshot();

      done();
    };

    container.appendChild(btn);
    document.body.appendChild(container);

    await waitForOnScreen(container);
    btn.click();
  });
});

