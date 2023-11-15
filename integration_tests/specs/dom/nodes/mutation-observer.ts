// Compares a mutation record to a predefined one
// mutationToCheck is a mutation record from the user agent
// expectedRecord is a mutation record minted by the test
//    for expectedRecord, if properties are omitted, they get default ones
function checkRecords(target, mutationToCheck, expectedRecord) {
  var mr1;
  var mr2;

  function checkField(property, isArray = false) {
    var field = mr2[property];
    if (isArray === undefined) {
      isArray = false;
    }
    if (field instanceof Function) {
      field = field();
    } else if (field === undefined) {
      if (isArray) {
        field = new Array();
      } else {
        field = undefined;
      }
    }
    if (isArray) {
      assert_array_equals(mr1[property], field, property + " didn't match");
    } else {
      expect(mr1[property]).toEqual(field, property + " didn't match");
    }
  }

  assert_equals(mutationToCheck.length, expectedRecord.length, "mutation records must match");
  for (var item = 0; item < mutationToCheck.length; item++) {
    mr1 = mutationToCheck[item];
    mr2 = expectedRecord[item];

    if (mr2.target instanceof Function) {
      assert_equals(mr1.target, mr2.target(), "target node must match");
    } else if (mr2.target !== undefined) {
      assert_equals(mr1.target, mr2.target, "target node must match");
    } else {
      assert_equals(mr1.target, target, "target node must match");
    }

    checkField("type");
    checkField("addedNodes", true);
    checkField("removedNodes", true);
    checkField("previousSibling");
    checkField("nextSibling");
    checkField("attributeName");
    // checkField("attributeNamespace");
    checkField("oldValue");
  }
}

function runMutationTest(node, mutationObserverOptions, mutationRecordSequence, mutationFunction, description, target?: any) {
  (new MutationObserver(moc)).observe(node, mutationObserverOptions);

  function moc(mrl, obs) {
    console.log(mrl);
    if (target === undefined) target = node;
    checkRecords(target, mrl, mutationRecordSequence);
  }

  mutationFunction();
}

describe("MutationObserver Style", function() {
  test(async () => {
    let called = 0;
    const el = document.createElement("div");
    document.body.appendChild(el);
    const m = new MutationObserver(() => {
      called++;
    });
    m.observe(el, { attributes: true });
    el.style.height = "100px";
    await Promise.resolve();
    assert_equals(called, 1, "times callback called");
    el.style.height = "100px";
    await Promise.resolve();
    assert_equals(called, 1, "times callback called");
  }, "Updating style property with the same value does not trigger an observation callback");

  test(async () => {
    let called = 0;
    const el = document.createElement("div");
    document.body.appendChild(el);
    const m = new MutationObserver(() => {
      called++;
    });
    m.observe(el, { attributes: true });
    el.style.cssText = "height:100px";
    await Promise.resolve();
    assert_equals(called, 1, "times callback called");
    el.style.cssText = "height:100px";
    await Promise.resolve();
    assert_equals(called, 2, "times callback called");
  }, "Updating cssText triggers an observation callback");
});

