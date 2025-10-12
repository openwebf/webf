describe('CSS animation overlay fade toggle (issue #243)', () => {
  it('fade-out then fade-in via class and animationend', async (done) => {
    // Inject styles (shortened duration for test speed)
    const style = document.createElement('style');
    style.textContent = `
      .van-fade-enter-active {
        animation: 0.3s van-fade-in both ease-out;
      }
      .van-fade-leave-active {
        animation: 0.3s van-fade-out both ease-in;
      }
      @keyframes van-fade-in {
        0% { opacity: 0; }
        to { opacity: 1; }
      }
      @keyframes van-fade-out {
        0% { opacity: 1; }
        to { opacity: 0; }
      }
      .van-overlay {
        position: fixed;
        top: 0;
        left: 0;
        z-index: 111;
        width: 100%;
        height: 100%;
        background: gray;
      }
      #btn {
        width: 100px;
        height: 100px;
        background-color: antiquewhite;
        text-align: center;
        line-height: 100px;
        position: relative;
        z-index: 200;
      }
    `;
    document.head.appendChild(style);

    const btn = document.createElement('div');
    btn.id = 'btn';
    btn.textContent = '点我啊';

    const overlay = document.createElement('div');
    overlay.id = 'overlay';
    overlay.className = 'van-overlay';

    function hide() {
      overlay.style.display = 'none';
      overlay.className = 'van-overlay';
    }
    function show() {
      overlay.style.display = 'block';
      // Keep a trailing space as in the original sample
      overlay.className = 'van-overlay ';
    }

    overlay.onclick = function () {
      overlay.removeEventListener('animationend', show);
      overlay.addEventListener('animationend', hide, { once: true });
      overlay.className = 'van-overlay van-fade-leave-active';
    };
    btn.onclick = function () {
      overlay.removeEventListener('animationend', hide);
      overlay.addEventListener('animationend', show, { once: true });
      overlay.style.display = 'block';
      overlay.className = 'van-overlay van-fade-enter-active';
    };

    document.body.appendChild(btn);
    document.body.appendChild(overlay);

    // Initial state snapshot (visible overlay)
    await snapshot();

    // 1) Trigger fade-out via click overlay
    const fadedOut = new Promise<void>((resolve) => {
      overlay.addEventListener('animationend', () => resolve(), { once: true });
    });
    overlay.click();
    await fadedOut;
    await snapshot();

    // 2) Trigger fade-in via click button
    const fadedIn = new Promise<void>((resolve) => {
      overlay.addEventListener('animationend', () => resolve(), { once: true });
    });
    btn.click();
    await fadedIn;
    expect(overlay.style.display).toBe('block');
    await snapshot();

    done();
  });
});

