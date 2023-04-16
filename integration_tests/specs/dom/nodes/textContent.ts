// test from https://github.com/web-platform-tests/wpt/blob/master/dom/nodes/Node-textContent.html

describe('Node.textContent', () => {
    // Getting
    // DocumentFragment, Element:
    test(function () {
        var element = document.createElement("div")
        assert_equals(element.textContent, "")
    }, "For an empty Element, textContent should be the empty string")

    test(function () {
        assert_equals(document.createDocumentFragment().textContent, "")
    }, "For an empty DocumentFragment, textContent should be the empty string")

    test(function () {
        var el = document.createElement("div")
        el.appendChild(document.createComment(" abc "))
        el.appendChild(document.createTextNode("\tDEF\t"))
        // el.appendChild(document.createProcessingInstruction("x", " ghi "))
        assert_equals(el.textContent, "\tDEF\t")
    }, "Element with children")

    test(function () {
        var el = document.createElement("div")
        var child = document.createElement("div")
        el.appendChild(child)
        child.appendChild(document.createComment(" abc "))
        child.appendChild(document.createTextNode("\tDEF\t"))
        // child.appendChild(document.createProcessingInstruction("x", " ghi "))
        assert_equals(el.textContent, "\tDEF\t")
    }, "Element with descendants")

    test(function () {
        var df = document.createDocumentFragment()
        df.appendChild(document.createComment(" abc "))
        df.appendChild(document.createTextNode("\tDEF\t"))
        // df.appendChild(document.createProcessingInstruction("x", " ghi "))
        assert_equals(df.textContent, "\tDEF\t")
    }, "DocumentFragment with children")

    test(function () {
        var df = document.createDocumentFragment()
        var child = document.createElement("div")
        df.appendChild(child)
        child.appendChild(document.createComment(" abc "))
        child.appendChild(document.createTextNode("\tDEF\t"))
        // child.appendChild(document.createProcessingInstruction("x", " ghi "))
        assert_equals(df.textContent, "\tDEF\t")
    }, "DocumentFragment with descendants")

    // Text, ProcessingInstruction, Comment:
    test(function () {
        assert_equals(document.createTextNode("").textContent, "")
    }, "For an empty Text, textContent should be the empty string")

    xtest(function () {
        assert_equals(document.createProcessingInstruction("x", "").textContent, "")
    }, "For an empty ProcessingInstruction, textContent should be the empty string")

    test(function () {
        assert_equals(document.createComment("").textContent, "")
    }, "For an empty Comment, textContent should be the empty string")

    test(function () {
        assert_equals(document.createTextNode("abc").textContent, "abc")
    }, "For a Text with data, textContent should be that data")

    xtest(function () {
        assert_equals(document.createProcessingInstruction("x", "abc").textContent,
            "abc")
    }, "For a ProcessingInstruction with data, textContent should be that data")

    test(function () {
        assert_equals(document.createComment("abc").textContent, "abc")
    }, "For a Comment with data, textContent should be that data")

    // Setting
    // DocumentFragment, Element:
    var testArgs = [
        [null, null],
        [undefined, null],
        ["", null],
        [42, "42"],
        ["abc", "abc"],
        ["<b>xyz<\/b>", "<b>xyz<\/b>"],
        ["d\0e", "d\0e"]
        // XXX unpaired surrogate?
    ]
    testArgs.forEach(function (aValue) {
        var argument = aValue[0] as string, expectation = aValue[1]
        var check = function (aElementOrDocumentFragment) {
        if (expectation === null) {
                assert_equals(aElementOrDocumentFragment.textContent, "")
                assert_equals(aElementOrDocumentFragment.firstChild, null)
            } else {
                assert_equals(aElementOrDocumentFragment.textContent, expectation)
                assert_equals(aElementOrDocumentFragment.childNodes.length, 1,
                    "Should have one child")
                var firstChild = aElementOrDocumentFragment.firstChild
                assert_true(firstChild instanceof Text, "child should be a Text")
                assert_equals(firstChild.data, expectation)
            }
        }

        test(function () {
            var el = document.createElement("div")
            el.textContent = argument
            check(el)
        }, "Element without children set to " + format_value(argument))

        test(function () {
            var el = document.createElement("div")
            var text = el.appendChild(document.createTextNode(""))
            el.textContent = argument
            check(el)
            assert_equals(text.parentNode, null,
                "Preexisting Text should have been removed")
        }, "Element with empty text node as child set to " + format_value(argument))

        test(function () {
            var el = document.createElement("div")
            el.appendChild(document.createComment(" abc "))
            el.appendChild(document.createTextNode("\tDEF\t"))
            // el.appendChild(document.createProcessingInstruction("x", " ghi "))
            el.textContent = argument
            check(el)
        }, "Element with children set to " + format_value(argument))

        test(function () {
            var el = document.createElement("div")
            var child = document.createElement("div")
            el.appendChild(child)
            child.appendChild(document.createComment(" abc "))
            child.appendChild(document.createTextNode("\tDEF\t"))
            // child.appendChild(document.createProcessingInstruction("x", " ghi "))
            el.textContent = argument
            check(el)
            assert_equals(child.childNodes.length, 2,
                "Should not have changed the internal structure of the removed nodes.")
        }, "Element with descendants set to " + format_value(argument))

        test(function () {
            var df = document.createDocumentFragment()
            df.textContent = argument
            check(df)
        }, "DocumentFragment without children set to " + format_value(argument))

        test(function () {
            var df = document.createDocumentFragment()
            var text = df.appendChild(document.createTextNode(""))
            df.textContent = argument
            check(df)
            assert_equals(text.parentNode, null,
                "Preexisting Text should have been removed")
        }, "DocumentFragment with empty text node as child set to " + format_value(argument))

        test(function () {
            var df = document.createDocumentFragment()
            df.appendChild(document.createComment(" abc "))
            df.appendChild(document.createTextNode("\tDEF\t"))
            // df.appendChild(document.createProcessingInstruction("x", " ghi "))
            df.textContent = argument
            check(df)
        }, "DocumentFragment with children set to " + format_value(argument))

        test(function () {
            var df = document.createDocumentFragment()
            var child = document.createElement("div")
            df.appendChild(child)
            child.appendChild(document.createComment(" abc "))
            child.appendChild(document.createTextNode("\tDEF\t"))
            // child.appendChild(document.createProcessingInstruction("x", " ghi "))
            df.textContent = argument
            check(df)
            assert_equals(child.childNodes.length, 2,
                "Should not have changed the internal structure of the removed nodes.")
        }, "DocumentFragment with descendants set to " + format_value(argument))
    })

    // Text, ProcessingInstruction, Comment:
    test(function () {
        var text = document.createTextNode("abc")
        text.textContent = "def"
        assert_equals(text.textContent, "def")
        assert_equals(text.data, "def")
    }, "For a Text, textContent should set the data")

    xtest(function () {
        var pi = document.createProcessingInstruction("x", "abc")
        pi.textContent = "def"
        assert_equals(pi.textContent, "def")
        assert_equals(pi.data, "def")
        assert_equals(pi.target, "x")
    }, "For a ProcessingInstruction, textContent should set the data")

    test(function () {
        var comment = document.createComment("abc")
        comment.textContent = "def"
        assert_equals(comment.textContent, "def")
        assert_equals(comment.data, "def")
    }, "For a Comment, textContent should set the data")
})
