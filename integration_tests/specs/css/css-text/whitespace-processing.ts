describe('CSS Text Whitespace Processing', () => {
  it('should collapse whitespace in normal mode', async () => {
    const div = document.createElement('div');
    div.style.whiteSpace = 'normal';
    div.innerHTML = '  Hello   world  \n  from   \n  WebF  ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should preserve whitespace in pre mode', async () => {
    const div = document.createElement('div');
    div.style.whiteSpace = 'pre';
    div.style.fontFamily = 'monospace';
    div.innerHTML = '  Hello   world  \n  from   \n  WebF  ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should preserve whitespace and wrap in pre-wrap mode', async () => {
    const div = document.createElement('div');
    div.style.whiteSpace = 'pre-wrap';
    div.style.fontFamily = 'monospace';
    div.style.width = '100px';
    div.innerHTML = '  Hello   world  from   WebF  with   preserved   spaces  ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should preserve line breaks but collapse spaces in pre-line mode', async () => {
    const div = document.createElement('div');
    div.style.whiteSpace = 'pre-line';
    div.innerHTML = '  Hello   world  \n  from   \n  WebF  ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should handle break-spaces mode', async () => {
    const div = document.createElement('div');
    div.style.whiteSpace = 'break-spaces';
    div.style.fontFamily = 'monospace';
    div.style.width = '100px';
    div.innerHTML = '  Hello   world  from   WebF  ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should trim whitespace at line start and end', async () => {
    const div = document.createElement('div');
    div.style.width = '50px';
    div.style.whiteSpace = 'normal';
    div.innerHTML = '  Hello  world  from  WebF  ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should handle hanging spaces in pre-wrap', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.whiteSpace = 'pre-wrap';
    div.style.fontFamily = 'monospace';
    div.style.border = '1px solid black';
    div.innerHTML = 'Hello world   \nfrom WebF   ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should handle mixed content with inline elements', async () => {
    const div = document.createElement('div');
    div.style.width = '150px';
    div.innerHTML = '  Hello  <span style="color: red">  beautiful  </span>  world  ';
    document.body.appendChild(div);
    
    await snapshot();
  });

  it('should handle tabs correctly', async () => {
    const div = document.createElement('div');
    div.style.whiteSpace = 'pre';
    div.style.fontFamily = 'monospace';
    div.innerHTML = 'Name:\tJohn\nAge:\t30\nCity:\tNew York';
    document.body.appendChild(div);
    
    await snapshot();
  });
});