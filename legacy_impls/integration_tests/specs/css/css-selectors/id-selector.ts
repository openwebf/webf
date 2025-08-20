describe("css id selector", () => {
  it("001", async () => {
    const style = <style>{`#div1 { color: green; }`}</style>;
    const div = <div id="div1">001 green Filler Text</div>;
    
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("002", async () => {
    const style = <style>{`# div1 { color: green; }`}</style>;
    const div = <div id="div1">002 black Filler Text</div>;
    
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("003", async () => {
    const style = <style>{`div { color: red; } #-div1 { color: green; }`}</style>;
    const div = <div id="-div1">003 green Filler Text</div>;
    
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  xit("004", async () => {
    const style = <style>{`#1digit { color: red; }`}</style>;
    const div = <div id="1digit">004 black Filler Text</div>;
    
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("005", async () => {
    const style = <style>{`div[id=div1] { color: red; } div#div1 { color: green; }`}</style>;
    const div = <div id="div1">005 green Filler Text</div>;
    
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("006", async () => {
    const style = <style>{`div[id=div1] { color: red; } div#div1 { color: green; }`}</style>;
    const div = <div id="div1">006 green Filler Text</div>;
    
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });
});
