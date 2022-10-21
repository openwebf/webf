describe('Cookie', () => {
  it('works with cookie getter and setter', async () => {
    expect(document.cookie).toBe('');
    document.cookie = "name=oeschger";
    document.cookie = "favorite_food=tripe";
    expect(document.cookie).toBe('name=oeschger; favorite_food=tripe');
  });
});
