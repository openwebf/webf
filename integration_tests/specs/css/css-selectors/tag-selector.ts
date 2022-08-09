describe("css tag selector", () => {
  it("001", async () => {
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

  fit("002", async () => {
    const style = <style>{`div, blockquote { color: green; }`}</style>;
    const p = <p>Test passes if the "Filler Text" below is green.</p>;
    const blockquote = <blockquote>Filler Text</blockquote>;
    const div = <div>Filler Text</div>;
    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(blockquote);
    document.body.appendChild(div);
    await snapshot();
  });

  fit("003", async () => {
    const style = <style>{`DIV { color: green; }`}</style>;
    const div = <div>Filler Text</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });
});
