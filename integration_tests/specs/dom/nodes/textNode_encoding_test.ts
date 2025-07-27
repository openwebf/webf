describe('TextNode encoding', () => {
  it('should handle no-break spaces correctly', async () => {
    const div = document.createElement('div');
    div.style.font = '20px monospace';
    const text = document.createTextNode('\u00A0\u00A0\u00A0A\u00A0\u00A0\u00A0B');
    div.appendChild(text);
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should handle Chinese characters correctly', async () => {
    const div = document.createElement('div');
    div.style.font = '20px sans-serif';
    const text = document.createTextNode('你好世界');
    div.appendChild(text);
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should handle emoji correctly', async () => {
    const div = document.createElement('div');
    div.style.font = '20px sans-serif';
    const text = document.createTextNode('😀😁😂');
    div.appendChild(text);
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should handle mixed content correctly', async () => {
    const div = document.createElement('div');
    div.style.font = '20px sans-serif';
    const text = document.createTextNode('Hello 你好 😀 Café');
    div.appendChild(text);
    document.body.appendChild(div);
    
    await snapshot();
  });
});