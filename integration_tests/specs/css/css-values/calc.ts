describe("calc", () => {
  it("001", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(100px +100px)",
          height: "calc(100px -50px)",
          backgroundColor: "green"
        }
      }, [createText("001")]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it("002", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(100px- 50px)",
          height: "calc(20px+ 30px)",
          backgroundColor: "green"
        }
      }, [createText("002")]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it("003", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(100px + 100px)",
          height: "calc(100px - 50px)",
          backgroundColor: "green"
        }
      }, [createText("003")]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it("004", async () => {
    let div;
    div = createElement(
      "div",
      {
        style: {
          width: "calc(20px*5)",
          height: "calc(300px/2)",
          backgroundColor: "green"
        }
      }, [createText("004")]
    );
    BODY.appendChild(div);
    await snapshot();
  });
});
