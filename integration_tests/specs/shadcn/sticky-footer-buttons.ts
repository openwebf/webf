describe('shadcn sticky footer buttons', () => {
  it('stretches sticky footer buttons in a column flex dialog', async () => {
    await resizeViewport(420, 900);

    document.documentElement.style.margin = '0';
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    const overlay = document.createElement('div');
    setElementStyle(overlay, {
      position: 'fixed',
      inset: '0',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'rgba(0, 0, 0, 0.5)',
      paddingLeft: '16px',
      paddingRight: '16px',
      paddingTop: '24px',
      paddingBottom: '24px',
      boxSizing: 'border-box',
    });

    const dialog = document.createElement('div');
    setElementStyle(dialog, {
      position: 'relative',
      display: 'flex',
      flexDirection: 'column',
      width: '388px',
      maxHeight: '85vh',
      overflow: 'hidden',
      border: '1px solid rgb(228,228,231)',
      borderRadius: '12px',
      background: 'white',
      boxSizing: 'border-box',
    });
    overlay.appendChild(dialog);

    const header = document.createElement('div');
    setElementStyle(header, {
      display: 'grid',
      gap: '8px',
      padding: '24px 24px 16px 24px',
      borderBottom: '1px solid rgb(244,244,245)',
      background: 'white',
      boxSizing: 'border-box',
    });
    header.textContent = 'Long-form migration checklist';
    dialog.appendChild(header);

    const body = document.createElement('div');
    setElementStyle(body, {
      display: 'grid',
      gap: '12px',
      padding: '16px 24px',
      overflowY: 'auto',
      boxSizing: 'border-box',
    });
    for (let i = 0; i < 8; i++) {
      const row = document.createElement('div');
      setElementStyle(row, {
        border: '1px solid rgb(228,228,231)',
        borderRadius: '8px',
        background: 'rgb(250,250,250)',
        padding: '12px 16px',
        fontSize: '14px',
        lineHeight: '20px',
        color: 'rgb(82,82,91)',
        boxSizing: 'border-box',
      });
      row.textContent = `Step ${i + 1}: migrate one shadcn component and verify layout parity in WebF.`;
      body.appendChild(row);
    }
    dialog.appendChild(body);

    const footer = document.createElement('div');
    setElementStyle(footer, {
      position: 'sticky',
      bottom: '0',
      display: 'flex',
      flexDirection: 'column-reverse',
      width: '100%',
      gap: '8px',
      padding: '16px 24px',
      background: 'white',
      borderTop: '1px solid rgb(228,228,231)',
      boxSizing: 'border-box',
    });
    dialog.appendChild(footer);

    const later = document.createElement('button');
    setElementStyle(later, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: '8px',
      width: '100%',
      whiteSpace: 'nowrap',
      borderRadius: '6px',
      fontWeight: '500',
      height: '36px',
      paddingLeft: '16px',
      paddingRight: '16px',
      paddingTop: '8px',
      paddingBottom: '8px',
      border: '1px solid rgb(228,228,231)',
      background: 'white',
      color: 'rgb(9,9,11)',
      boxSizing: 'border-box',
    });
    later.textContent = 'Later';
    footer.appendChild(later);

    const continueButton = document.createElement('button');
    setElementStyle(continueButton, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: '8px',
      width: '100%',
      whiteSpace: 'nowrap',
      borderRadius: '6px',
      fontWeight: '500',
      height: '36px',
      paddingLeft: '16px',
      paddingRight: '16px',
      paddingTop: '8px',
      paddingBottom: '8px',
      border: '1px solid rgb(24,24,27)',
      background: 'rgb(24,24,27)',
      color: 'white',
      boxSizing: 'border-box',
    });
    continueButton.textContent = 'Continue rollout';
    footer.appendChild(continueButton);

    document.body.appendChild(overlay);
    await waitForFrame();
    await snapshot();

    const footerRect = footer.getBoundingClientRect();
    const laterRect = later.getBoundingClientRect();
    const continueRect = continueButton.getBoundingClientRect();

    expect(footerRect.width).toBeGreaterThan(300);
    expect(Math.abs(laterRect.width - continueRect.width)).toBeLessThan(1);
    expect(laterRect.width).toBeGreaterThan(280);
  });
});
