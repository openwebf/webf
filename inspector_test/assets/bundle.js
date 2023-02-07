(() => {

  let gg = 9;
  function foo(t) {
      var a = 55;
      var b = 33;
      var c = {
          d: true,
          e: 'hello',
          f: 34.55,
      };

      var arr2 = new Uint8Array(10000);
      var arr = [];
      for (var i = 0; i < 10000; i++) {
          arr.push(i);
          arr2[i] = i;
      }

      function noob() {
          console.log('f;asdsad`')
          console.log(a);
          console.log(t);
          console.log('supsups')
          console.log('ubgasdsad')
      }
      noob();
  }

  function bar() {
      foo(3);
      console.log('asdsad');
      console.log('about to throw!');
      try {
          throw new Error('whoops');
      }
      catch (e) {
          console.log('caught a whoops');
      }
  }


  function aaaaa() {
      foo(3);
      console.log('asdsad');
      console.log('about to throw!');
      try {
          throw new Error('whoops');
      }
      catch (e) {
          console.log('caught a whoops');
      }
  }


  class Blub {
      constructor() {
          this.peeps = 3;
          this.data = {
              arr: [1, "2", 0.3, 444, true, false, undefined, null, NaN, [[[[1]]]]],
              f: {
                  a: {
                      e: 10
                  }
              }
          };
      }
      jib() {
          let bbbb = NaN;
          // bar();
          // aaaaa();
          console.log(bbbb);
      }
  }

  var blub = new Blub();
  blub.jib()();
})();
