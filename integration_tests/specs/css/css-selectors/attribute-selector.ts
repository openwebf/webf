describe('css attribute selector', () => {
    it('001', async () => {
        const style = <style>{`[id] { color: green; }`}</style>;
        const div = <div id="div1">001 should be green</div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    it('002', async () => {
        const style = <style>{`[id=div1] { color: green; }`}</style>;
        const div = <div id="div1">002 should be green</div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    it('003', async () => {
        const style = <style>{`[class~=est] { color: green; }`}</style>;
        const div1 = <div class="t estDiv">should not be green</div>;
        const div2 = <div class="t est">003 should be green</div>;
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        await snapshot();
    });
    
    it('004', async () => {
        const style = <style>{`div[CLASS] { color: green; }`}</style>;
        const div = <div class="div1">004 should be green</div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    it('005', async () => {
        const style = <style>{`[class= "class1"][id = "div1"][class= "class1"][id = "div1"][id = "div1"] { color: green;}`}</style>;
        const div = <div class="class1" id = "div1">005 should be green</div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    // error
    xit('006', async () => {
        const style = <style>{`[1digit], div { color: green; }`}</style>;
        const div = <div>006 Filler Text</div>
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    it('007', async () => {
        const style = <style>{`div[class^="a"]  { color: green; }`}</style>;
        const div1 = <div class="abc">7 should be green</div>
        const div2 = <div class="acb">should be green</div>
        const div3 = <div class="bac">should not be green</div>
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        document.body.appendChild(div3);
        await snapshot();
    });

    it('008', async () => {
        const style = <style>{`div[class^="a"]  { color: green; }`}</style>;
        const div1 = <div class="abc">8 should be green</div>
        const div2 = <div class="acb">should be green</div>
        const div3 = <div class="bac">should not be green</div>
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        document.body.appendChild(div3);
        await snapshot();
    });

    it('009', async () => {
        const style = <style>{`div[class$="c"]  { color: green; }`}</style>;
        const div1 = <div class="abc">9 should be green</div>
        const div2 = <div class="acb">should not be green</div>
        const div3 = <div class="bac">should be green</div>
        for (var oldStyle in document.getElementsByTagName("style")) {
          document.head.removeChild(oldStyle);
        }
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        document.body.appendChild(div3);
        await snapshot();
    });

    it('010', async () => {
        const style = <style>{`div[class*="c"] { color: green; }`}</style>;
        const div1 = <div class="abc">10 should be green</div>
        const div2 = <div class="acb">should be green</div>
        const div3 = <div class="bac">should be green</div>
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        document.body.appendChild(div3);
        await snapshot();
    });

    it('011', async () => {
        const style = <style>{`div[class|="a"] { color: green; }`}</style>;
        const div1 = <div class="a">11 should be green</div>
        const div2 = <div class="a-test">should be green</div>
        const div3 = <div class="b-test">should not be green</div>
        const div4 = <div class="c-test">should not be green</div>
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        document.body.appendChild(div3);
        document.body.appendChild(div4);
        await snapshot();
    });
});
