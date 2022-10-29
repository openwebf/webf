import qs from 'qs';

describe('Cookie', () => {
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
});
