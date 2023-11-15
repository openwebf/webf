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

function runMutationTest(node, mutationObserverOptions, mutationRecordSequence, mutationFunction, description, target) {
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
            attributeName: null,
            oldValue: null,
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
            attributeName: null,
            oldValue: null,
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
      {type: "attributes", attributeName: "class", oldValue: ''},
      {type: "childList", addedNodes: [n00.firstChild], attributeName: null, oldValue: null},
      {type: "characterData", oldValue: "old data", target: n00.firstChild, attributeName: null}
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