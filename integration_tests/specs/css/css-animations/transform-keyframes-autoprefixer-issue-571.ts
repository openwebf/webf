// Repro for https://github.com/openwebf/webf/issues/571
// Ensure transform inside keyframes still animates when prefixed and unprefixed
// declarations (e.g., produced by Autoprefixer) coexist.

describe('keyframes transform with vendor-prefixed declarations (issue #571)', () => {
  it('animates transform when keyframes include -webkit-transform and transform', async () => {
    document.body.style.margin = '0';

    const style = document.createElement('style');
    style.textContent = `
      @keyframes spin {
        from { -webkit-transform: rotate(0deg); transform: rotate(0deg); }
        to   { -webkit-transform: rotate(360deg); transform: rotate(360deg); }
      }
      /* Optional prefixed keyframes block as some tools emit both */
      @-webkit-keyframes spin {
        from { -webkit-transform: rotate(0deg); transform: rotate(0deg); }
        to   { -webkit-transform: rotate(360deg); transform: rotate(360deg); }
      }
      .box {
        width: 120px; height: 120px;
        background: #4CAF50;
        animation: spin 1s linear infinite;
        -webkit-animation: spin 1s linear infinite;
      }
    `;
    document.head.appendChild(style);

    const el = document.createElement('div');
    el.className = 'box';
    document.body.appendChild(el);

    // At t=0, rotation starts at 0deg => computed transform should be 'none'.
    const start = getComputedStyle(el).getPropertyValue('transform');
    expect(start).toBe('none');

    // Let the animation progress; then pause to observe a stable, non-zero rotation.
    await sleep(0.5);
    el.style.animationPlayState = 'paused';
    const mid = getComputedStyle(el).getPropertyValue('transform');

    // Should have advanced to a non-identity matrix (i.e., not 'none').
    expect(mid).not.toBe('none');
  });
});

