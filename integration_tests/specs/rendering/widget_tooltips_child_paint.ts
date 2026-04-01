describe('Widget tooltips child paint', () => {
  it('tooltip child widget text still paints after nested widget text update in flex layout', async () => {
    document.documentElement.style.margin = '0';
    document.body.style.margin = '0';
    document.body.style.padding = '0';
    document.body.style.backgroundColor = '#000';

    const root = document.createElement('div');
    root.setAttribute(
      'style',
      [
        'display:flex',
        'width:240px',
        'padding:12px',
        'background:#000',
      ].join(';'),
    );

    const column = document.createElement('div');
    column.setAttribute(
      'style',
      [
        'display:flex',
        'flex-direction:column',
        'min-width:0',
        'flex:1',
      ].join(';'),
    );

    const row = document.createElement('div');
    row.setAttribute(
      'style',
      [
        'display:flex',
        'width:100%',
        'align-items:center',
      ].join(';'),
    );

    const tips = document.createElement('flutter-tooltips');
    tips.id = 'tips';
    tips.setAttribute('style', 'display:block; width:100%;');

    const amount = document.createElement('webf-test-auto-size-text');
    amount.id = 'amount';
    amount.setAttribute('text', '1,200.686 USDT');

    tips.appendChild(amount);
    row.appendChild(tips);
    column.appendChild(row);
    root.appendChild(column);
    document.body.appendChild(root);

    await waitForOnScreen(root);
    await nextFrames(4);

    await snapshot();

    amount.setAttribute('text', '9,999.999 USDT');
    await nextFrames(4);
    await sleep(0.2);

    await snapshot();
  });
});
