describe('overflow hidden - long text blocks', () => {
  it('renders two .q blocks within hidden overflow container', async () => {
    const style = document.createElement('style');
    style.textContent = `
      * {
        padding: 0;
        margin: 0;
      }
      .q {
        margin: 10px;
        padding: 10px;
        flex: 1 1 auto;
        background: gold;
      }
    `;
    document.head.appendChild(style);

    const wrapper = document.createElement('div');
    wrapper.style.overflow = 'hidden';

    const q1 = document.createElement('div');
    q1.className = 'q';
    q1.textContent = 'AAABBBCCCDDDEEEFFFGGGHHHIIIJJJKKKMMMNNNDDDQQQPPPLLLAAAKKKK';

    const q2 = document.createElement('div');
    q2.className = 'q';
    q2.textContent = 'AAABBBCC';

    wrapper.appendChild(q1);
    wrapper.appendChild(q2);
    document.body.appendChild(wrapper);

    await snapshot();
  });
});

