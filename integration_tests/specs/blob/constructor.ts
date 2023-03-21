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

    expect(base64).toEqual('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAWgAAAAiCAYAAAByUUNrAAAAAXNSR0IArs4c6QAAAARzQklUCAgICHwIZIgAAATbSURBVHic7dx/aFZVHMfx9xPSD9uzskyzNoqJQgUWgmAJWuSyZRAaJEG/oLZW/hNKP/6o/iiiEJSIiKIkKqEysPJHZYX2w1US9YfhMimtpik5aqTLTXO3P77fy84Oj9vu2EMn+bzgcLjfc+6553n++D535567EpAhIiLJGQPK0CIiqSkBJ/3XkxARkcqUoEVEEqUELSKSKCVoEZFEKUGLiCRKCVpEJFFK0CIiiVKCFhFJVOEEvQ14f5Qu/hvwDnAwiH0IfD1K41dbLzb/3cPo+wXwSXWnIyInmMIJ+llg0ShdfDOwAEvUuTuBZ0Zp/Grbj81/0zD6PgY8UN3piMgJRkscIiKJUoIWEUnUiBP0i8Bk7B96TAQeB/qC9mPASuBS71MLLAQ6RnCtz4CrfYwScAmwAjji7Ws8tis4Z7fHro3GWufxX/x4F3ArUO9jTwYWAweCczb4ORuA2d7vr0Hm+zxwOf3fzTIGfjciIsMxogR9EFgK3IStF08BHgXWB31eAe7CEt6rwJNAG3AF8E+Ba+0A5gB7gKd83Mv8+k94n4uBdiyR5z7w2EbghyD+HvYjUY895GsE3gXuAVZh6+vPYWvL+X/56/KxrgdqgKeBsceZ7ws+VtnHWQIsBz4q8JlFRHJZVqA0W97KPg1i+zz2SBBrgGxGdO4677fZj1f58Y6gTx1ktwTHrd6nIxqryeM9kPVBNgGyO6L2Ru+zIppX3u91b18djb3M423RPFuifj97/KUgNtWv0RvE2r1f/H2oqKioHK8A2YjuoMvYn/q5c73u9roXWzqYje3QaMfunvd4+74C19qO3SHXRfEmr/diSwk3YHfHAIewrYA3AzcCb3u8w+c1z493ej0nGnuu1z9F8cVDzPVvH/M64OQgfhEwfYhzRURiY6oxaL5+u9xLrgw0AGcXGGsvMKlC/Eyv9/uYjdi6+I/A9942D/uAtwGd2I8EwFVe5z8UtdHYZ0TtuVOGmGuX12dVaJsE/D7E+SIioaok6DxBtQIPYwmwBrvTLWoC8GeF+CGv82Sf39FvAbYCM4DzgGs8vtHbpmMP7gDOCcY6NRg7/0tgfMG51kRzC3VViImIDKYq2+zGYol1O3A+duc8WHI+Fh2HDxGnYEsknVGfrV7Xez0RmIa9NLIGW9rI4zOBtdhbivODMS70On5z8RuvLxhkzqF8/rXYZ43fGDxA/927iMhwVW0f9H3A59gWtrXYroqV2JuCuXzt+k0sCYMlxS3YGvJh4G6PL8ISbBv9uzlaGLibYj7wGraU0BTEFwKrsfXnuUF8AZZQW4C3gK+wnRwPAlMZuM5eyTiv19O/g6QZ+BbbybEJ2yESb/UTERmuQk8Wm7EdE5WeON4fHB+G7CGPh+XKoM8RyGZ5vNVjb0BW9tivHnvZrxmOcztkndEcPva2uij+XXBeT9T2JWTTorFnQbYt6JPv4thZ4XMv9bYGP+7GdonkY5UhWwLZvZDNTODJsIqKyv+jAFnJE3TV9GEP8o5ia76V9g93AafR/xDuKLaOOy7q9wfQgy2fjPbiebePP97nUvRcgNODWC/2uevR65oiUlzJS1UTtIiIFFdCN3ciIslSghYRSZQStIhIopSgRUQSpQQtIpIoJWgRkUQpQYuIJEoJWkQkUSVA76mIiCToX+zyAmIAp2CbAAAAAElFTkSuQmCC');
  });
});
