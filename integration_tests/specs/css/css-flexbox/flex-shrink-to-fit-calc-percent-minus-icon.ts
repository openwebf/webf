describe('flex-shrink-to-fit-calc-percent-minus-icon', () => {
  afterEach(() => {
    BODY.innerHTML = '';
  });

  it('should not collapse width: calc(100% - 24px) inside an auto-width flex item', async () => {
    document.documentElement.style.margin = '0';
    document.documentElement.style.padding = '0';
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    const row = createElement('div', {
      style: {
        width: '320px',
        padding: '8px',
        border: '1px solid #000',
        boxSizing: 'border-box',
        display: 'flex',
        alignItems: 'flex-start',
        justifyContent: 'space-between',
      },
    });

    const left = createElement(
      'div',
      {
        style: {
          width: '45%',
          overflow: 'hidden',
        },
      },
      [createText('收款人姓名')]
    );

    // This matches the reported pattern:
    // - right side is a fixed-width flex container with justify-end
    // - its child is an auto-width (shrink-to-fit) flex item
    // - inside that item, the text uses calc(100% - iconWidth)
    const right = createElement('div', {
      style: {
        width: '55%',
        display: 'flex',
        justifyContent: 'flex-end',
        overflow: 'hidden',
        textAlign: 'end',
      },
    });

    const inner = createElement('div', {
      style: {
        position: 'relative',
        display: 'flex',
        alignItems: 'flex-start',
        overflow: 'hidden',
      },
    });

    const text = createElement(
      'div',
      {
        id: 'text',
        dir: 'ltr',
        style: {
          width: 'calc(100% - 24px)',
          overflow: 'hidden',
          textAlign: 'end',
        },
      },
      [createText('張三')]
    );

    const icon = createElement('div', {
      id: 'icon',
      style: {
        width: '24px',
        height: '20px',
        backgroundColor: 'red',
        flex: 'none',
      },
    });

    inner.appendChild(text);
    inner.appendChild(icon);
    right.appendChild(inner);
    row.appendChild(left);
    row.appendChild(right);
    BODY.appendChild(row);

    await waitForOnScreen(row);
    await nextFrames(2);

    expect((text as HTMLElement).offsetWidth).toBeGreaterThan(0);
    expect((inner as HTMLElement).offsetWidth).toBeGreaterThan((icon as HTMLElement).offsetWidth);
    await snapshot();
  });
});
