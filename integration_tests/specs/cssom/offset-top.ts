describe('OffsetTop In Scrollable Parent', () => {
  function createDOM(onParentMount, onChildMount, onAbsoluteChildMount) {
    // Create parent div
    const parent = document.createElement("div");
    parent.id = "parent";
    parent.style.overflow = "scroll";
    parent.style.height = "100px";
    parent.style.position = "relative";
    // @ts-ignore
    parent.ononscreen = onParentMount;

    // Create spacer div
    const spacer = document.createElement("div");
    spacer.id = "spacer";
    spacer.style.height = "200px";

    // Create child div
    const child = document.createElement("div");
    child.id = "child";
    child.style.backgroundColor = 'red';
    // @ts-ignore
    child.ononscreen = onChildMount;

    // Create absolute-child div
    const absoluteChild = document.createElement("div");
    absoluteChild.id = "absolute-child";
    absoluteChild.style.position = "absolute";
    absoluteChild.style.top = "41px";
    absoluteChild.style.left = "43px";
    absoluteChild.style.backgroundColor = 'blue';
    // @ts-ignore
    absoluteChild.ononscreen = onAbsoluteChildMount;

    // Append elements to parent
    parent.appendChild(spacer);
    parent.appendChild(child);
    parent.appendChild(absoluteChild);

    // Append parent to body
    document.body.appendChild(parent);
  }

  it('001', async (done) => {
    createDOM(function onParentMount() {
    }, function onChildMount(e) {
      const child = e.target;
      assert_equals(child!.offsetTop, 200, "Child is after spacer");
      assert_equals(child!.offsetLeft, 0, "Child is flush left");
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      assert_equals(absChild!.offsetTop, 41, "Abspos child is y-positioned");
      assert_equals(absChild!.offsetLeft, 43, "Abspos child is x-positioned");
      done();
    });
  });

  it('002', async (done) => {
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.scrollTop = 100;
    }, function onChildMount(e) {
      const child = e.target;
      assert_equals(child.offsetTop, 200, "Child is after spacer");
      assert_equals(child.offsetLeft, 0, "Child is flush left");
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      assert_equals(absChild.offsetTop, 41, "Abspos child is y-positioned");
      assert_equals(absChild.offsetLeft, 43, "Abspos child is x-positioned");
      done();
    });
  });

  it('003', async (done) => {
    createDOM(function onParentMount(e) {
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
      });
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        done();
      });
    });
  });

  it('004', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);

  });

  it('005', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });

  it('006', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      parent.style.borderTop = "23px solid yellow";
      parent.style.borderLeft = "19px solid yellow";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });

  it('007', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      parent.style.borderTop = "23px solid yellow";
      parent.style.borderLeft = "19px solid yellow";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      child.style.paddingTop = "31px";
      child.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      absChild.style.paddingTop = "31px";
      absChild.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });

  it('008', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      parent.style.borderTop = "23px solid yellow";
      parent.style.borderLeft = "19px solid yellow";
      parent.style.paddingTop = "31px";
      parent.style.paddingLeft = "37px";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      child.style.paddingTop = "31px";
      child.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 251, "Child is after spacer and margin and parent padding");
        assert_equals(child.offsetLeft, 137, "Child is 100px + parent padding from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      absChild.style.paddingTop = "31px";
      absChild.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });
});

