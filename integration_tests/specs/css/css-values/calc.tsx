describe("calc", () => {
  it("001", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(100px +100px)",
          height: "calc(100px -50px)",
          backgroundColor: "green"
        }
      }, [createText("001")]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it("002", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(100px- 50px)",
          height: "calc(20px+ 30px)",
          backgroundColor: "green"
        }
      }, [createText("002")]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it("003", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(100px + 100px)",
          height: "calc(100px - 50px)",
          backgroundColor: "green"
        }
      }, [createText("003")]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it("004", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(20px*5)",
          height: "calc(300px/2)",
          backgroundColor: "green"
        }
      }, [createText("004")]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it("005", async () => {
    document.head.appendChild(
      createStyle(`
      :root {
        --num1: 20px;
        --num2: 20px;
      }
      .container {
        transform: translate(calc(var(--num1) + var(--num2)), 20px);
        background: green;
      }
    `)
    );

    document.body.appendChild(
      <div class='container'>
          <h2>The text should be green.</h2>
      </div>
    );
    await snapshot();
  });

  it('should works when clac same kind of length value', async () => {
    let box = createElement('div', {
      style: {
        width: 'calc(100vw - 50vw)',
        height: 'calc(100vh - 50vh)',
        background: 'green'
      }
    }, [
      createText('AAAAA')
    ]);
    document.body.appendChild(box);
    await snapshot();
  });

  it('should works when combine calc with vars', async () => {
    let box = createElement('div', {
      style: {
        width: 'calc(45* 1px * var(--base_size_ratio, 1))',
        height: 'calc(45* 1px * var(--base_size_ratio, 1))',
        background: 'green'
      }
    }, [
      createText('This box should be green')
    ]);
    document.body.appendChild(box);
    await snapshot();
  });

  it('should work with clamp() function', async () => {
    let box = createElement('div', {
      style: {
        width: 'clamp(100px, 200px, 150px)', // Should be 150px (clamped between 100px and 150px)
        height: 'clamp(50px, 25px, 100px)',  // Should be 50px (25px clamped to minimum of 50px)
        background: 'green'
      }
    }, [
      createText('clamp test')
    ]);
    document.body.appendChild(box);
    await snapshot();
  });

  it('should work with clamp() using percentages', async () => {
    let container = createElement('div', {
      style: {
        width: '400px',
        height: '300px',
        background: 'lightgray'
      }
    }, [
      createElement('div', {
        style: {
          width: 'clamp(100px, 50%, 150px)', // 50% of 400px = 200px, clamped to 150px
          height: 'clamp(50px, 20%, 100px)', // 20% of 300px = 60px
          background: 'blue'
        }
      }, [createText('clamp %')])
    ]);
    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with clamp() in calc expressions', async () => {
    let box = createElement('div', {
      style: {
        width: 'calc(clamp(50px, 100px, 200px) + 50px)', // 100px + 50px = 150px
        height: 'calc(clamp(25px, 10px, 50px) * 2)',      // 25px * 2 = 50px
        background: 'green'
      }
    }, [
      createText('clamp+calc')
    ]);
    document.body.appendChild(box);
    await snapshot();
  });

  it('should work with clamp() using viewport units', async () => {
    let box = createElement('div', {
      style: {
        width: 'clamp(100px, 25vw, 200px)',
        height: 'clamp(50px, 15vh, 150px)',
        background: 'green'
      }
    }, [
      createText('clamp vw/vh')
    ]);
    document.body.appendChild(box);
    await snapshot();
  });

  it('should work with round() function', async () => {
    let box = createElement('div', {
      style: {
        width: 'round(123px, 10px)',      // rounds to 120px
        height: 'round(127px, 10px)',     // rounds to 130px  
        background: 'green'
      }
    }, [
      createText('round')
    ]);
    document.body.appendChild(box);
    await snapshot();
  });

  it('should work with round() using different strategies', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: '10px'
      }
    }, [
      createElement('div', {
        style: {
          width: 'round(nearest, 15px, 10px)', // 15px -> 20px
          height: '30px',
          background: 'red'
        }
      }, [createText('nearest')]),
      createElement('div', {
        style: {
          width: 'round(up, 15px, 10px)',      // 15px -> 20px
          height: '30px',
          background: 'blue'
        }
      }, [createText('up')]),
      createElement('div', {
        style: {
          width: 'round(down, 15px, 10px)',    // 15px -> 10px
          height: '30px',
          background: 'green'
        }
      }, [createText('down')]),
      createElement('div', {
        style: {
          width: 'round(to-zero, -15px, 10px)', // -15px -> -10px
          height: '30px',
          background: 'purple'
        }
      }, [createText('to-zero')])
    ]);
    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with mod() function', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: '5px'
      }
    }, [
      createElement('div', {
        style: {
          width: 'mod(140px, 30px)',  // 140 % 30 = 20px
          height: '30px',
          background: 'red'
        }
      }, [createText('mod 140/30')]),
      createElement('div', {
        style: {
          width: 'mod(18px, 5px)',    // 18 % 5 = 3px
          height: '30px',
          background: 'blue'
        }
      }, [createText('mod 18/5')])
    ]);
    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with rem() function', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: '5px'
      }
    }, [
      createElement('div', {
        style: {
          width: 'rem(140px, 30px)',  // 140 % 30 = 20px
          height: '30px',
          background: 'green'
        }
      }, [createText('rem 140/30')]),
      createElement('div', {
        style: {
          width: 'rem(-18px, 5px)',   // -18 % 5 = -3px (preserves sign)
          height: '30px',
          background: 'purple'
        }
      }, [createText('rem -18/5')])
    ]);
    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with stepped value functions in calc()', async () => {
    let box = createElement('div', {
      style: {
        width: 'calc(round(55px, 10px) + 50px)',    // 60px + 50px = 110px
        height: 'calc(mod(130px, 40px) * 2)',       // 10px * 2 = 20px
        background: 'green'
      }
    }, [
      createText('stepped+calc')
    ]);
    document.body.appendChild(box);
    await snapshot();
  });

  function createStyle(text) {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(text));
    return style;
  }
});
