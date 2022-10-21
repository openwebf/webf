describe('css combinator selector', () => {
  it('001', async () => {
      const style = <style>{`#div1 > p { color: green; }`}</style>;
      const div = <div id="div1"><p> 001 Filler Text </p></div>;
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('002', async () => {
      const style = <style>{`#div1 + p { color: green; }`}</style>;
      const div = <div id="div1"></div>;
      const p = <p>002 Filler Text </p>
      document.head.appendChild(style);
      document.body.appendChild(div);
      document.body.appendChild(p);
      await snapshot();
  });  
  it('003', async () => {
      const style = <style>{`
          #div1
          +
          p
      {
          color: green;
      }`}</style>;
      const div = <div id="div1"> </div>;
      const p = <p>003 Filler Text </p>
      document.head.appendChild(style);
      document.body.appendChild(div);
      document.body.appendChild(p);
      await snapshot();
  });
})  
