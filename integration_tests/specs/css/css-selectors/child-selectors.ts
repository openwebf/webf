describe("css child selector", () => {
  it("001", async () => {
    const style = <style>{`div > h1 { color: green; }`}</style>;
    const h1 = <h1>Filler Text</h1>;
    document.head.appendChild(style);
    document.body.appendChild(h1);
    await snapshot();
  });
  it("002", async () => {
    const style = <style>{`div > h1 { color: green; }`}</style>;
    const div = (
      <div>
        <h1>Filler Text</h1>
      </div>
    );
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("003", async () => {
    const style = <style>{`div > h1 { color: green; }`}</style>;
    const div = (
      <div>
        <blockquote>
          <h1>Filler Text</h1>{" "}
        </blockquote>{" "}
      </div>
    );
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it("004", async () => {
    const style = <style>{`div:first-child { color: green; }`}</style>;
    const div1 = <div>Filler Text</div>;
    const div2 = <div>Filler Text</div>;
    const p = (
      <p>
        Test passes if the first "Filler Text" above is green and the second one
        is black.
      </p>
    );
    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(p);
    await snapshot();
  });

  it("005", async () => {
    const style = <style>{`div:first-child { color: green; }`}</style>;
    document.body = (
      <body>
        Filler Text<div>Filler Text</div>
        <div>Filler Text</div>
      </body>
    );
    document.head.appendChild(style);
    await snapshot();
  });

  it("006", async () => {
    const style = <style>{`div:fiRsT-cHiLd { color: green; }`}</style>;
    const div = <div>Filler Text</div>;
    document.body.appendChild(div);
    document.head.appendChild(style);
    await snapshot();
  });

  it("007", async () => {
    const style = (
      <style>{`html { color: red; } :root:first-child { color: green; }`}</style>
    );
    document.body = (
      <body>
        <p>This text should be green.</p>
      </body>
    );
    document.head.appendChild(style);
    await snapshot();
  });

  it("008", async () => {
    const style = (
      <style>{` :first-child  { border: 10px solid blue; }`}</style>
    );
    const div = <div>Filler Text</div>;
    const p = (
      <p>
        Test passes if there is a blue border around the viewport and around
        "Filler Text" above.
      </p>
    );
    document.head.appendChild(style);
    document.body.appendChild(div);
    document.body.appendChild(p);
    await snapshot();
  });

  it("009", async () => {
    const style = <style>{` :root { color: green; }`}</style>;
    const p1 = <p>Should be green </p>;
    const p2 = <p>Should be green </p>;
    const p3 = <p>Should be green </p>;
    const p4 = <p>Should be green </p>;
    const p5 = <p>Should be green </p>;
    document.head.appendChild(style);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    await snapshot();
  });

  it("010", async () => {
    const style = (
      <style>{` 
        :first-child #a {
            color: green;
          }
          :nth-child(n) #b {
            color: green;
          }
          :first-of-type #c {
            color: green;
          }
          :nth-of-type(1) #d {
            color: green;
          }
          :last-of-type #e {
            color: green;
          }
          :last-child #f {
            color: green;
          }
          :nth-last-child(1) #g {
            color: green;
          }
          :nth-last-of-type(n) #h {
            color: green;
          }
        
          #i {
            color: green;
          }
        
          /* NB: not matching intentionally */
          :nth-last-child(2) #i {
            color: red;
          }
        `}</style>
    );
    document.head.appendChild(style);

    const p1 = <p id="a">Should be green</p>;
    const p2 = <p id="b">Should be green</p>;
    const p3 = <p id="c">Should be green</p>;
    const p4 = <p id="d">Should be green</p>;
    const p5 = <p id="e">Should be green</p>;
    const p6 = <p id="f">Should be green</p>;
    const p7 = <p id="g">Should be green</p>;
    const p8 = <p id="h">Should be green</p>;
    const p9 = <p id="i">Should be green</p>;
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    await snapshot();
  });

  it("011", async () => {
    const style = (
      <style>{` 
        :root:first-child #a {
            color: green;
          }
          :root:nth-child(n) #b {
            color: green;
          }
          :root:first-of-type #c {
            color: green;
          }
          :root:nth-of-type(1) #d {
            color: green;
          }
          :root:last-of-type #e {
            color: green;
          }
          :root:last-child #f {
            color: green;
          }
          :root:nth-last-child(1) #g {
            color: green;
          }
          :root:nth-last-of-type(n) #h {
            color: green;
          }
        
          #i {
            color: green;
          }
        
          /* NB: not matching intentionally */
          :root:nth-last-child(2) #i {
            color: red;
          }
        `}</style>
    );

    const p1 = <p id="a">Should be green</p>;
    const p2 = <p id="b">Should be green</p>;
    const p3 = <p id="c">Should be green</p>;
    const p4 = <p id="d">Should be green</p>;
    const p5 = <p id="e">Should be green</p>;
    const p6 = <p id="f">Should be green</p>;
    const p7 = <p id="g">Should be green</p>;
    const p8 = <p id="h">Should be green</p>;
    const p9 = <p id="i">Should be green</p>;

    document.head.appendChild(style);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    await snapshot();
  });

  it("012", async () => {
    const style = (
      <style>{` 
        li:only-child {
            color: green;
        }
        `}</style>
    );
    const ul = (
      <ul>
        <li> 012 Should be green</li>
      </ul>
    );
    document.head.appendChild(style);
    document.body.appendChild(ul);
    await snapshot();
  });

  it("013", async () => {
    const style = (
      <style>{` 
        li:only-child {
            color: green;
        }
        `}</style>
    );
    const ul = (
      <ul>
        <li> 013 Should not be green</li>
        <li> 013 Should not be green</li>
      </ul>
    );
    document.head.appendChild(style);
    document.body.appendChild(ul);
    await snapshot();
  });

  it("014", async () => {
    const style = (
      <style>{` 
      last-child #f {
        color: green;
      }
        `}</style>
    );

    const p = <p>014</p>;
    const p1 = <p id="a">Should be green</p>;
    const p2 = <p id="b">Should be green</p>;
    const p3 = <p id="c">Should be green</p>;
    const p4 = <p id="d">Should be green</p>;
    const p5 = <p id="e">Should be green</p>;
    const p6 = <p id="f">Should be green</p>;
    const p7 = <p id="g">Should be green</p>;
    const p8 = <p id="h">Should be green</p>;
    const p9 = <p id="i">Should be green</p>;

    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    await snapshot();
  });
});
