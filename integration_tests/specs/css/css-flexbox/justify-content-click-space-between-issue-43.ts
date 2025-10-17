// Repro for https://github.com/openwebf/webf-enterprise/issues/43
// Flex container with justify-content: space-between should layout two items at edges
// and both items should be clickable.

describe('flex justify-content space-between click targets (enterprise #43)', () => {
  it('lays out at edges and fires click handlers', async (done) => {
    document.body.style.margin = '0';

    const footer = document.createElement('div');
    footer.className = 'login-footer';
    Object.assign(footer.style, {
      marginTop: '16px',
      width: '300px',
      height: '40px',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      border: '1px solid #ddd'
    } as CSSStyleDeclaration);

    const left = document.createElement('div');
    left.className = 'login-footer-text';
    left.textContent = '忘记密码？';
    left.style.fontSize = '14px';

    const right = document.createElement('div');
    right.className = 'login-footer-link';
    right.textContent = '立即注册';
    right.style.color = 'blue';

    footer.appendChild(left);
    footer.appendChild(right);
    document.body.appendChild(footer);

    // Wait a frame for layout
    await waitForOnScreen(footer);

    const footerRect = footer.getBoundingClientRect();
    const leftRect = left.getBoundingClientRect();
    const rightRect = right.getBoundingClientRect();

    // Layout assertions: left aligned near container left; right aligned near container right.
    expect(Math.abs(leftRect.left - footerRect.left)).toBeLessThanOrEqual(2);
    expect(Math.abs(rightRect.right - footerRect.right)).toBeLessThanOrEqual(2);

    let clicks = { left: 0, right: 0 };
    left.addEventListener('click', () => { clicks.left++; });
    right.addEventListener('click', () => { clicks.right++; });

    // Simulate clicks roughly at element centers
    const leftX = leftRect.left + leftRect.width / 2;
    const leftY = leftRect.top + leftRect.height / 2;
    const rightX = rightRect.left + rightRect.width / 2;
    const rightY = rightRect.top + rightRect.height / 2;

    await simulateClick(leftX, leftY);
    await simulateClick(rightX, rightY);

    expect(clicks.left).toBe(1);
    expect(clicks.right).toBe(1);

    await snapshot();
    done();
  });
});

