describe("Location API", function() {
  it('href', () => {
    expect(location.href).toBe('http://localhost:4567/public/core.build.js?search=1234#hash=hashValue');
  });
  it('protocol', () => {
    expect(location.protocol).toBe('http:');
  });
  it('host', () => {
    expect(location.host).toBe('localhost:4567');
  });
  it('hostname', () => {
    expect(location.hostname).toBe('localhost');
  });
  it('port', () => {
    expect(location.port).toBe('4567');
  });
  it('pathname', () => {
    expect(location.pathname).toBe('/public/core.build.js');
  });
  it('search', () => {
    expect(location.search).toBe('?search=1234');
  });
  it('hash', () => {
    expect(location.hash).toBe('#hash=hashValue');
  });
});