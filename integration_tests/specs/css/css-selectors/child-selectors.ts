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
})