describe("MutationObserver sanity", function() {
  test(() => {
    var m = new MutationObserver(() => {
    });
    assert_throws_exactly(new TypeError("The options object must set at least one of 'attributes', 'characterData', or 'childList' to true."), () => {
      m.observe(document, {});
    });
  }, "Should throw if none of childList, attributes, characterData are true");

  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, { childList: true });
    m.disconnect();
  }, "Should not throw if childList is true");

  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, { attributes: true });
    m.disconnect();
  }, "Should not throw if attributes is true");
  //
  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, { characterData: true });
    m.disconnect();
  }, "Should not throw if characterData is true");

  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, { attributeOldValue: true });
    m.disconnect();
  }, "Should not throw if attributeOldValue is true and attributes is omitted");

  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, { characterDataOldValue: true });
    m.disconnect();
  }, "Should not throw if characterDataOldValue is true and characterData is omitted");

  test(() => {
    var m = new MutationObserver(() => {
    });
    // @ts-ignore
    m.observe(document, { attributes: ["abc"] });
    m.disconnect();
  }, "Should not throw if attributeFilter is present and attributes is omitted");

  test(() => {
    var m = new MutationObserver(() => {
    });
    assert_throws_exactly(new TypeError("The options object may only set 'attributeOldValue' to true when 'attributes' is true or not present."), () => {
      m.observe(document, {
        childList: true, attributeOldValue: true,
        attributes: false
      });
    });
  }, "Should throw if attributeOldValue is true and attributes is false");

  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, {
      childList: true, attributeOldValue: true,
      attributes: true
    });
    m.disconnect();
  }, "Should not throw if attributeOldValue and attributes are both true");

  test(() => {
    var m = new MutationObserver(() => {
    });
    assert_throws_exactly(new TypeError("The options object may only set 'attributeFilter' when 'attributes' is true or not present."), () => {
      m.observe(document, {
        childList: true, attributeFilter: ["abc"],
        attributes: false
      });
    });
  }, "Should throw if attributeFilter is present and attributes is false");

  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, {
      childList: true, attributeFilter: ["abc"],
      attributes: true
    });
    m.disconnect();
  }, "Should not throw if attributeFilter is present and attributes is true");

  test(() => {
    var m = new MutationObserver(() => {
    });
    assert_throws_exactly(new TypeError("The options object may only set 'characterDataOldValue' to true when 'characterData' is true or not present."), () => {
      m.observe(document, {
        childList: true, characterDataOldValue: true,
        characterData: false
      });
    });
  }, "Should throw if characterDataOldValue is true and characterData is false");

  test(() => {
    var m = new MutationObserver(() => {
    });
    m.observe(document, {
      childList: true, characterDataOldValue: true,
      characterData: true
    });
    m.disconnect();
  }, "Should not throw if characterDataOldValue is true and characterData is true");
});

describe("MutationObserver document", () => {
  it("001", async () => {
    var testCounter = 0;
    var document_observer = new MutationObserver(function(sequence) {
      testCounter++;
      if (testCounter == 1) {
        checkRecords(document, sequence,
          [{
            type: "childList",
            addedNodes: function() {
              return [newElement];
            },
            previousSibling: function() {
              return undefined;
            },
            target: document.body
          }]);
      }
    });
    var newElement = document.createElement("span");
    document_observer.observe(document, { subtree: true, childList: true });
    newElement.id = "inserted_element";
    newElement.setAttribute("style", "display: none");
    newElement.textContent = "my new span for n00";
    document.body.appendChild(newElement);
    await Promise.resolve();
    document_observer.disconnect();
  });

  it('002', async () => {
    var testCounter = 0;
    function removalMO(sequence, obs) {
      testCounter++;
      if (testCounter == 1) {
        checkRecords(document, sequence,
          [{type: "childList",
            removedNodes: function () {
              return [ newElement];
            },
            previousSibling: function () {
              return undefined;
            },
            target: document.body}]);
      }
    }
    var document2_observer;
    var newElement = document.createElement("span");
    newElement.id = "inserted_element";
    newElement.setAttribute("style", "display: none");
    newElement.textContent = "my new span for n00";
    document.body.appendChild(newElement);

    document2_observer = new MutationObserver(removalMO);
    document2_observer.observe(document, {subtree:true,childList:true});
    document.body.removeChild(newElement);
    await Promise.resolve();
    document2_observer.disconnect();
  });
});

describe("Mutation Observer disconnect", function() {
  it('001', async () => {
    const n00 = document.createElement('p');
    document.body.appendChild(n00);

    function observerCallback(sequence) {
      assert_equals(sequence.length, 1);
      assert_equals(sequence[0].type, "attributes");
      assert_equals(sequence[0].attributeName, "id");
      assert_equals(sequence[0].oldValue, "latest");
    }

    var observer = new MutationObserver(observerCallback);
    observer.observe(n00, {"attributes": true});
    n00.id = "foo";
    n00.id = "bar";
    observer.disconnect();
    observer.observe(n00, {"attributes": true, "attributeOldValue": true});
    n00.id = "latest";
    observer.disconnect();
    observer.observe(n00, {"attributes": true, "attributeOldValue": true});
    n00.id = "n0000";
    await Promise.resolve();
    observer.disconnect();
  });
});