xdescribe('OffsetTop in ListView Parent', () => {
  function createDOM(onParentMount, onChildMount, onAbsoluteChildMount) {
    // Create parent div
    const parent = document.createElement("webf-listview");
    parent.id = "parent";
    parent.style.height = "100px";
    parent.style.position = "relative";
    // @ts-ignore
    parent.ononscreen = onParentMount;

    // Create spacer div
    const spacer = document.createElement("div");
    spacer.id = "spacer";
    spacer.style.height = "200px";

    // Create child div
    const child = document.createElement("div");
    child.id = "child";
    child.style.backgroundColor = 'red';
    // @ts-ignore
    child.ononscreen = onChildMount;

    // Create absolute-child div
    const absoluteChild = document.createElement("div");
    absoluteChild.id = "absolute-child";
    absoluteChild.style.position = "absolute";
    absoluteChild.style.top = "41px";
    absoluteChild.style.left = "43px";
    absoluteChild.style.backgroundColor = 'blue';
    // @ts-ignore
    absoluteChild.ononscreen = onAbsoluteChildMount;

    // Append elements to parent
    parent.appendChild(spacer);
    parent.appendChild(child);
    parent.appendChild(absoluteChild);

    // Append parent to body
    document.body.appendChild(parent);
  }

  it('001', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount() {
    }, function onChildMount(e) {
      const child = e.target;
      assert_equals(child!.offsetTop, 200, "Child is after spacer");
      assert_equals(child!.offsetLeft, 0, "Child is flush left");
      checkedCount++;
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      assert_equals(absChild!.offsetTop, 41, "Abspos child is y-positioned");
      assert_equals(absChild!.offsetLeft, 43, "Abspos child is x-positioned");
      checkedCount++;
    });

    setTimeout(() => {
      assert_equals(checkedCount, 2);
      done();
    }, 1000);
  });

  it('002', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.scrollTop = 100;
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      assert_equals(child.offsetTop, 200, "Child is after spacer");
      assert_equals(child.offsetLeft, 0, "Child is flush left");
      checkedCount++;
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      assert_equals(absChild.offsetTop, 41, "Abspos child is y-positioned");
      assert_equals(absChild.offsetLeft, 43, "Abspos child is x-positioned");
      checkedCount++;
    });

    setTimeout(() => {
      assert_equals(checkedCount, 3);
      done();
    }, 1000);
  });

  it('003', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      });
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      assert_equals(checkedCount, 2);
      done();
    }, 1000);
  });

  it('004', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "66px"
      parent.style.marginLeft = "33px";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      });
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });
    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000)

  });

  it('005', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });

  it('006', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      parent.style.borderTop = "23px solid yellow";
      parent.style.borderLeft = "19px solid yellow";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });

  it('007', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      parent.style.borderTop = "23px solid yellow";
      parent.style.borderLeft = "19px solid yellow";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      child.style.paddingTop = "31px";
      child.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 220, "Child is after spacer and margin");
        assert_equals(child.offsetLeft, 100, "Child is 100px from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      absChild.style.paddingTop = "31px";
      absChild.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });

  it('008', async (done) => {
    let checkedCount = 0;
    createDOM(function onParentMount(e) {
      const parent = e.target;
      parent.style.marginTop = "166px"
      parent.style.marginLeft = "33px";
      parent.style.borderTop = "23px solid yellow";
      parent.style.borderLeft = "19px solid yellow";
      parent.style.paddingTop = "31px";
      parent.style.paddingLeft = "37px";
      checkedCount++;
    }, function onChildMount(e) {
      const child = e.target;
      child.style.marginTop = "20px"
      child.style.marginLeft = "100px";
      child.style.borderTop = "13px solid green";
      child.style.borderLeft = "7px solid green";
      child.style.paddingTop = "31px";
      child.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(child.offsetTop, 251, "Child is after spacer and margin and parent padding");
        assert_equals(child.offsetLeft, 137, "Child is 100px + parent padding from left");
        checkedCount++;
      })
    }, function onAbsoluteChildMount(e) {
      var absChild = e.target;
      absChild.style.borderTop = "13px solid green";
      absChild.style.borderLeft = "7px solid green";
      absChild.style.marginTop = "20px"
      absChild.style.marginLeft = "100px";
      absChild.style.paddingTop = "31px";
      absChild.style.paddingLeft = "37px";
      requestAnimationFrame(() => {
        assert_equals(absChild.offsetTop, 61, "Abspos child is y-positioned and has margin");
        assert_equals(absChild.offsetLeft, 143, "Abspos child is x-positioned and has margin");
        checkedCount++;
      });
    });

    setTimeout(() => {
      expect(checkedCount).toBe(3);
      done();
    }, 1000);
  });
});
