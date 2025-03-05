describe('Background-position', () => {
  it('center', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/cat.png)',
      backgroundPosition: 'center',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position1);
    append(BODY, position);
    await snapshot(1);
  });

  it('left', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position2 = document.createElement('div');
    setElementStyle(position2, {
      width: '360px',
      height: '200px',
      backgroundImage: 'url(assets/rabbit.png)',
      backgroundPosition: 'left',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position2);

    append(BODY, position);
    await snapshot(1);
  });

  it('top', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position3 = document.createElement('div');
    setElementStyle(position3, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'top',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position3);

    append(BODY, position);
    await snapshot(1);
  });

  it('right', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });

    const position4 = document.createElement('div');
    setElementStyle(position4, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'right',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position4);

    append(BODY, position);
    await snapshot(1);
  });

  it('bottom', async () => {
    // position
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });
    const position5 = document.createElement('div');
    setElementStyle(position5, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'bottom',
      backgroundRepeat: 'no-repeat',
    });
    position.appendChild(position5);
    append(BODY, position);
    await snapshot(1);
  });

  it('right center', async () => {
    const position = document.createElement('div');
    setElementStyle(position, {
      width: '360px',
      height: '200px',
      marginTop: '10px',
      display: 'flex',
      flexDirection: 'row',
    });
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      backgroundImage:
        'url(assets/rabbit.png)',
      backgroundPosition: 'right center',
      backgroundRepeat: 'no-repeat',
    });
    append(position, div);
    append(BODY, position);
    await snapshot(1);
  });

  it('should works with length type', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) no-repeat yellow',
      backgroundPosition: '40px 60px',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works with length type and background-repeat of repeat', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) repeat yellow',
      backgroundPosition: '40px 60px',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works with percentage type', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 80% 40% no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works with mixing type 1', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 80% 40px no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works with mixing type 2', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 40px top no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works with mixing type 3', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) 30% bottom no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works when background image size is bigger than container size', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '60px',
      height: '80px',
      background: 'url(assets/cat.png) 20px bottom no-repeat yellow',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works with background-position-x', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) no-repeat yellow',
      backgroundPositionX: '50px',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it('should works with background-position-y', async () => {
    const position1 = document.createElement('div');
    setElementStyle(position1, {
      width: '120px',
      height: '120px',
      background: 'url(assets/cat.png) no-repeat yellow',
      backgroundPositionY: 'bottom',
    });
    append(BODY, position1);
    await snapshot(1);
  });

  it("computed", async (done) => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        'font-size': '40px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    target.onmount = () => {
      test_computed_value('background-position', '1px', '1px 50%');
      test_computed_value('background-position', '1px center', '1px 50%');
      test_computed_value('background-position', '-2% -3%');
      test_computed_value('background-position', '5% top', '5% 0%');
      test_computed_value('background-position', 'center', '50% 50%');
      test_computed_value('background-position', 'center center', '50% 50%');
      test_computed_value('background-position', 'center 6px', '50% 6px');
      test_computed_value('background-position', 'center left', '0% 50%');
      // test_computed_value('background-position', 'center right 7%', '93% 50%');
      test_computed_value('background-position', 'center bottom', '50% 100%');
      // test_computed_value('background-position', 'center top 8px', '50% 8px');
      test_computed_value('background-position', 'left', '0% 50%');
      test_computed_value('background-position', 'right 9%', '100% 9%');
      // test_computed_value('background-position', 'left 10px center', '10px 50%');
      // test_computed_value('background-position', 'right 11% bottom', '89% 100%');
      // test_computed_value('background-position', 'left 12px top 13px', '12px 13px');
      test_computed_value('background-position', 'right center', '100% 50%');
      test_computed_value('background-position', 'left bottom', '0% 100%');
      // test_computed_value('background-position', 'right top 14%', '100% 14%');
      test_computed_value('background-position', 'bottom', '50% 100%');
      // test_computed_value('background-position', 'top 15px center', '50% 15px');
      // test_computed_value('background-position', 'bottom 16% left', '0% 84%');
      // test_computed_value(
      //   'background-position',
      //   'top 17px right -18px',
      //   'calc(100% + 18px) 17px'
      // );
      test_computed_value('background-position', 'bottom center', '50% 100%');
      test_computed_value('background-position', 'top left', '0% 0%');
      // test_computed_value('background-position', 'bottom right 19%', '81% 100%');
      test_computed_value(
        'background-position',
        'calc(10px + 0.5em) calc(10px - 0.5em)',
        '30px -10px'
      );
      test_computed_value(
        'background-position',
        'calc(10px - 0.5em) calc(10px + 0.5em)',
        '-10px 30px'
      );

      // See background-computed.html for a test with multiple background images.
      test_computed_value(
        'background-position',
        '12px 13px'
      );

      done();
    }
  })
});