describe("Mutation Observer callback arguments",  function() {
  it('001', async () => {
    const moTarget = createElement('div', {
      id: 'mo-target'
    }, []);

    const mo = new MutationObserver(function(records, observer) {
      // @ts-ignore
      assert_equals(this, mo);
      assert_equals(arguments.length, 2);
      assert_true(Array.isArray(records));
      assert_equals(records.length, 1);
      assert_true(records[0] instanceof MutationRecord);
      assert_equals(observer, mo);

      mo.disconnect();
    });
    mo.observe(moTarget, {attributes: true});
    moTarget.className = "trigger-mutation";
    await Promise.resolve();
  });
});

describe("MutationObserver takeRecords", function() {
  it('001', async (done) => {
    var n00 = createElement('div', {
      id: 'n00'
    });

    var observer = new MutationObserver(() => {
      done.fail('the observer callback should not fire');
    });
    observer.observe(n00, { "subtree": true,
      "childList": true,
      "attributes": true,
      "characterData": true,
      "attributeOldValue": true,
      "characterDataOldValue": true});
    n00.id = "foo";
    n00.id = "bar";
    n00.className = "bar";
    n00.textContent = "old data";
    // @ts-ignore
    n00.firstChild.data = "new data";

    checkRecords(n00, observer.takeRecords(), [
      {type: "attributes", attributeName: "id", oldValue: "n00"},
      {type: "attributes", attributeName: "id", oldValue: "foo"},
      {type: "attributes", attributeName: "class"},
      {type: "childList", addedNodes: [n00.firstChild]},
      {type: "characterData", oldValue: "old data", target: n00.firstChild}
    ]);

    checkRecords(n00, observer.takeRecords(), []);

    await Promise.resolve();
    done();
  });
});

describe("Mutation Observer Styles", function() {
  it('Changes to CSS declaration block should queue mutation record for style attribute', async () => {
    function createTestElement(style) {
      let wrapper = document.createElement("div");
      wrapper.innerHTML = `<div id="test" style="${style}"></div>`;
      return wrapper.querySelector("#test");
    }
    let elem = createTestElement("z-index: 40;");
    // @ts-ignore
    let style = elem!.style;
    assert_equals(style.cssText, "z-index: 40;");
    // Create an observer for the element.
    let observer = new MutationObserver(function() {});
    // @ts-ignore
    observer.observe(elem, {attributes: true, attributeOldValue: true});
    function assert_record_with_old_value(oldValue, action) {
      let records = observer.takeRecords();
      assert_equals(records.length, 1, "number of mutation records after " + action);
      let record = records[0];
      assert_equals(record.type, "attributes", "mutation type after " + action);
      assert_equals(record.attributeName, "style", "mutated attribute after " + action);
      assert_equals(record.oldValue, oldValue, "old value after " + action);
    }
    style.setProperty("z-index", "41");
    assert_record_with_old_value("z-index: 40;", "changing property in CSS declaration block");
    style.cssText = "z-index: 42;";
    assert_record_with_old_value("z-index: 41;", "changing cssText");
    style.cssText = "z-index: 42;";
    assert_record_with_old_value("z-index: 42;", "changing cssText with the same content");
    style.removeProperty("z-index");
    assert_record_with_old_value("z-index: 42;", "removing property from CSS declaration block");
    // Mutation to shorthand properties should also trigger only one mutation record.
    style.setProperty("margin", "1px");
    assert_record_with_old_value("", "adding shorthand property to CSS declaration block");
    style.removeProperty("margin");
    assert_record_with_old_value("margin: 1px;", "removing shorthand property from CSS declaration block");
    // Final sanity check.
    // @ts-ignore
    assert_equals(elem.getAttribute("style"), "");
  });
});

function log_test(func, expected, description) {
  it( description, async function(done) {
    var actual: string[] = [];
    function log(entry: string) {
      actual.push(entry);
      if (expected.length == actual.length) {
        assert_array_equals(actual, expected);
        done();
      }
    }
    func(log);
  });
}

