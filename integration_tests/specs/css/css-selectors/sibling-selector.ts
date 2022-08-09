describe("css sibling selector", () => {
  it("001", async () => {
    const style = <style>{`div { color: red; }
    [class=foo] + div { color: green; }
    [class=foo] + div + div { color: green; }
    [class=foo] + div + div + div { color: green; }
    [class=foo] + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div + div + div + div { color: green; }`}</style>;
    const div = <div id='test' class='foo'></div>
    const p1 = <div>This sentence must be green.</div>;
    const p2 = <div>This sentence must be green.</div>;
    const p3 = <div>This sentence must be green.</div>;
    const p4 = <div>This sentence must be green.</div>;
    const p5 = <div>This sentence must be green.</div>;
    const p6 = <div>This sentence must be green.</div>;
    const p7 = <div>This sentence must be green.</div>;
    const p8 = <div>This sentence must be green.</div>;
    const p9 = <div>This sentence must be green.</div>;
    const p10 = <div>This sentence must be green.</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    document.body.appendChild(p10);
    await snapshot();
  });
});
