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

    expect(base64).toEqual('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAWgAAAAiCAYAAAByUUNrAAAAAXNSR0IArs4c6QAAAARzQklUCAgICHwIZIgAAAS7SURBVHic7d1/aFZVHMfx9xPSD9tWlmnWRjFRqMBCECxBi1y2DEKDJOgX1NbKf0Lpxx/VH0UUghIRUZREJVQGVv7IrNB+uEqi/jBcJqXVNCVHjXS5ae72R58Lh8Pj9tzxPHaSzwsOh/s955577vPHd3fnnmcrARlmZpacUThDm5klpwSc9F9PwszMynOCNjNLlBO0mVminKDNzBLlBG1mlignaDOzRDlBm5klygnazCxRhRP0VmB9lS7+K/AOcCCIfQB8VaXxa21A899VQd/PgY+Pw5zM7MRROEE/Cyyo0sU3AfOUqHN3As9Uafxa26f5b6yg72PAA8dhTmZ24vASh5lZopygzcwSNeIE/SIwUX/QYzzwODAYtB8FlgOXqk8DMB/oHsG1PgWu1hgl4BJgGXBY7asU2xmcs0uxa6Ox1ij+s453ArcCTRp7IrAQ2B+cs07nrANmqt+fQ8z3eeDy4LNZEn02ZmaVGFGCPgAsBm7SevEk4FFgbdDnFeAuJbxXgSeBTuAK4O8C19oOzAJ2A09p3Mt0/SfU52KgS4k8975iG4Dvg/h7+iHRpJd8LcC7wD3ACq2vP6e15fyv/PVqrOuBOuBpYPQx5vuCxqrXOIuApcCHBe7ZzCyXZQVK2795K/skiO1V7JEg1gzZtOjcNeq3SccrdLw96NMI2S3BcYf6dEdjtSreD9kgZOMguyNqb1GfZdG88n6vq31lNPYSxTujebZH/X5S/KUgNlnXGAhiXeoXfx4uLi4uxypANqIn6Hr9qp87V3Wf6gEtHczUDo0uPT3vVvveAtfapifkxijeqnqPlhJu0NMxwEFtBbwZuBF4W/FuzWuOjneonhWNPVv1j1F84TBz/UtjXgecHMQvAqZWcK9mZqFRtRg0X79dqpKrB5qBswuMtQeYUCZ+pup9GrNF6+I/AN+pbY5u8DagRz8kAK5Snf+gaIjGPiNqz50yzFx7VZ9Vpm0C8Nsw55uZhWqSoPME1QE8rARYpyfdosYBf5SJH1SdJ/v8iX4zsAWYBpwHXKP4BrVN1Ys7gHOCsU4Nxs5/ExhbcK510dxCvWViZmZDqck2u9FKrNuA8/XkPFRyPhodhy8RJ2mJpCfqs0V1k+rxwBR9aWSVljby+HRgtb6lODcY40LV8TcXv1Z9QQX3Gs6/Qfcaf2Nwf/D0bmZWqZrtg74P+Exb2FZrV8VyfVMwl69dv6kkjJLiZq0hHwLuVnyBEmxnsJujPdpNMRd4TUsJrUF8PrBS68+zg/g8JdR24C3gS+3keBCYHK2zlzNG9dpgB0kb8I12cmzUDpF4q5+ZWaUKvVls046Jcm8c7w+OD0H2kOJhuTLocxiyGYp3KPYGZPWK/aLYy7pmOM7tkPVEc/hIbY1R/NvgvP6o7QvIpkRjz4Bsa9An38Wxo8x9L1Zbs477tEskH6seskWQ3QvZ9ATeDLu4uPw/CpCVlKBrZlAv8o5ozbfc/uFe4LTgJdwRreOOifr9DvRr+aTai+d9Gn+s5lL0XIDTg9iA7rvJX9c0sxEoqdQ0QZuZWXElP9yZmaXLCdrMLFFO0GZmiXKCNjNLlBO0mVminKDNzBLlBG1mlignaDOzRJWCfxxiZmYJ+Qfs8gJi9ynfLgAAAABJRU5ErkJggg==');
  });
});
