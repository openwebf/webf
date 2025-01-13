describe('Tags img async', () => {
  it('should have not size when img not mounted', async (done) => {
    const img = document.createElement('img');
    // @ts-ignore
    let w = await img.width_async;
    // @ts-ignore
    let h = await img.height_async;
    expect(w).toBe(0);
    expect(h).toBe(0);
    done()
  });

  it('have no effect setting empty src', (done) => {
    const img = document.createElement('img');
    // @ts-ignore
    img.src_async = '';
    document.body.appendChild(img);
    img.onload = () => {
      done.fail('image can not load');
    };
    setTimeout(() => {
      done();
    }, 500);
  });

  it('don\'t error when append child on img element', async (done) => {
    let img = document.createElement('img');
    // @ts-ignore
    img.src_async = 'https://gw.alicdn.com/tfs/TB1MRC_cvb2gK0jSZK9XXaEgFXa-1701-1535.png';
    document.body.appendChild(img);

    img.onload = async () => {
      await snapshot();
      let text = document.createTextNode('text');
      img.appendChild(text);
      await snapshot();

      done();
    };
  });

  it('new Image', (done) => {
    const img = new Image();
    img.onload = img.onerror = (evt) => {
      done();
    };
    // @ts-ignore
    img.src_async = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
  });
  
  it('won not leak when overwrite src', (done) => {
    const img = new Image();
    img.onload = img.onerror = (evt) => {
      done();
    };
    // @ts-ignore
    img.src_async = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    // @ts-ignore
    img.src_async = 'https://gw.alicdn.com/tfs/TB1MRC_cvb2gK0jSZK9XXaEgFXa-1701-1535.png';
  });

  it('set src property setter', async (done) => {
    const img = createElement('img', {
      src: 'assets/rabbit.png'
    }) as HTMLImageElement;
    BODY.appendChild(img);
    // @ts-ignore
    let src = await img.src_async;
    expect(src).toBe(`http://localhost:${location.port}/public/assets/rabbit.png`);
    // have to wait for asset load?
    await snapshot(0.1);
    // @ts-ignore
    img.src_async = 'assets/solidblue.png';
    await snapshot(0.1);
    src = await img.src;
    expect(src).toBe(`http://localhost:${location.port}/public/assets/solidblue.png`);
    done();
  });

  it('read image size through property', async (done) => {
    const img = document.createElement('img');
    img.onload = async () => {
      let w = await img.width;
      let h = await img.height;
      expect(w).toBe(70);
      expect(h).toBe(72);
      await snapshot();
      done();
    };
    // @ts-ignore
    img.src_async = 'assets/rabbit.png';
    BODY.appendChild(img);
  });

  it('change image src dynamically', async (done) => {
    const img = createElement('img', {
      src: 'assets/rabbit.png'
    }) as HTMLImageElement;
    BODY.appendChild(img);
    await snapshot(0.2);
    // @ts-ignore
    img.src_async = 'assets/300x150-green.png';
    await snapshot(0.2);
    done();
  });

  it('support base64 data url', async (done) => {
    var img = document.createElement('img');
    // @ts-ignore
    img.src_async = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAIAAAC0tAIdAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAACJJREFUKFNjZGD4z0AKAKomHpGgFOQK4g0eVY01rEZCCAIAC+rSL3tdVQUAAAAASUVORK5CYII=';
    document.body.appendChild(img);
    await snapshot(0.2);
    done();
  });

  it('minwidth and minheight of image is 0', async (done) => {
    var img = document.createElement('img');
    // @ts-ignore
    img.src_async = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    img.style.minWidth = '0';
    img.style.minHeight = '0';
    img.style.display = 'inline';
    document.body.appendChild(img);
    await snapshot(0.2);
    done();
  });

  it('image size and image natural size', async (done) => {
    var imageURL = 'https://img.alicdn.com/tfs/TB1RRzFeKL2gK0jSZFmXXc7iXXa-200-200.png?network';
    var img = document.createElement('img');
    img.onload = async function() {
      // @ts-ignore
      expect(await img.naturalWidth_async).toEqual(200);
      // @ts-ignore
      expect(await img.naturalHeight_async).toEqual(200);
      done();
    };
    // @ts-ignore
    img.src_async = imageURL;
    Object.assign(img.style, {
      width: '20px',
      height: '20px',
    });

    document.body.style.background = 'green';
    document.body.appendChild(img);

    // @ts-ignore
    expect(await img.width_async).toEqual(20);
    // @ts-ignore
    expect(await img.height_async).toEqual(20);
  });

  it('should work with loading=lazy', (done) => {
    const img = document.createElement('img');
    // Make image loading=lazy.
    img.setAttribute('loading', 'lazy');
    // @ts-ignore
    img.src_async = 'assets/100x100-green.png';
    img.style.width = '60px';

    document.body.appendChild(img);

    img.onload = async () => {
      await sleep(0.5);
      await snapshot(img);
      done();
    };
  });

  it ('lazy loading should work with scroll', (done) => {
    const img = document.createElement('img');
    img.setAttribute('loading', 'lazy');
    img.style.width = '60px';
    img.style.height = '60px';
    img.style.background = 'red';

    let div = document.createElement('div');
    div.style.width = '60px';
    div.style.height = '2000px';
    div.style.background = 'yellow';

    document.body.appendChild(div);
    document.body.appendChild(img);

    img.onload = async () => {
      window.scroll(0, 2000);
      await snapshot(0.5);
      done();
    };
    // @ts-ignore
    img.src_async = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';

    requestAnimationFrame(() => {
      window.scroll(0, 2000);
    });
  })
  

  it('same image src should only trigger once event', async (done) => {
    const imageURL = 'assets/100x100-green.png';
    const img = document.createElement('img');
    // @ts-ignore
    img.src_async = imageURL;

    var loadCount = 0;
    img.onload = (event) => {
      loadCount++;
      document.body.removeChild(img);
      document.body.appendChild(img);
    };

    document.body.appendChild(img);

    setTimeout(() => {
      if (loadCount == 1) {
        done();
      } else {
        // @ts-ignore
        done('load event should only trigger once.');
      }
    }, 200);
  });

  it('gif can not replay by remove nodes', async (done) => {
    const imageURL = 'assets/10frames-1s.gif';
    const img = document.createElement('img');

    img.onload = async () => {
      // Disable due to CI fail due to snapshot inconsistency.
      // await snapshot(img);
      document.body.removeChild(img);

      // Delay 200ms to play gif.
      setTimeout(async () => {
        // When img re-append to document, to Gif image will continue to play.
        document.body.appendChild(img);
        requestAnimationFrame(async () => {
          await snapshot(img);
          done();
        })

      }, 200);
    };

    document.body.appendChild(img);
    // @ts-ignore
    img.src_async = imageURL;
  });

  it('width property change should work when width of style is not set', async (done) => {
    let img = createElement('img', {
      src: 'assets/300x150-green.png',
      width: 100,
      height: 100,
    });
    BODY.appendChild(img);

    requestAnimationFrame(async () => {
      // @ts-ignore
      img.width_async = 200;
      await snapshot(0.1);
      done();
    });
  });

  it('width property should not work when width of style is auto', async (done) => {
    let img = createElement('img', {
      src: 'assets/300x150-green.png',
      width: 100,
      height: 100,
      style: {
          width: 'auto'
      }
    });
    BODY.appendChild(img);

    await snapshot(0.1);
    done();
  });

  it('can get natualSize from repeat image url', async (done) => {
    const flutterContainer = document.createElement('div');
    flutterContainer.style.height = '100vh';
    flutterContainer.style.display = 'block';
    document.body.appendChild(flutterContainer);

    const colors = ['red', 'yellow', 'black', 'blue', 'green'];
    const images = [
      'assets/100x100-green.png',
      'assets/200x200-green.png',
      'assets/60x60-gg-rr.png',
    ];

    let loadedCount = 0;
    let imgCount = 10;

    for (let i = 0; i < imgCount; i++) {
      const div = document.createElement('div');
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.border = `3px solid ${colors[i % colors.length]}`
      div.appendChild(document.createTextNode(i + ''));

      const img = document.createElement('img');
      img.onload = async () => {
        loadedCount++;
        if (loadedCount == imgCount) {
          await snapshot();
          done();
        }
      };
      // @ts-ignore
      img.src_async = images[i % images.length];
      div.appendChild(img);
      img.style.width = '80px';

      flutterContainer.appendChild(div);
    }
  });
});
