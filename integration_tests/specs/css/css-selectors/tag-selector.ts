describe('css tag selector', () => {
    fit('001', async () => {
        const style = <style>{`p { color: green; }`}</style>;
        const p1 = <p>This sentence must be green.</p>;
        const p2 = <p>This sentence must be green.</p>;
        const p3 = <p>This sentence must be green.</p>;
        const p4 = <p>This sentence must be green.</p>;
        const p5 = <p>This sentence must be green.</p>;
        document.head.appendChild(style);
        document.body.appendChild(p1);
        document.body.appendChild(p2);
        document.body.appendChild(p3);
        document.body.appendChild(p4);
        document.body.appendChild(p5);
        await snapshot();
    });
});
