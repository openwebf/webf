describe('css class selector', () => {
  it('style added', async () => {
    const style = <style>{`.red { color: red; }`}</style>;
    const div = <div class="red">{'It should red color'}</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('style removed', async () => {
    const style = <style>{`.red { color: red; }`}</style>;
    const div = <div class="red">{'It should from red to black color'}</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
    document.head.removeChild(style);
    await snapshot();
  });

  it('style removed later', async (done) => {
    const style = <style>{`.blue { color: blue; }`}</style>;
    const div = <div class="blue">{'It should from blue to black color'}</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
    requestAnimationFrame(async () => {
      document.head.removeChild(style);
      await snapshot();
      done();
    });
  });

  it('two style added', async () => {
    const style1 = <style>{`.txt { color: red; }`}</style>;
    const style2 = <style>{`.txt { font-size: 20px; }`}</style>;
    const div = <div class="txt">{'It should red color and 20px'}</div>;
    document.head.appendChild(style1);
    document.body.appendChild(div);
    document.head.appendChild(style2);

    await snapshot();
  });

  it('one style removed', async () => {
    const style1 = <style>{`.txt { color: red; }`}</style>;
    const style2 = <style>{`.txt { font-size: 20px; }`}</style>;
    const div = <div class="txt">{'It should black color and 20px'}</div>;
    document.head.appendChild(style1);
    document.body.appendChild(div);
    document.head.appendChild(style2);
    document.head.removeChild(style1);

    await snapshot();
  });

  it('one inline style removed', async () => {
    const style1 = <style>{`.txt { color: red; }`}</style>;
    const style2 = <style>{`.txt { font-size: 20px; }`}</style>;
    const div = <div style={{color: 'yellow'}} class="txt">{'It should from yellow to red and 20px to 16px'}</div>;
    document.head.appendChild(style1);
    document.head.appendChild(style2);
    document.body.appendChild(div);
    await snapshot();
    div.style.removeProperty('color');
    await snapshot();
    document.head.removeChild(style2);
    await snapshot();
  });

  it('001', async () => {
    const style = <style>{`div.div1 { color: red; }`}</style>;
    const div = <div class="div11">001 Filler Text</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('002', async () => {
    const style = <style>{`div.div1 { color: red; }`}</style>;
    const div = <div class="div1">002 Filler Text</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('003', async () => {
    const style = <style>{`.div1 { color: red; }`}</style>;
    const div = <div class="div1">003 Filler Text</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('004', async () => {
    const style = <style>{`div.bar.foo.bat { color: red; }`}</style>;
    const div = <div class="foo bar bat"> 004 Filler Text</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();   
  });

  it('005', async () => {
    const style = <style>{`.teST { color: green; } .TEst { background: red; color: yellow; }`}</style>;
    const p = <p class="teST"> 005 This text should be green.</p>;
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('006', async () => {
    const style = <style>{`p { background: green; color: white; } .fail.test { background: red; color: yellow; }`}</style>;
    const p = <p class="pass test"> 006 This should have a green background.</p>;
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('007', async () => {
    const style = <style>{`p { background: red; color: yellow; } .pass.test { background: green; color: white; }`}</style>;
    const p = <p class="pass test"> 007 This should have a green background.</p>;
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('008', async () => {
    const style = <style>{`p { background: red; color: yellow; } .pass { background: green; color: white; }`}</style>;
    const p = <p class="pass test"> 008 This should have a green background.</p>;
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('009', async () => {
    const style = <style>{`p { background: red; color: yellow; } .test { background: green; color: white; }`}</style>;
    const p1 = <p class= "test line"> This line should be green.</p>
    const p2 = <p class= "line test"> This line should be green.</p>
    const p3 = <p class= " test line"> This line should be green.</p>
    const p4 = <p class= " line test"> This line should be green.</p>
    const p5 = <p class= "test line "> This line should be green.</p>
    const p6 = < p class= "line test "> This line should be green.</p>
    const p7 = < p class= " test line "> This line should be green.</p>
    const p8 = < p class= " line test "> This line should be green.</p>
    document.head.appendChild(style);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    await snapshot();
  });

  it('010', async () => {
    const style = <style>{`.rule1 { background: red; color: yellow; } .rule2 { background: green; color: white; }`}</style>;
    const p = <p class="rule2 rule1"> 010 This should have a green background.</p>;
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });
});
