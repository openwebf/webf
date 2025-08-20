describe('Transition property', () => {
  it('backgroundColor', async (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      position: 'absolute',
      padding: '30px',
      transition: 'all 1s linear',
    });
    container1.appendChild(document.createTextNode('DIV'));
    await snapshot();

    const style = window.getComputedStyle(container1);
    expect(style['transition-property']).toEqual('all');
    expect(style['transition-delay']).toEqual('0s');
    expect(style['transition-duration']).toEqual('1s');
    expect(style['transition-timing-function']).toEqual('linear');
    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });

    requestAnimationFrame(() => {
      setElementStyle(container1, {
        backgroundColor: 'red',
      });
    });
  });
  it('should works with property value is transform: none  ', async () => {
    let container;
    const wrapper = createElement('div', {
      style: {
        position: 'relative',
        margin: '0 auto',
        width: '200px',
        height: '200px',
        border: '1px solid #000'
      }
    }, [
      container = createElement('div', {
        style: {
          position: 'absolute',
          background: 'red',
          width: '50px',
          height: '50px',
          right: '100%',
          transform: 'translatex(100%)',
          transitionDuration: '300ms',
          transitionProperty: 'right,transform,width,height,top'
        }
      })
    ]);
    document.body.appendChild(wrapper);

    await snapshot();
    container.style.right = '0';
    container.style.transform = 'none';
    await sleep(1);
    await snapshot();
    container.style.right = '100%';
    container.style.transform = 'translatex(100%)';
    await sleep(1);
    await snapshot();
  });

  it('should works when transition property are relative to other animation property', async () => {
    let container;
    const wrapper = createElement('div', {
      style: {
        position: 'relative',
        margin: '0 auto',
        width: '200px',
        height: '200px',
        border: '1px solid #000'
      }
    }, [
      container = createElement('div', {
        style: {
          position: 'absolute',
          background: 'red',
          width: '50px',
          height: '50px',
          right: '100%',
          transform: 'translatex(100%)',
          transitionDuration: '300ms',
          transitionProperty: 'right,transform,width,height,top'
        }
      })
    ]);
    document.body.appendChild(wrapper);

    await snapshot();
    container.style.right = '0';
    container.style.transform = 'none';
    container.style.width = '80px';
    await sleep(1);
    await snapshot();
    container.style.right = '100%';
    container.style.width = '60px';
    container.style.transform = 'translatex(100%)';
    await sleep(1);
    await snapshot();
  });

  it('should works with percentage translate property with width and height', async () => {
    const cssText = `#pop-scribe-wrapper{
  position: fixed;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  z-index: 999;
  background: rgba(0, 0, 0, 0.5);
}
.pop-scribe {
  transform: translateX(-50%) translateY(-183px);
  position: absolute;
  top: 50%;
  left: 50%;
  width: 280px;
  height: 240px;
  z-index: 999;
  border-radius: 6px 6px 0px 0px;
  background-color: blue;
  background-size: 100% 100%;
  background-repeat: no-repeat;
}
.pop-scribe-btn{
  position: absolute;
  bottom: -85.5px;
  width: 280px;
  height: 86px;
  background: #FFFFFF;
  border-radius: 0px 0px 6px 6px;
}
.pop-scribe-study-btn{
  position: absolute;
  top:50%;
  left:50%;
  transform: translateX(-50%) translateY(-50%);
  width: 112px;
  height: 36px;
  line-height:36px;
  background: #F03867;
  border-radius: 18px;
  text-align: center;
  font-family: PingFangSC-Regular;
  font-size: 14px;
  color: #FFFFFF;
  font-weight: 400;
}
.pop-scribe-close {
  position: absolute;
  bottom: 0;
  transform: translateX(-50%) translateY(100%);
  left: 50%;
  width: 30px;
  height: 55px;
  background-color: red;
  background-size: 100% 100%;
}`;
    const style = document.createElement('style');
    style.innerHTML = cssText;
    document.head.appendChild(style);

    // 添加订阅成功弹窗
    let doc = document;
    let popup = doc.createElement('div')
    popup.setAttribute('id', 'pop-scribe-wrapper')
    doc.body.appendChild(popup)

    let subscribePop = doc.createElement('div')
    subscribePop.setAttribute('class', 'pop-scribe')

    // 添加弹窗下方按钮
    let subscribeBtn = doc.createElement('div')
    subscribeBtn.setAttribute('class', 'pop-scribe-btn')
    let btn = doc.createElement('div')
    btn.innerHTML = '学到了'
    btn.setAttribute('class', 'pop-scribe-study-btn')

    subscribePop.appendChild(subscribeBtn)
    subscribeBtn.appendChild(btn);

    // 添加弹窗关闭按钮
    let closePop = doc.createElement('div')
    closePop.setAttribute('class', 'pop-scribe-close')
    subscribeBtn.appendChild(closePop)

    popup.appendChild(subscribePop)

    await snapshot();
  });
});
