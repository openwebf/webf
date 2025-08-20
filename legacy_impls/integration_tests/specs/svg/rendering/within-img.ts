function createCaseForErrorUrl(url) {
  return (done) => {
    const img = document.createElement('img');
    img.src = url;
    img.style.width = '100px';
    img.style.height = '100px';
    img.onload = () => {
      done.fail('Unreachable');
    }
    img.onerror = () => {
      done();
    }
    document.body.appendChild(img);
  }
}

function createCaseForSize(width?: string, height?: string) {
  return (done) => {
    const img = document.createElement('img');
    img.src = 'assets/js-icon.svg'
    img.style.border = '1px solid green';
    if (width) img.style.width = width;
    if (height) img.style.height = height;
    img.onload = () => {
      snapshot().then(done, done.fail);
    }
    img.onerror = () => {
      done.fail('Should now throw error');
    }
    document.body.appendChild(img);
  }
}

function createCaseForToggleImg(srcs: string[], hasError?: boolean) {
  return (done) => {
    let i = 0;
    function next() {
      if (i == srcs.length) {
        // snapshot last image
        snapshot().then(done, done.fail);
        return;
      }
      img.src = srcs[i++];
    }
    const img = document.createElement('img');
    img.style.width = img.style.height = '100px';
    img.onload = async () => {
      setTimeout(() => next(), 100);
    }
    img.onerror = () => {
      if (hasError) {
        setTimeout(() => next(), 100);
      } else {
        done.fail('Unreachable');
      }
    }
    document.body.appendChild(img);

    next();
  }
}

describe('SVG rendering within img', () => {
  it('should works with svg', (done) => {
    const img = document.createElement('img');
    img.src = 'assets/js-icon.svg';
    img.style.width = '100px';
    img.style.height = '100px';
    img.onload = async () => {
      await snapshot();
      done();
    }
    document.body.appendChild(img);
  });

  it('should throw error when decode svg file failed', createCaseForErrorUrl('assets/non-svg.svg'));

  it('should throw error when resource is not found', createCaseForErrorUrl('assets/svg-icon-not-found.svg'));

  it('should show large size', createCaseForSize('300px', '300px'));
  it('should auto calc height when has a fixed width', createCaseForSize('100px'));
  it('should auto calc width when has a fixed height', createCaseForSize(undefined, '100px'));
  it('should use natural size when height and width is not fixed', createCaseForSize());

  it('should correct render when switch img src', createCaseForToggleImg([
    'assets/100x100-green.png',
    'assets/js-icon.svg',
  ]));

  it('should render svg after a failed load', createCaseForToggleImg([
    'assets/100x100-green.png',
    'assets/non-svg.svg', // decode error
    'assets/js-icon.svg' // correct image
  ], true))
});
