describe("css pseudo selector", () => {
  it("001", async () => {
    const style = document.createElement('style');
    style.innerHTML = `
      .div1::before {
        content: '';
        display: block;
        width: 30px;
        height: 30px;
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: '';
        display: block;
        width: 30px;
        height: 30px;
        background-color: blue;
        margin-left: 10px;
    }`;

    const div = createElement('div', {
      className: 'div1'
    }, [createText('001 Before && After')]);
    div.setAttribute("style", "border:5px solid blue");
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("002", async () => {
    const style = <style>{`
      .div1::before {
        content: 'A';
        display: block;
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'B';
        display: block;
        background-color: blue;
        margin-left: 10px;
    }`}</style>;
    const div = <div class="div1">{'002 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("003", async () => {
    const style = <style>{`
      .div1::before {
        content: 'A';
        display: block;
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'B';
        display: block;
        background-color: blue;
        margin-left: 10px;
    }`}</style>;
    const div = <div>{'003 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1";
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("004", async () => {
    const style = <style>{`
      .div1::before {
        content: before;
        display: none;
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: after;
        display: none;
        background-color: blue;
        margin-left: 10px;
    }`}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1";
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('005', async () => {
    const style = <style>{`
      .div1::before {
        content: 'AAA';
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'BBB';
        background-color: blue;
        margin-left: 10px;
    }`}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1";
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();

    div.style.display = 'none';
    await snapshot();
  });

  it('006', async () => {
    const style = <style>{`
      .div1::before {
        content: 'AAA';
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'BBB';
        background-color: blue;
        margin-left: 10px;
    }`}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1";
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();

    document.body.removeChild(div);
    await snapshot();
  });

  it('007', async () => {
    const style = <style>{`
      .div1::before {
        content: 'AAA';
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'BBB';
        background-color: blue;
        margin-left: 10px;
      }
      .text-box:before {
        border: 5px solid #000;
      }
      .text-box:after {
        border: 5px solid red;
      }
    
    `}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1 text-box";
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();

    document.body.removeChild(div);
    await snapshot();
  });

  it('008', async () => {
    const style = <style>{`
      
      #pro:before {
        border: 2px solid green;
      }
      #pro:after {
        border: 2px solid yellow;
      }
    
      .div1::before {
        content: 'AAA';
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'BBB';
        background-color: blue;
        margin-left: 10px;
      }
      .text-box:before {
        border: 5px solid #000;
      }
      .text-box:after {
        border: 5px solid red;
      }
     
    
    `}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1 text-box";
    div.id = 'pro';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();

    document.body.removeChild(div);
    await snapshot();
  });

  it('pseudo should activate events', async (done) => {
    const style = <style>{`
      #pro:before {
        border: 2px solid green;
      }
      #pro:after {
        border: 2px solid yellow;
      }
    
      .div1::before {
        content: 'AAA';
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'BBB';
        background-color: blue;
        margin-left: 10px;
      }
      .text-box:before {
        border: 5px solid #000;
      }
      .text-box:after {
        border: 5px solid red;
      }
    `}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1 text-box";
    div.id = 'pro';

    div.onclick = () => {
      done();
    }

    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();

    await simulateClick(0, 0);
  });

  it('pseudo should works when toggle className', async () => {
    const style = <style>{`
      #pro:before {
        border: 2px solid green;
      }
      #pro:after {
        border: 2px solid yellow;
      }
    
      .div1::before {
        content: 'AAA';
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'BBB';
        background-color: blue;
        margin-left: 10px;
      }
      .text-box:before {
        border: 5px solid #000;
      }
      .text-box:after {
        border: 5px solid red;
      }
    `}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1 text-box";
    div.id = 'pro';

    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();

    div.className = 'div1';
    div.id = '';
    await snapshot();
  });

  it('border-radius can inherit in pseduo', async () => {
    const style = <style>{`
      #pro:before {
        border-radius: inherit;
        border: 2px solid green;
      }
      #pro:after {
        border: 2px solid yellow;
        border-radius: inherit;
      }
    
      .div1 {
        border-radius: 50%;
      }
    
      .div1::before {
        content: 'AAA';
        background-color: red;
        margin-left: 10px;
      }
      .div1::after {
        content: 'BBB';
        background-color: blue;
        margin-left: 10px;
      }
    `}</style>;
    const div = <div>{'004 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    div.className = "div1 text-box";
    div.id = 'pro';

    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });
});
