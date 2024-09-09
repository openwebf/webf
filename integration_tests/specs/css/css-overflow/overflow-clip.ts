describe('clip', () => {
  it('should works with basic', async (done) => {
    let image;
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "clip",
      }
    }, [
      (image = createElement('img', {
          src: 'assets/100x100-green.png',
      })) 
    ]);
  
    document.body.appendChild(container);

    onImageLoad(image, async () => {
      await snapshot(0.1);
      done();
    });
  });

  it('should works with children of appear event', async () => {
    let image;
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "clip",
      }
    }, [
      (image = createElement('img', {
          src: 'assets/100x100-green.png',
      })) 
    ]);
  
    image.addEventListener('appear', function onAppear() {});
  
    document.body.appendChild(container);
  
    await snapshot(0.1);
  });

  it('should works with transform', async () => {
    let box = document.createElement('div');
    document.body.style.background= '#f92';
    document.body.style.width= '300px';
    document.body.style.height= '300px';

    box.style.width = '82px';
    box.style.height = '82px';
    box.style.marginLeft = '100px';
    box.style.marginTop = '100px';
    box.style.background = '#6ad0e2';
    box.style.overflow = 'scroll';


    const icon = document.createElement('div');
    icon.style.width = '82px';
    icon.style.height = '82px';
    icon.style.zIndex = 0;
    icon.style.background= '#f32'
    icon.style.transform = 'translate(-32px,0px)';

    box.appendChild(icon);

    document.body.appendChild(box);
    await snapshot(0.1);
  });
});
