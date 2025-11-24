describe('transition: box-shadow via Tailwind-like CSS variables', () => {
  function waitForTransitionEnd(el: HTMLElement): Promise<void> {
    return new Promise<void>((resolve) => {
      const onEnd = (e: Event) => {
        if ((e as TransitionEvent).propertyName === 'box-shadow') {
          el.removeEventListener('transitionend', onEnd as any);
          resolve();
        }
      };
      el.addEventListener('transitionend', onEnd as any);
    });
  }

  it('fades in box-shadow from none -> shadow', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .host {
        width: 200px;
        height: 140px;
        padding: 24px;
        background: #f9fafb;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .box {
        width: 80px;
        height: 80px;
        border-radius: 9999px;
        background: #ffffff;
        /* Tailwind-like box-shadow variable setup */
        --tw-ring-offset-shadow: 0 0 #0000;
        --tw-ring-shadow: 0 0 #0000;
        --tw-shadow: 0 0 #0000;
        box-shadow: var(--tw-ring-offset-shadow, 0 0 #0000),
          var(--tw-ring-shadow, 0 0 #0000),
          var(--tw-shadow);

        transition-property: box-shadow;
        transition-duration: 500ms;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
      }
      .box.on {
        /* Approximate Tailwind shadow-xl */
        --tw-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }
    `;
    document.head.appendChild(style);

    const host = document.createElement('div');
    host.className = 'host';
    const box = document.createElement('div');
    box.className = 'box';
    host.appendChild(box);
    document.body.appendChild(host);

    // Initial (no shadow) snapshot.
    await snapshot();

    // Trigger none -> shadow.
    box.classList.add('on');

    // Wait slightly longer than duration.
    await new Promise((r) => setTimeout(r, 560));

    // Final (with shadow) snapshot.
    await snapshot();

    // Programmatic check: box-shadow should be non-empty at the end.
    const cs = getComputedStyle(box);
    expect(cs.boxShadow === 'none' || cs.boxShadow === '').toBe(false);
  });

  it('fades out box-shadow from shadow -> none using var() toggle', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .host2 {
        width: 200px;
        height: 140px;
        padding: 24px;
        background: #f9fafb;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .box2 {
        width: 80px;
        height: 80px;
        border-radius: 9999px;
        background: #ffffff;
        /* Tailwind-like box-shadow variables */
        --tw-ring-offset-shadow: 0 0 #0000;
        --tw-ring-shadow: 0 0 #0000;
        --tw-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
        box-shadow: var(--tw-ring-offset-shadow, 0 0 #0000),
          var(--tw-ring-shadow, 0 0 #0000),
          var(--tw-shadow);

        transition-property: box-shadow;
        transition-duration: 1000ms;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
      }
    `;
    document.head.appendChild(style);

    const host = document.createElement('div');
    host.className = 'host2';
    const box = document.createElement('div');
    box.className = 'box2';
    host.appendChild(box);
    document.body.appendChild(host);

    // Initial (with shadow) snapshot.
    await snapshot();

    // Toggle Tailwind-like shadow variable to "none".
    box.style.setProperty('--tw-shadow', '0 0 #0000');

    // Wait slightly longer than duration to ensure all transitions
    // (including any var()-driven ones) have completed.
    await new Promise((r) => setTimeout(r, 1200));

    // Final (no shadow) snapshot.
    await snapshot();

    const cs = getComputedStyle(box);
    const expected =
      'rgba(0, 0, 0, 0) 0px 0px 0px 0px, ' +
      'rgba(0, 0, 0, 0) 0px 0px 0px 0px, ' +
      'rgba(0, 0, 0, 0) 0px 0px 0px 0px';
    expect(cs.boxShadow).toBe(expected);
  });
});
