describe('Storage string convertion', () => {
  ["localStorage", "sessionStorage"].forEach(function(name) {
    test(function() {
      assert_true(name in window, name + " exist");

      var storage = window[name];
      storage.clear();

      assert_equals(storage.length, 0);

      storage.a = null;
      assert_equals(storage.a, "null");
      storage.b = 0;
      assert_equals(storage.b, "0");

      storage.setItem('d', null);
      assert_equals(storage.d, "null");
      storage.setItem('e', 0);
      assert_equals(storage.e, "0");

      storage['g'] = null;
      assert_equals(storage.g, "null");
      storage['h'] = 0;
      assert_equals(storage.h, "0");

    }, name + " only stores strings");
  });
});