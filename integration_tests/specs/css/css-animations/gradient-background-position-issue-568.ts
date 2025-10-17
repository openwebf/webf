// Repro for https://github.com/openwebf/webf/issues/568
// Animate background-position on a linear-gradient and verify it updates.

describe('linear-gradient background-position animation (issue #568)', () => {
  it('background-position moves over time and can be paused for a stable snapshot', async () => {
    document.body.style.margin = '0';

    const style = document.createElement('style');
    style.textContent = `
      .skeleton {
        height: 200px;
        width: 200px;
        animation-duration: 1s;
        animation-fill-mode: forwards;
        animation-iteration-count: infinite;
        animation-name: placeHolderShimmer;
        animation-timing-function: linear;
        background: #f6f7f8;
        background: linear-gradient(to right, #eeeeee 8%, #dddddd 18%, #eeeeee 33%);
        background-size: 800px 104px;
        position: relative;
      }
      @keyframes placeHolderShimmer {
        0% { background-position: -468px 0; }
        100% { background-position: 468px 0; }
      }
    `;
    document.head.appendChild(style);

    const el = document.createElement('div');
    el.className = 'skeleton';
    document.body.appendChild(el);

    // Capture initial value
    const cs1 = getComputedStyle(el);
    const startPos = cs1.getPropertyValue('background-position-x') || cs1.getPropertyValue('background-position');

    // Wait some time to allow animation to progress, then pause for determinism
    await sleep(1);
    el.style.animationPlayState = 'paused';

    await sleep(1);
    const cs2 = getComputedStyle(el);
    const laterPos = cs2.getPropertyValue('background-position-x') || cs2.getPropertyValue('background-position');

    // Ensure animation updated background-position
    expect(laterPos).not.toBe(startPos);

    await snapshot();
  });
});

