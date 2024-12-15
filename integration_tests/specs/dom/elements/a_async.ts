describe('anchor element async', async () => {
  it('should work with set href attribute', async () => {
    let a = document.createElement('a');
    // @ts-ignore
    a.href_async = 'https://v3.vuejs.org/guide/introduction.html';
    // @ts-ignore
    let value = await a.href_async
    expect(value).toBe('https://v3.vuejs.org/guide/introduction.html');
  });

  it('should work with pathname property', async () => {
    let a = document.createElement('a');
    // @ts-ignore
    a.href_async = 'https://v3.vuejs.org/guide/introduction.html';

    // @ts-ignore
    let value = await a.pathname_async
    expect(value).toBe('/guide/introduction.html');

    // @ts-ignore
    a.pathname_sync = '/guide/introduction.html#what-is-vue-js';
    // @ts-ignore
    value = await a.href_async
    expect(value).toBe('https://v3.vuejs.org/guide/introduction.html%23what-is-vue-js');
  });

  it('should work with host property', async () => {
    let a = document.createElement('a');
    // @ts-ignore
    a.href_async = 'https://v3.vuejs.org:8093/guide/introduction.html';

    // @ts-ignore
    let host = await a.host_async
    // @ts-ignore
    let hostname = await a.hostname_async
    // @ts-ignore
    let port = await a.port_async

    expect(host).toBe('v3.vuejs.org:8093');
    expect(hostname).toBe('v3.vuejs.org');
    expect(port).toBe('8093');
    // @ts-ignore
    a.host_async = 'react.dev:8088';
    // @ts-ignore
    let href = await a.href_async
    expect(href).toBe('https://react.dev:8088/guide/introduction.html');
    // @ts-ignore
    a.hostname_async = 'v3.vuejs.org';
    // @ts-ignore
    href = await a.href_async
    expect(href).toBe('https://v3.vuejs.org:8088/guide/introduction.html');
  });

  it('should work with protocol property', async () => {
    let a = document.createElement('a');
    // @ts-ignore
    a.href_async = 'https://v3.vuejs.org/guide/introduction.html';

    // @ts-ignore
    let protocol = await a.protocol_async
    expect(protocol).toBe('https:');
    
    // @ts-ignore
    a.protocol_async = 'http:';
    // @ts-ignore
    let href = await a.href_async
    expect(href).toBe('http://v3.vuejs.org/guide/introduction.html');
  });
});
