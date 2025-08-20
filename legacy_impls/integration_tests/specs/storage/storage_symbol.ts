describe('Storage symbol', () => {
  ["localStorage", "sessionStorage"].forEach(function(name) {
    test(function() {
      var key = Symbol();

      var storage = window[name];
      storage.clear();

      storage[key] = "test";
      assert_equals(storage[key], "test");
    }, name + ": plain set + get (loose)");

    test(function() {
      "use strict";
      var key = Symbol();

      var storage = window[name];
      storage.clear();

      storage[key] = "test";
      assert_equals(storage[key], "test");
    }, name + ": plain set + get (strict)");

    test(function() {
      var key = Symbol();

      var storage = window[name];
      storage.clear();

      Object.defineProperty(storage, key, { "value": "test" });
      assert_equals(storage[key], "test");
    }, name + ": defineProperty + get");

    test(function() {
      var key = Symbol();

      var storage = window[name];
      storage.clear();

      Object.defineProperty(storage, key, { "value": "test", configurable: true, writable: true });
      assert_equals(storage[key], "test");

      assert_true(delete storage[key]);
      assert_equals(storage[key], undefined);
    }, name + ": defineProperty not configurable");

    test(function() {
      var key = Symbol();
      // @ts-ignore
      Storage.prototype[key] = "test";

      var storage = window[name];
      storage.clear();

      assert_equals(storage[key], "test");
      var desc = Object.getOwnPropertyDescriptor(storage, key);
      assert_equals(desc, undefined);

      // @ts-ignore
      delete Storage.prototype[key];
    }, name + ": get with symbol on prototype");

    test(function() {
      var key = Symbol();

      var storage = window[name];
      storage.clear();

      storage[key] = "test";
      assert_true(delete storage[key]);
      assert_equals(storage[key], undefined);
    }, name + ": delete existing property");

    test(function() {
      var key = Symbol();

      var storage = window[name];
      storage.clear();

      assert_true(delete storage[key]);
      assert_equals(storage[key], undefined);
    }, name + ": delete non-existent property");
  });
});