(() => {
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
          debugger;
          console.log(bbbb);
      }
  }

  var blub = new Blub();
  blub.jib()();
})();
