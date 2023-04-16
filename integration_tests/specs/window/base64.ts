describe('Base64', () => {

  /**
   * btoa() as defined by the HTML5 spec, which mostly just references RFC4648.
   */
  function mybtoa(s) {
    // String conversion as required by WebIDL.
    s = String(s);

    // "The btoa() method must throw an INVALID_CHARACTER_ERR exception if the
    // method's first argument contains any character whose code point is
    // greater than U+00FF."
    for (var i = 0; i < s.length; i++) {
      if (s.charCodeAt(i) > 255) {
        return "INVALID_CHARACTER_ERR";
      }
    }

    var out = "";
    for (var i = 0; i < s.length; i += 3) {
      let groupsOfSix: any[] = [undefined, undefined, undefined, undefined];
      groupsOfSix[0] = s.charCodeAt(i) >> 2;
      groupsOfSix[1] = (s.charCodeAt(i) & 0x03) << 4;
      if (s.length > i + 1) {
        groupsOfSix[1] |= s.charCodeAt(i + 1) >> 4;
        groupsOfSix[2] = (s.charCodeAt(i + 1) & 0x0f) << 2;
      }
      if (s.length > i + 2) {
        groupsOfSix[2] |= s.charCodeAt(i + 2) >> 6;
        groupsOfSix[3] = s.charCodeAt(i + 2) & 0x3f;
      }
      for (var j = 0; j < groupsOfSix.length; j++) {
        if (typeof groupsOfSix[j] == "undefined") {
          out += "=";
        } else {
          out += btoaLookup(groupsOfSix[j]);
        }
      }
    }
    return out;
  }

  /**
   * Lookup table for mybtoa(), which converts a six-bit number into the
   * corresponding ASCII character.
   */
  function btoaLookup(idx) {
    if (idx < 26) {
      return String.fromCharCode(idx + 'A'.charCodeAt(0));
    }
    if (idx < 52) {
      return String.fromCharCode(idx - 26 + 'a'.charCodeAt(0));
    }
    if (idx < 62) {
      return String.fromCharCode(idx - 52 + '0'.charCodeAt(0));
    }
    if (idx == 62) {
      return '+';
    }
    if (idx == 63) {
      return '/';
    }
    // Throw INVALID_CHARACTER_ERR exception here -- won't be hit in the tests.
    throw new Error('INVALID_CHARACTER_ERR');
  }

  function btoaException(input) {
    input = String(input);
    for (var i = 0; i < input.length; i++) {
      if (input.charCodeAt(i) > 255) {
        return true;
      }
    }
    return false;
  }

  function testBtoa(input) {
    // "The btoa() method must throw an INVALID_CHARACTER_ERR exception if the
    // method's first argument contains any character whose code point is
    // greater than U+00FF."
    var normalizedInput = String(input);
    for (var i = 0; i < normalizedInput.length; i++) {
      if (normalizedInput.charCodeAt(i) > 255) {
        expect(() => btoa(input)).toThrow();
      }
    }
    assert_equals(btoa(input), mybtoa(input));
    assert_equals(atob(btoa(input)), String(input), "atob(btoa(input)) must be the same as String(input)");
  }

  var tests = ["עברית", "", "ab", "abc", "abcd", "abcde",
    // This one is thrown in because IE9 seems to fail atob(btoa()) on it.  Or
    // possibly to fail btoa().  I actually can't tell what's happening here,
    // but it doesn't hurt.
    "\xff\xff\xc0",
    // Is your DOM implementation binary-safe?
    "\0a", "a\0b",
    // WebIDL tests.
    undefined, null, 7, 12, 1.5, true, false, NaN, +Infinity, -Infinity, 0, -0,
    {toString: function() { return "foo" }},
  ];
  for (var i = 0; i < 258; i++) {
    tests.push(String.fromCharCode(i));
  }
  tests.push(String.fromCharCode(10000));
  tests.push(String.fromCharCode(65534));
  tests.push(String.fromCharCode(65535));

// This is supposed to be U+10000.
  tests.push(String.fromCharCode(0xd800, 0xdc00));
  tests = tests.map(
    function(elem) {
      var expected = mybtoa(elem);
      if (expected === "INVALID_CHARACTER_ERR") {
        return ["btoa("  + format_value(elem) + ") must raise INVALID_CHARACTER_ERR", elem];
      }
      return ["btoa(" + format_value(elem) + ") == " + format_value(mybtoa(elem)), elem];
    }
  );

  var everything = "";
  for (var i = 0; i < 256; i++) {
    everything += String.fromCharCode(i);
  }
  tests.push(["btoa(first 256 code points concatenated)", everything]);

  const base64Json = [
    ["", []],
    ["abcd", [105, 183, 29]],
    [" abcd", [105, 183, 29]],
    ["abcd ", [105, 183, 29]],
    [" abcd===", null],
    ["abcd=== ", null],
    ["abcd ===", null],
    ["a", null],
    ["ab", [105]],
    ["abc", [105, 183]],
    ["abcde", null],
    ["𐀀", null],
    ["=", null],
    ["==", null],
    ["===", null],
    ["====", null],
    ["=====", null],
    ["a=", null],
    ["a==", null],
    ["a===", null],
    ["a====", null],
    ["a=====", null],
    ["ab=", null],
    ["ab==", [105]],
    ["ab===", null],
    ["ab====", null],
    ["ab=====", null],
    ["abc=", [105, 183]],
    ["abc==", null],
    ["abc===", null],
    ["abc====", null],
    ["abc=====", null],
    ["abcd=", null],
    ["abcd==", null],
    ["abcd===", null],
    ["abcd====", null],
    ["abcd=====", null],
    ["abcde=", null],
    ["abcde==", null],
    ["abcde===", null],
    ["abcde====", null],
    ["abcde=====", null],
    ["=a", null],
    ["=a=", null],
    ["a=b", null],
    ["a=b=", null],
    ["ab=c", null],
    ["ab=c=", null],
    ["abc=d", null],
    ["abc=d=", null],
    ["ab\u000Bcd", null],
    ["ab\u3000cd", null],
    ["ab\u3001cd", null],
    ["ab\tcd", [105, 183, 29]],
    ["ab\ncd", [105, 183, 29]],
    ["ab\fcd", [105, 183, 29]],
    ["ab\rcd", [105, 183, 29]],
    ["ab cd", [105, 183, 29]],
    ["ab\u00a0cd", null],
    ["ab\t\n\f\r cd", [105, 183, 29]],
    [" \t\n\f\r ab\t\n\f\r cd\t\n\f\r ", [105, 183, 29]],
    ["ab\t\n\f\r =\t\n\f\r =\t\n\f\r ", [105]],
    ["A", null],
    ["/A", [252]],
    ["//A", [255, 240]],
    ["///A", [255, 255, 192]],
    ["////A", null],
    ["/", null],
    ["A/", [3]],
    ["AA/", [0, 15]],
    ["AAAA/", null],
    ["AAA/", [0, 0, 63]],
    ["\u0000nonsense", null],
    ["abcd\u0000nonsense", null],
    ["YQ", [97]],
    ["YR", [97]],
    ["~~", null],
    ["..", null],
    ["--", null],
    ["__", null]
  ];

  const idlTests = [
    [undefined, null],
    [null, [158, 233, 101]],
    [7, null],
    [12, [215]],
    [1.5, null],
    [true, [182, 187]],
    [false, null],
    [NaN, [53, 163]],
    [+Infinity, [34, 119, 226, 158, 43, 114]],
    [-Infinity, null],
    [0, null],
    [-0, null],
    [{toString: function() { return "foo" }}, [126, 138]],
    [{toString: function() { return "abcd" }}, [105, 183, 29]]
  ];

  function runAtobTests(tests) {
    const allTests = tests.concat(idlTests);
    for(let i = 0; i < allTests.length; i++) {
      const input = allTests[i][0],
        output = allTests[i][1];
      test(() => {
        if(output === null) {
          expect(() => globalThis.atob(input)).toThrow();
        } else {
          const result = globalThis.atob(input);
          for(let ii = 0; ii < output.length; ii++) {
            assert_equals(result.charCodeAt(ii), output[ii]);
          }
        }
      }, "atob(" + format_value(input) + ")");
    }
  }

  runAtobTests(base64Json);
});