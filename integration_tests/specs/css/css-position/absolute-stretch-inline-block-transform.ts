describe("Absolute stretch with inline-block + transform (issue #360)", () => {
  it("absolute child with left/right/top/bottom covers parent box", async () => {
    document.body.style.margin = "0";

    const tag = document.createElement("div");
    tag.style.background =
      "linear-gradient(90deg, rgb(255, 134, 64) 3%, rgba(255, 134, 64, 0.4) 97.33%)";
    tag.style.color = "rgb(255, 134, 64)";
    tag.style.border = "none";
    tag.style.borderRadius = "9px 6px";
    tag.style.padding = "0";
    tag.style.position = "relative";
    tag.style.transform = "skewX(-10deg)";
    tag.style.lineHeight = "44px";
    tag.style.display = "inline-block";
    tag.style.fontSize = "30px";
    tag.style.fontWeight = "550";
    tag.style.maxWidth = "210px";
    tag.style.margin = "20px";
    tag.style.height = "44px";

    const fakeTag = document.createElement("div");
    fakeTag.style.background = "#fff";
    fakeTag.style.borderRadius = "inherit";
    fakeTag.style.bottom = "0";
    fakeTag.style.left = "0";
    fakeTag.style.margin = "2px";
    fakeTag.style.position = "absolute";
    fakeTag.style.right = "0";
    fakeTag.style.top = "0";

    const content = document.createElement("div");
    content.textContent = "超级管理员";

    tag.appendChild(fakeTag);
    tag.appendChild(content);
    document.body.appendChild(tag);

    // Take a visual snapshot for comparison and ensure layout has settled.
    await snapshot();

    const containerWidth = tag.offsetWidth;
    const containerHeight = tag.offsetHeight;
    const overlayWidth = fakeTag.offsetWidth;
    const overlayHeight = fakeTag.offsetHeight;

    // Height is explicitly 44px; overlay should be 2px inset on each edge.
    expect(containerHeight).toBe(44);
    expect(overlayHeight).toBe(40);
    // Width should match container width minus 4px (2px margins on both sides).
    expect(overlayWidth + 4).toBe(containerWidth);
  });
});

