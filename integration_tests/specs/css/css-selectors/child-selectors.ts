describe("css child selector", () => {
    it("001", async () => {
        const style = <style>{`div > h1 { color: green; }`}</style>;
        const h1 = <h1>Filler Text</h1 >;
        document.head.appendChild(style);
        document.body.appendChild(h1);
        await snapshot();
    });
    it("002", async () => {
        const style = <style>{`div > h1 { color: green; }`}</style>;
        const div = <div><h1>Filler Text</h1 ></div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });
    
    it("003", async () => {
        const style = <style>{`div > h1 { color: green; }`}</style>;
        const div = <div><blockquote><h1>Filler Text</h1 > </blockquote > </div>;
        document.head.appendChild(style);
        document.body.appendChild(div);
        await snapshot();
    });

    it("004", async () => {
        const style = <style>{`div:first-child { color: green; }`}</style>;
        const div1 = <div>Filler Text</div>;
        const div2 = <div>Filler Text</div>;
        const p = <p>Test passes if the first "Filler Text" above is green and the second one is black.</p>;
        document.head.appendChild(style);
        document.body.appendChild(div1);
        document.body.appendChild(div2);
        document.body.appendChild(p);
        await snapshot();
    });

    it("005", async () => {
        const style = <style>{`div:first-child { color: green; }`}</style>;
        document.body = <body>Filler Text<div>Filler Text</div><div>Filler Text</div></body>;
        document.head.appendChild(style);
        await snapshot();
    });

    fit("006", async () => {
        const style = <style>{`html { color: red; } :root:first-child { color: green; }`}</style>;
        document.body = <body><p>This text should be green.</p></body>;
        document.head.appendChild(style);
        await snapshot();
    });
})
