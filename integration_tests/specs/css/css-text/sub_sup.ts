describe('sub and sup inline semantics', () => {
  it('renders subscript lower and smaller, superscript raised and smaller', async () => {
    const p = createElement('p', { style: { fontSize: '16px', lineHeight: '22px' } }, [
      createText('Water is H'),
      createElement('sub', {}, [createText('2')]),
      createText('O, and angles are 90'),
      createElement('sup', {}, [createText('°')]),
      createText('.')
    ]);

    BODY.appendChild(p);
    await snapshot();
  });

  it('keeps single-line baseline flow with inline sub/sup', async () => {
    const container = createElement('div', { style: { width: '360px', fontSize: '16px', lineHeight: '22px' } }, [
      createElement('p', {}, [
        createText('E = mc'),
        createElement('sup', {}, [createText('2')]),
        createText(', CO'),
        createElement('sub', {}, [createText('2')]),
        createText(' emissions')
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('supports CSS vertical-align: super/sub on spans', async () => {
    const p = createElement('p', { style: { fontSize: '16px', lineHeight: '22px' } }, [
      createText('E = mc'),
      createElement('span', { style: { verticalAlign: 'super', fontSize: '12px' } }, [createText('2')]),
      createText(' using CSS super; X'),
      createElement('span', { style: { verticalAlign: 'sub', fontSize: '12px' } }, [createText('i')]),
      createText(' for subscript.')
    ]);
    BODY.appendChild(p);
    await snapshot();
  });
});
