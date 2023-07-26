describe('Tags template', () => {
  it('should work with content', async () => {
    const t = document.createElement('template')
    const template = t.content;
    template.appendChild(document.createTextNode('template text'))
    document.body.appendChild(template);

    await snapshot();
  });

  it('should work with innerHTML', async () => {
    const t = document.createElement('template')
    t.innerHTML = '<div>template text</div>';
    document.body.appendChild(t.content);
    expect(t.innerHTML).toBe('');
    await snapshot();
  });

  it('should avoid leaks when massive elements in template element', async () => {
    const t = document.createElement('template')
    const template = t.content;
    const element = document.createElement('div');
    element.innerHTML = `<ul>
<li><div><span>1</span></div></li>
<li><div><span>2</span></div></li>
<li><div><span>3</span></div></li>
</ul>`;
    template.appendChild(element);
    document.body.appendChild(template);
  });
});
