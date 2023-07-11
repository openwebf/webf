describe('Tags dir', () => {
  it('basic', async () => {
    var br = document.createElement('br');
    var text = document.createTextNode(br.dir);

    document.body.appendChild(br);
    document.body.appendChild(text);
    await snapshot();
  });
});
