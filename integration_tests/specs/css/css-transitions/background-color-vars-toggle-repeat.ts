describe('transition: background-color via CSS vars toggled repeatedly', () => {
  it('animates white(surface) <-> red repeatedly', async () => {
    const style = document.createElement('style');
    style.textContent = `
      :root { --tw-bg-opacity: 1; }
      .host { width: 220px; height: 160px; padding: 16px; background: #fff; }
      .box {
        width: 100px; height: 80px; border-radius: 8px;
        transition-property: background-color;
        transition-duration: 200ms;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        /* Start from surface-like color */
        --tw-bg-opacity: 1;
        background-color: rgb(241 245 249 / var(--tw-bg-opacity, 1));
      }
      .box.on {
        /* Tailwind red-400 */
        --tw-bg-opacity: 1;
        background-color: rgb(248 113 113 / var(--tw-bg-opacity, 1));
      }
      .box.off {
        --tw-bg-opacity: 1;
        background-color: rgb(241 245 249 / var(--tw-bg-opacity, 1));
      }
    `;
    document.head.appendChild(style);

    const host = document.createElement('div');
    host.className = 'host';
    const box = document.createElement('div');
    box.className = 'box off';
    host.appendChild(box);
    document.body.appendChild(host);

    const waitForEnd = (el: HTMLElement) => new Promise<void>((resolve) => {
      const onEnd = (e: Event) => { el.removeEventListener('transitionend', onEnd as any); resolve(); };
      el.addEventListener('transitionend', onEnd as any);
    });

    // Initial snapshot/state
    await snapshot();
    let cs = getComputedStyle(box);
    expect(cs.backgroundColor).toBe('rgb(241, 245, 249)');

    // Toggle 1: off -> on (surface -> red)
    box.classList.remove('off');
    box.classList.add('on');
    await waitForEnd(box);
    cs = getComputedStyle(box);
    expect(cs.backgroundColor).toBe('rgb(248, 113, 113)');
    await snapshot();

    // Toggle 2: on -> off (red -> surface)
    box.classList.remove('on');
    box.classList.add('off');
    await waitForEnd(box);
    cs = getComputedStyle(box);
    expect(cs.backgroundColor).toBe('rgb(241, 245, 249)');
    await snapshot();

    // Toggle 3: off -> on again (surface -> red) should still animate
    box.classList.remove('off');
    box.classList.add('on');
    await waitForEnd(box);
    cs = getComputedStyle(box);
    expect(cs.backgroundColor).toBe('rgb(248, 113, 113)');
    await snapshot();
  });
});

