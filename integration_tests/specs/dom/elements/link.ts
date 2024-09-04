describe('Link Element', () => {
  it('should work with remote css', async (done) => {
    let link = document.createElement('link');
    link.setAttribute('href', 'https://andycall.oss-cn-beijing.aliyuncs.com/css/a-green.css');
    link.setAttribute('rel', 'stylesheet');

    link.addEventListener('load', async () => {
      await snapshot();
      done();
    });

    document.head.appendChild(link);

    let div = document.createElement('div');
    div.className = 'a';
    div.appendChild(document.createTextNode('helloworld'));
    BODY.appendChild(div);
  });

  it('should work with local css', async (done) => {
    let link = document.createElement('link');
    link.setAttribute('href', 'assets:assets/bad.css');
    link.setAttribute('rel', 'stylesheet');
    link.addEventListener('load', async () => {
        await snapshot();
        link.setAttribute('href', 'assets:assets/good.css');
        await snapshot(0.1);
        done();
    });
    document.head.appendChild(link);
 
    let p = document.createElement('p');
    p.appendChild(document.createTextNode('002 This text should be green on a white background'));
    BODY.appendChild(p);
  });

  it('insert style sheet', async (done) => {
    let link1 = document.createElement('link');
    link1.setAttribute('href', 'assets:assets/bad.css');
    link1.setAttribute('rel', 'stylesheet');
    document.head.appendChild(link1);

    let link2 = document.createElement('link');
    link2.setAttribute('href', 'assets:assets/good.css');
    link2.setAttribute('rel', 'stylesheet');
    document.head.appendChild(link2);

    link2.addEventListener('load', async () => {
      done();
    });

    let p = document.createElement('p');
    p.appendChild(document.createTextNode('This text should be green on a red background'));
    BODY.appendChild(p);
  });

  it('remove style sheet', async (done) => {
    let link1 = document.createElement('link');
    link1.setAttribute('href', 'assets:assets/bad.css');
    link1.setAttribute('rel', 'stylesheet');
    document.head.appendChild(link1);

    let link2 = document.createElement('link');
    link2.setAttribute('href', 'assets:assets/good.css');
    link2.setAttribute('rel', 'stylesheet');
    document.head.appendChild(link2);
    
    link1.addEventListener('load', async () => {
      document.head.removeChild(link1);
      await sleep(0.5);
      await snapshot();
      done();
    });

    let p = document.createElement('p');
    p.appendChild(document.createTextNode('remove: This text should be green on a red background'));
    BODY.appendChild(p);
  });
});
