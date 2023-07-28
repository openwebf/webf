describe('Storage set.window', () => {
  ["localStorage", "sessionStorage"].forEach(function(name) {
    test(function() {
      var storage = window[name];
      storage.clear();

      assert_false("name" in storage);
      storage["name"] = "user1";
      assert_true("name" in storage);
    }, "The in operator in " + name + ": property access");

    test(function() {
      var storage = window[name];
      storage.clear();

      assert_false("name" in storage, '1');
      storage.setItem("name", "user1");
      assert_true("name" in storage, '2');
      assert_equals(storage.name, "user1");
      storage.removeItem("name");
      assert_false("name" in storage);
    }, "The in operator in " + name + ": method access");
  });

  ["localStorage", "sessionStorage"].forEach(function(name) {
    [9, "x"].forEach(function(key) {
      test(function () {
        var expected = "value for ";
        var value = expected;

        var storage = window[name];
        storage.clear();

        assert_equals(storage[key], undefined);
        assert_equals(storage.getItem(key), null);
        assert_equals(storage[key] = value, value);
        assert_equals(storage[key], expected);
        assert_equals(storage.getItem(key), expected);
      }, "Setting property for key " + key + " on " + name);

      test(function () {
        // @ts-ignore
        var expected = "value for ";
        var value = {
          toString: function () {
            return expected;
          }
        };

        var storage = window[name];
        storage.clear();

        assert_equals(storage[key], undefined);
        assert_equals(storage.getItem(key), null);
        assert_equals(storage[key] = value, value);
        assert_equals(storage[key], expected);
        assert_equals(storage.getItem(key), expected);
      }, "Setting property with toString for key " + key + " on " + name);
    });
  });
});