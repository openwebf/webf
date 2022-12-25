describe('history API', () => {
  it('location should update when pushState', () => {
    expect(location.pathname).toBe('/public/core.build.js');
    history.pushState({name: 1}, '', '/sample');
    expect(location.pathname).toBe('/sample');
    expect(history.state).toEqual({name: 1});
    history.back();
  });

  it('popState event will trigger when navigate back', (done) => {
    expect(location.pathname).toBe('/public/core.build.js');
    history.pushState({name: 2}, '', '/sample2');
    function onPopStateChange(e: PopStateEvent) {
      expect(e.state).toEqual(null);
      expect(location.pathname).toBe('/public/core.build.js');
      window.removeEventListener('popstate', onPopStateChange);
      done();
    }
    window.addEventListener('popstate', onPopStateChange);
    expect(history.state).toEqual({name: 2});
    requestAnimationFrame(() => {
      history.back();
    });
  });

  it('replaceState should work', (done) => {
    expect(location.pathname).toBe('/public/core.build.js');
    history.replaceState({name: 0}, '');
    history.pushState({name: 2}, '', '/sample2');
    function onPopStateChange(e: PopStateEvent) {
      expect(e.state).toEqual({name: 0});
      expect(location.pathname).toBe('/public/core.build.js');
      window.removeEventListener('popstate', onPopStateChange);
      done();
    }
    window.addEventListener('popstate', onPopStateChange);
    expect(history.state).toEqual({name: 2});
    requestAnimationFrame(() => {
      history.back();
    });
  });

  it('go back should work', (done) => {
    expect(location.pathname).toBe('/public/core.build.js');
    history.replaceState({name: 0}, '');
    history.pushState({name: 2}, '', '/sample2');
    function onPopStateChange(e: PopStateEvent) {
      expect(e.state).toEqual({name: 0});
      expect(location.pathname).toBe('/public/core.build.js');
      window.removeEventListener('popstate', onPopStateChange);
      done();
    }
    window.addEventListener('popstate', onPopStateChange);
    expect(history.state).toEqual({name: 2});
    requestAnimationFrame(() => {
      history.go(-1);
    });
  });
});
