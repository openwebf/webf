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
});
