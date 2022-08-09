describe('css attribute selector', () => {
    it('001', async () => {
        const style = <style>{`[id] { color: red; }`}</style>;
        const div = <div id="div1" >001- Filler Text </div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    it('002', async () => {
        const style = <style>{`[id=div1] { color: red; }`}</style>;
        const div = <div id="div1" >002 Filler Text < /div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    it('003', async () => {
        const style = <style>{`[class~=est] { color: red; }`}</style>;
        const div1 = <div class="t estDiv" > Filler Text </div>;
        const div2 = <div class="t est" > 003 Filler Text </div>;
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        await snapshot();
    });
    it('004', async () => {
        const style = <style>{`div[CLASS] { color: red; }`}</style>;
        const div = <div class="div1" > 004 Filler Text </div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });
    it('005', async () => {
        const style = <style>{`[class= "class1"][id = "div1"][class= "class1"][id = "div1"][id = "div1"] { color: red;}`}</style>;
        const div = <div class="class1" id = "div1" > 005 Filler Text </div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });
    // error
    xit('006', async () => {
        const style = <style>{`[1digit], div { color: red; }`}</style>;
        const div = <div> 006 Filler Text</div>
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });
});
