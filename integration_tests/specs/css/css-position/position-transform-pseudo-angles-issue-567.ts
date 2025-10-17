// Repro for https://github.com/openwebf/webf/issues/567
// Absolute positioning combined with transform centering and pseudo-elements
// should render arrows at top/bottom/left/right edges correctly.

describe('position + transform with pseudo elements (issue #567)', () => {
  it('renders four centered edge arrows around a 100x100 box', async () => {
    document.body.style.margin = '0';

    const style = document.createElement('style');
    style.textContent = `
      .angle-wrap {
        position: relative;
        width: 100px;
        height: 100px;
        top: 50px;
        left: 50px;
        background: pink;
      }
      .angle {
        position: absolute;
      }
      .angle::before {
        content: "";
        display: block;
        border-width: 0 6px 6px;
        border-style: solid;
        border-color: transparent transparent #333740;
      }
      .top {
        left: 50%;
        transform: translateX(-50%);
        top: 0;
      }
      .top::before {
        margin-top: -6px;
        transform: rotate(0deg);
      }
      .bottom {
        left: 50%;
        transform: translateX(-50%);
        bottom: 0;
      }
      .bottom::before {
        margin-bottom: -6px;
        transform: rotate(180deg);
      }
      .left {
        top: 50%;
        transform: translateY(-50%);
        left: 0;
      }
      .left::before {
        margin-left: -9px;
        transform: rotate(-90deg);
      }
      .right {
        top: 50%;
        transform: translateY(-50%);
        right: 0;
      }
      .right::before {
        margin-right: -9px;
        transform: rotate(90deg);
      }
    `;
    document.head.appendChild(style);

    const wrap = document.createElement('div');
    wrap.className = 'angle-wrap';
    const top = document.createElement('div');
    top.className = 'angle top';
    const bottom = document.createElement('div');
    bottom.className = 'angle bottom';
    const left = document.createElement('div');
    left.className = 'angle left';
    const right = document.createElement('div');
    right.className = 'angle right';

    wrap.appendChild(top);
    wrap.appendChild(bottom);
    wrap.appendChild(left);
    wrap.appendChild(right);
    document.body.appendChild(wrap);

    await snapshot();
  });
});

