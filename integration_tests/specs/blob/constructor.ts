describe('Blob construct', () => {
  it('with string', async () => {
    let blob = new Blob(['1234']);
    expect(blob.size).toBe(4);
    let text = await blob.text();
    expect(text).toBe('1234');
  });

  it('with another blob', async () => {
    let blob = new Blob(['1234']);
    let another = new Blob([blob]);
    expect(another.size).toBe(4);
    expect(await another.text()).toBe('1234');
  });

  it('with arrayBuffer', async () => {
    let arrayBuffer = await new Blob(['1234']).arrayBuffer();
    let blob = new Blob([arrayBuffer]);
    expect(blob.size).toBe(4);
    expect(await blob.text()).toBe('1234');
  });

  it('with arrayBufferView', async () => {
    let buffer = new Int8Array([97, 98, 99, 100, 101]);
    let blob = new Blob([buffer]);
    expect(await blob.text()).toBe('abcde');
    expect(blob.size).toBe(5);
  });

  it('with int16Array', async () => {
    let buffer = new Int16Array([100, 101, 102, 103, 104]);
    let blob = new Blob([buffer]);
    let arrayBuffer = await blob.arrayBuffer();
    let u8Array = new Uint8Array(arrayBuffer);
    expect(Array.from(u8Array)).toEqual([100, 0, 101, 0, 102, 0, 103, 0, 104, 0]);
  });
});

describe('Blob API', () => {
  it('base64()', async () => {
    let div = document.createElement('div');
    div.textContent = 'helloworld';
    div.style.padding = '5px 10px';
    div.style.backgroundColor = 'red';
    div.style.border = '1px solid #000';
    document.body.appendChild(div);

    const blob = await div.toBlob(1);
    // @ts-ignore
    const base64 = await blob.base64();

    expect(base64).toEqual('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAWgAAAAfCAYAAADKtVcYAAAAAXNSR0IArs4c6QAAAARzQklUCAgICHwIZIgAAASpSURBVHic7d1vaFdVHMfx9y+kP7atLNOsjWKiUIGFIFiCFrlsGYQGSdA/qK2VT0Lpz4PqQRGFoEREFCVRCZWBlX8yK7Q/rpKoB4bLpLSapuSokS43zZ0e9LlwOPzcfnf8fnaTzwsOh/s955577h58d3fuuVoCAmZmVjijcIY2MyucEnDSfz0JMzMrzwnazKygnKDNzArKCdrMrKCcoM3MCsoJ2sysoHIn6K3A+ipd/FfgHeBAFPsA+KpK49fagOa/q4K+nwMfH4c5mdmJI3eCfhZYUKWLbwLmKVFn7gSeqdL4tbZP899YQd/HgAeOw5zM7MThJQ4zs4JygjYzK6gRJ+gXgYn6HHE88DgwGLUfBZYDl6pPAzAf6B7BtT4FrtYYJeASYBlwWO2rFNsZnbNLsWuTsdYo/rOOdwK3Ak0aeyKwENgfnbNO56wDZqrfn0PM93ng8uhnsyT52ZiZVWJECfoAsBi4SevFk4BHgbVRn1eAu5TwXgWeBDqBK4C/c1xrOzAL2A08pXEv0/WfUJ+LgS4l8sz7im0Avo/i7+mXRJNe8rUA7wL3ACu0vv6c1pazf6OkV2NdD9QBTwOjjzHfFzRWvcZZBCwFPsxxz2ZmmRBylLZ/81b4JIrtVeyRKNYMYVpy7hr126TjFTreHvVphHBLdNyhPt3JWK2K90MYhDAOwh1Je4v6LEvmlfV7Xe0rk7GXKN6ZzLM96feT4i9Fscm6xkAU61K/9Ofh4uLicqwChBE9QdfrT/3Muar7VA9o6WCmdmh06el5t9r35rjWNj0hNybxVtV7tJRwg56OAQ5qK+DNwI3A24p3a15zdLxD9axk7Nmqf0ziC4eZ618a8zrg5Ch+ETC1gns1M4uNqsWg2frtUpVMPdAMnJ1jrD3AhDLxM1Xv05gtWhf/AfhObXN0g7cBPfolAXCV6uwXRUMy9hlJe+aUYebaq/qsMm0TgN+GOd/MLFaTBJ0lqA7gYSXAOj3p5jUO+KNM/KDqLNlnT/SbgS3ANOA84BrFN6htql7cAZwTjXVqNHb2l8DYnHOtS+YW6y0TMzMbSk222Y1WYt0GnK8n56GS89HkOH6JOElLJD1Jny2qm1SPB6boo5FVWtrI4tOB1fpKcW40xoWq0y8Xv1Z9QQX3Gs+/QfeafjG4P3p6NzOrVM32Qd8HfKYtbKu1q2K5vhTMZGvXbyoJo6S4WWvIh4C7FV+gBNsZ7eZoT3ZTzAVe01JCaxSfD6zU+vPsKD5PCbUdeAv4Ujs5HgQmJ+vs5YxRvTbaQdIGfKOdHBu1QyTd6mdmVqlcbxbbtGOi3BvH+6PjQxAeUjwuV0Z9DkOYoXiHYm9AqFfsF8Ve1jXjcW6H0JPM4SO1NSbxb6Pz+pO2LyBMScaeAWFr1CfbxbGjzH0vVluzjvu0SyQbqx7CIgj3QphegDfDLi4u/48ChJISdM0M6kXeEa35lts/3AucFr2EO6J13DFJv9+Bfi2fVHvxvE/jj9Vc8p4LcHoUG9B9N/lzTTMbgZJKTRO0mZnl5/801syswJygzcwKygnazKygnKDNzArKCdrMrKCcoM3MCsoJ2sysoErRv0tvZmYF8g+sGwJc9BrF0gAAAABJRU5ErkJggg==');
  });
});
