describe('css descendent selector', () => {
  it('001', async () => {
      const style = <style>{`div em { color: red; }` }</style>;
      const div = <div id="div1"> 001 Filler Text < /div >;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('002', async () => {
      const style = <style>{`div em { color: red; }`}</style>;
      const div = <div><em>002 Filler Text</em></div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('003', async () => {
      const style = <style>{`div em { color: red; }`}</style>;
      const div = <div><span><em>003 Filler Text</em></span > </div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('004', async () => {
      const style = <style>{`p em { color: red; }`}</style>;
      const div = <div><em>004 Filler Text</em></div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('005', async () => {
      const style = <style>{`div * em { color: red; }`}</style>;
      const div = <div>005 Filler Text</div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('006', async () => {
      const style = <style>{`div * em { color: red; }`}</style>;
      const div = <div><em>006 Filler Text</em></div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('007', async () => {
      const style = <style>{`div * em { color: red; }`}</style>;
      const div = <div><span><em>007 Filler Text</em></span></div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('008', async () => {
      const style = <style>{`div em[id] { color: red; }`}</style>;
      const div = <div><span><em id="em1"> 008 Filler Text </em></span ></div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('009', async () => {
      const style = <style>{`#div em { color: red; }`}</style>;
      const div = <div id="div"><em> 009 Filler Text </em> </div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });  
  it('010', async () => {
      const style = <style>{`#div
                          em { color: red; }`}</style>;
      const div = <div id="div"><em>010 Filler Text </em></div>;
      
      document.head.appendChild(style);
      document.body.appendChild(div);
      await snapshot();
  });
  it('011', async () => {
    const style = <style>{`.div.a .text { color: red; }`}</style>;
    const div = <div class="div a"><div class="text">011 Filler Text </div></div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });
});
