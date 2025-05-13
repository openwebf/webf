describe('FontFamily', () => {
  it('should works in english', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('should works in chinese', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('works with inheritance', async (done) => {
    let div1;
    let div2;
    let div = createElement('div', {
      style: {
        position: 'relative',
        width: '300px',
        height: '200px',
        backgroundColor: 'grey',
      }
    }, [
      (div1 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightgreen',
        }
      }, [
        createText('inherited font-family')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          fontFamily: 'arial',
        }
      }, [
        createText('not inherited font-family')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        fontFamily: 'Songti SC'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.fontFamily = 'Tahoma';
      await snapshot();
      done();
    });
  });

  it("computed", (done) => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    target.addEventListener('onscreen', () => {

      test_computed_value('font-family', 'serif', 'Times, Times New Roman, Noto Serif, Songti SC, Songti TC, Hiragino Mincho ProN, AppleMyungjo, Apple SD Gothic Neo');
      test_computed_value('font-family', 'sans-serif', 'Helvetica, Roboto, PingFang SC, PingFang TC');
      test_computed_value('font-family', 'cursive', 'Snell Roundhand, Apple Chancery, DancingScript, Comic Sans MS');
      test_computed_value('font-family', 'fantasy', 'Papyrus, Impact');
      test_computed_value('font-family', 'monospace', 'Courier, Courier New, DroidSansMono, Monaco, Heiti SC, Heiti TC');
      test_computed_value(
        'font-family',
        'serif, sans-serif, cursive, fantasy, monospace',
        'Times, Times New Roman, Noto Serif, Songti SC, Songti TC, Hiragino Mincho ProN, AppleMyungjo, Apple SD Gothic Neo, Helvetica, Roboto, PingFang SC, PingFang TC, Snell Roundhand, Apple Chancery, DancingScript, Comic Sans MS, Papyrus, Impact, Courier, Courier New, DroidSansMono, Monaco, Heiti SC, Heiti TC'
      );
  
      test_computed_value('font-family', 'Helvetica, Verdana, sans-serif', 'helvetica, verdana, Helvetica, Roboto, PingFang SC, PingFang TC');
      test_computed_value('font-family', 'New Century Schoolbook, serif', 'new century schoolbook, Times, Times New Roman, Noto Serif, Songti SC, Songti TC, Hiragino Mincho ProN, AppleMyungjo, Apple SD Gothic Neo');
      test_computed_value('font-family', '"21st Century", fantasy', '21st century, Papyrus, Impact');

      done();
    });
  })
});
