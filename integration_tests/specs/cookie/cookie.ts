import qs from 'qs';

describe('Cookie', () => {
  beforeEach(() => {
    // @ts-ignore
    document.___clear_cookies__();
  });

  it('works with cookie getter and setter', async () => {
    expect(document.cookie).toBe('');
    document.cookie = "name=oeschger";
    document.cookie = "favorite_food=tripe";
    expect(document.cookie).toBe('name=oeschger; favorite_food=tripe');
  });

  it('fetch api can read cookie from response', async () => {
    const queryString = qs.stringify({
      key: 'ID',
      value: '1234'
    });
    const setResponse = await fetch('/set_cookie?' + queryString);
    await setResponse.text();
    expect(document.cookie).toBe('ID=1234');
    const verityResponse = await fetch('/verify_cookie?id=ID&value=1234');
    expect(await verityResponse.text()).toBe('true');
  });

  it('fetch api and read cookie from document.cookie api', async () => {
    document.cookie = 'name=andycall; path=/';
    const verifyResponse = await fetch('/verify_cookie?id=name&value=andycall');
    expect(await verifyResponse.text()).toBe('true');
  });

  it('set expired cookie will have no effect', async () => {
    document.cookie = 'type=expired; Expires=Thu, 31 Oct 2021 07:28:00 GMT;'
    const verifyResponse = await fetch('/verify_cookie?id=type&value=expired');
    expect(await verifyResponse.text()).toBe('invalid');
  });

  it('set cookie with domain should works', async () => {
    document.cookie = 'name=andycall; domain=localhost; path=/';
    const verifyResponse = await fetch('/verify_cookie?id=name&value=andycall');
    expect(await verifyResponse.text()).toBe('true');
  });
});
