fdescribe("css pseudo selector", () => {
  it("001", async () => {
    const style = <style>{`
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
    }`}</style>;
    const div = <div class="div1">{'001 Before && After'}</div>;
    div.setAttribute("style", "border:5px solid blue");
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });
});