describe("MutationObserver microtask looping", function() {
  log_test(function(log) {
    log('script start');

    setTimeout(function() {
      log('setTimeout');
    }, 0);

    Promise.resolve().then(function() {
      log('promise1');
    }).then(function() {
      log('promise2');
    });

    log('script end');
  }, [
    'script start',
    'script end',
    'promise1',
    'promise2',
    'setTimeout'
  ], 'Basic task and microtask ordering');

  log_test(function(log) {
    const container = createElement('div', {
      className: 'outer'
    }, [
      createElement('div', {
        className: 'inner'
      })
    ]);
    document.body.appendChild(container);

    // Let's get hold of those elements
    var outer = document.querySelector('.outer');
    var inner = document.querySelector('.inner');

    // Let's listen for attribute changes on the
    // outer element
    new MutationObserver(function() {
      log('mutate');
    }).observe(outer!, {
      attributes: true
    });

    // Here's a click listener...
    function onClick() {
      log('click');
      //
      setTimeout(function() {
        log('timeout');
      }, 0);

      Promise.resolve().then(function() {
        log('promise');
      });
      //
      outer!.setAttribute('data-random', Math.random().toString());
    }

    // ...which we'll attach to both elements
    inner!.addEventListener('click', onClick);
    outer!.addEventListener('click', onClick);

    // Note that this will behave differently than a real click,
    // since the dispatch is synchronous and microtasks will not
    // run between event bubbling steps.
    // @ts-ignore
    inner!.click();
  }, [
    'click',
    'promise',
    'mutate',
    'click',
    'promise',
    'mutate',
    'timeout',
    'timeout'
  ], 'Level 1 bossfight (synthetic click)');
});

function createFragment() {
  var fragment = document.createDocumentFragment();
  fragment.appendChild(document.createTextNode("11"));
  fragment.appendChild(document.createTextNode("22"));
  return fragment;
}

