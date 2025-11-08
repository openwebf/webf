fdescribe('border-radius with non-uniform borders', () => {
  it('paints rounded corners with non-uniform solid widths', async () => {
    const box = createElement('div', {
      style: {
        width: '220px',
        height: '80px',
        borderStyle: 'solid',
        borderWidth: '2px 4px 8px 12px',
        borderColor: '#ef4444',
        borderRadius: '20px',
        backgroundColor: '#ffffff',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(box);

    await snapshot();
  });

  it('clips background to radius with non-uniform solid widths', async () => {
    const box = createElement('div', {
      style: {
        width: '160px',
        height: '90px',
        borderStyle: 'solid',
        borderWidth: '12px 6px 3px 9px',
        borderColor: '#10b981',
        borderRadius: '18px',
        background: 'linear-gradient(45deg, #fde68a, #fca5a5)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(box);

    await snapshot();
  });
});