fdescribe("MutationObserver childList", function() {
  it('n00', async () => {
    const n00 = createElement('div', {
      id: 'n00',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    document.body.appendChild(n00);
    runMutationTest(n00,
      {"childList":true, "attributes":true},
      [{type: "attributes", attributeName: "class"}],
      function() { n00.nodeValue = ""; n00.setAttribute("class", "dummy");},
      "childList Node.nodeValue: no mutation");
    await Promise.resolve();
  });

  it('n10', async () => {
    const n10 = createElement('div', {
      id: 'n00',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    runMutationTest(n10,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n10.firstChild],
        addedNodes: function() {return [n10.firstChild]}}],
      function() { n10.textContent = "new data"; },
      "childList Node.textContent: replace content mutation");
  })

  it('n11', async () => {
    const n11 = createElement('p', {
      id: 'n01',
    });
    runMutationTest(n11,
      {"childList":true},
      [{type: "childList",
        addedNodes: function() {return [n11.firstChild]}}],
      function() { n11.textContent = "new data"; },
      "childList Node.textContent: no previous content mutation");
  });

  it('n12', async () => {
    const n12 = createElement('p', {
      id: 'n01',
    });
    runMutationTest(n12,
      {"childList":true, "attributes":true},
      [{type: "attributes", attributeName: "class"}],
      function() { n12.textContent = ""; n12.setAttribute("class", "dummy");},
      "childList Node.textContent: textContent no mutation");
  });

  it('n13', async () => {
    const n13 = createElement('div', {
      id: 'n13',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    runMutationTest(n13,
      {"childList":true},
      [{type: "childList", removedNodes: [n13.firstChild]}],
      function() { n13.textContent = ""; },
      "childList Node.textContent: empty string mutation");
  });

  // it('n20', async () => {
  //   const n20 = createElement('div', {
  //     id: 'n20',
  //   }, [
  //     createText('PAS')
  //   ]);
  //   n20.appendChild(document.createTextNode("S"));
  //   runMutationTest(n20,
  //     {"childList":true},
  //     [{type: "childList",
  //       removedNodes: [n20.lastChild],
  //       previousSibling: n20.firstChild}],
  //     function() { n20.normalize(); },
  //     "childList Node.normalize mutation");
  // });

  it('n30', async () => {
    const n30 = createElement('div', {
      id: 'n30',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    document.body.appendChild(n30);
    let d30;
    const dummy = createElement('div', {
      id: 'dummy'
    }, [
      d30 = createElement('span', {
        id: 'd30'
      }, [ createText('text content') ])
    ]);
    document.body.appendChild(dummy);

    runMutationTest(n30,
      {"childList":true},
      [{type: "childList",
        addedNodes: [d30],
        nextSibling: n30.firstChild}],
      function() { n30.insertBefore(d30, n30.firstChild); },
      "childList Node.insertBefore: addition mutation");
  });

  it('n31', async () => {
    const n31 = createElement('div', {
      id: 'n31',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    document.body.appendChild(n31);
    const dummies = createElement('div', {
      id: 'dummy'
    }, [
      createElement('span', {
        id: 'd30'
      }, [ createText('text content') ])
    ]);
    runMutationTest(n31,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n31.firstChild]}],
      function() { dummies.insertBefore(n31.firstChild!, dummies.firstChild); },
      "childList Node.insertBefore: removal mutation");
  });

  it('n32', async () => {
    const n32 = createElement('div', {
      id: 'n32'
    }, [
      createElement('span', {}, [
        createText('AN')
      ]),
      createElement('span', {}, [
        createText('CH')
      ]),
      createElement('span', {}, [
        createText('GED')
      ]),
    ]);
    document.body.appendChild(n32);
    runMutationTest(n32,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n32.firstChild!.nextSibling],
        previousSibling: n32.firstChild, nextSibling: n32.lastChild},
        {type: "childList",
          addedNodes: [n32.firstChild!.nextSibling],
          nextSibling: n32.firstChild}],
      function() { n32.insertBefore(n32.firstChild!.nextSibling!, n32.firstChild); },
      "childList Node.insertBefore: removal and addition mutations");
  });

  it('n33', async () => {
    const n33 = createElement('div', {
      id: 'n33',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n33);
    var f33 = createFragment();
    runMutationTest(n33,
      {"childList":true},
      [{type: "childList",
        addedNodes: [f33.firstChild, f33.lastChild],
        nextSibling: n33.firstChild}],
      function() { n33.insertBefore(f33, n33.firstChild); },
      "childList Node.insertBefore: fragment addition mutations");
  });

  it('n34', async () => {
    const n34 = createElement('div', {
      id: 'n34',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n34);
    var f34 = createFragment();
    runMutationTest(f34,
      {"childList":true},
      [{type: "childList",
        removedNodes: [f34.firstChild, f34.lastChild]}],
      function() { n34.insertBefore(f34, n34.firstChild); },
      "childList Node.insertBefore: fragment removal mutations");
  });

  it('n35', async () => {
    const n35 = createElement('div', {
      id: 'n35',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n35);

    let d35;
    const dummy = createElement('div', {
      id: 'dummy'
    }, [
      d35 = createElement('span', {
        id: 'd35'
      }, [ createText('text content') ])
    ]);
    BODY.append(dummy);

    runMutationTest(n35,
      {"childList":true},
      [{type: "childList",
        addedNodes: [d35],
        previousSibling: n35.firstChild}],
      function() { n35.insertBefore(d35, null); },
      "childList Node.insertBefore: last child addition mutation");
  });

  it('n40', async () => {
    const n40 = createElement('div', {
      id: 'n40',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n40);
    let d40;
    const dummy = createElement('div', {
      id: 'dummy'
    }, [
      d40 = createElement('span', {
        id: 'd40'
      }, [ createText('text content') ])
    ]);
    BODY.append(dummy);

    runMutationTest(n40,
      {"childList":true},
      [{type: "childList",
        addedNodes: [d40],
        previousSibling: n40.firstChild}],
      function() { n40.appendChild(d40); },
      "childList Node.appendChild: addition mutation");
  });

  it('n41', async () => {
    const n41 = createElement('div', {
      id: 'n41',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n41);

    const dummies = createElement('div', {
      id: 'dummy'
    }, [
      createElement('span', {
        id: 'd35'
      }, [ createText('text content') ])
    ]);
    BODY.append(dummies);

    runMutationTest(n41,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n41.firstChild]}],
      function() { dummies.appendChild(n41.firstChild!); },
      "childList Node.appendChild: removal mutation");
  });

  it('n42', async () => {
    const n42 = createElement('div', {
      id: 'n42'
    }, [
      createElement('span', {}, [
        createText('AN')
      ]),
      createElement('span', {}, [
        createText('CH')
      ]),
      createElement('span', {}, [
        createText('GED')
      ]),
    ]);
    BODY.append(n42);
    runMutationTest(n42,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n42.firstChild!.nextSibling],
        previousSibling: n42.firstChild, nextSibling: n42.lastChild},
        {type: "childList",
          addedNodes: [n42.firstChild!.nextSibling],
          previousSibling: n42.lastChild}],
      function() { n42.appendChild(n42.firstChild!.nextSibling!); },
      "childList Node.appendChild: removal and addition mutations");
  });

  it('n43', async () => {
    const n43 = createElement('div', {
      id: 'n43',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n43);

    var f43 = createFragment();

    runMutationTest(n43,
      {"childList":true},
      [{type: "childList",
        addedNodes: [f43.firstChild, f43.lastChild],
        previousSibling: n43.firstChild}],
      function() { n43.appendChild(f43); },
      "childList Node.appendChild: fragment addition mutations");
  });

  it('n44', async () => {
    const n44 = createElement('div', {
      id: 'n44',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n44);

    var f44 = createFragment();

    runMutationTest(f44,
      {"childList":true},
      [{type: "childList",
        removedNodes: [f44.firstChild, f44.lastChild]}],
      function() { n44.appendChild(f44); },
      "childList Node.appendChild: fragment removal mutations");

  });

  it('n45', async () => {
    var n45 = document.createElement('p');
    var d45 = document.createElement('span');
    runMutationTest(n45,
      {"childList":true},
      [{type: "childList",
        addedNodes: [d45]}],
      function() { n45.appendChild(d45); },
      "childList Node.appendChild: addition outside document tree mutation");
  });

  it('n50', async () => {
    const n50 = createElement('div', {
      id: 'n50',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n50);

    let d50;
    const dummies = createElement('div', {
      id: 'dummy'
    }, [
      d50 = createElement('span', {
        id: 'd35'
      }, [ createText('text content') ])
    ]);

    runMutationTest(n50,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n50.firstChild],
        addedNodes: [d50]}],
      function() { n50.replaceChild(d50, n50.firstChild!); },
      "childList Node.replaceChild: replacement mutation");
  });

  it('n51', async () => {
    const n51 = createElement('div', {
      id: 'n51',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n51);

    let d51;
    const dummies = createElement('div', {
      id: 'dummy'
    }, [
      d51 = createElement('span', {
        id: 'd35'
      }, [ createText('text content') ])
    ]);

    runMutationTest(n51,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n51.firstChild]}],
      function() { d51.parentNode.replaceChild(n51.firstChild, d51); },
      "childList Node.replaceChild: removal mutation");
  });

  it('n52', async () => {
    const n52 = createElement('div', {
      id: 'n52'
    }, [
      createElement('span', {}, [
        createText('NO ')
      ]),
      createElement('span', {}, [
        createText('CHANGED')
      ])
    ]);
    BODY.append(n52);
    runMutationTest(n52,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n52.lastChild],
        previousSibling: n52.firstChild},
        {type: "childList",
          removedNodes: [n52.firstChild],
          addedNodes: [n52.lastChild]}],
      function() { n52.replaceChild(n52.lastChild!, n52.firstChild!); },
      "childList Node.replaceChild: internal replacement mutation");
  });

  it('n53', async () => {
    const n53 = createElement('div', {
      id: 'n53',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n53);

    runMutationTest(n53,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n53.firstChild]},
        {type: "childList",
          addedNodes: [n53.firstChild]}],
      function() { n53.replaceChild(n53.firstChild!, n53.firstChild!); },
      "childList Node.replaceChild: self internal replacement mutation");
  });

  it('n60', async () => {
    const n60 = createElement('div', {
      id: 'n60',
    }, [
      createElement('span', {}, [
        createText('text content')
      ])
    ]);
    BODY.appendChild(n60);

    runMutationTest(n60,
      {"childList":true},
      [{type: "childList",
        removedNodes: [n60.firstChild]}],
      function() { n60.removeChild(n60.firstChild!); },
      "childList Node.removeChild: removal mutation");
  });
});