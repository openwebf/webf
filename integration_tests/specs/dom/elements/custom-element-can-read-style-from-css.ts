describe('custom-element-can-read-style-from-css', () => {
  it('applies stylesheet rules to custom elements', async () => {
    // Inject CSS similar to the original HTML
    const style = document.createElement('style');
    style.appendChild(
      document.createTextNode(`
      .c-footerbtns {
        width: 100%;
        height: 100px;
        border: 1px solid #000;
        background-color: #fff;
        display: flex;
        flex-direction: row;
        justify-content: center;
        align-items: center;
        padding-bottom: 9.067vw;
      }

      .c-footerbtns .footer-button {
        width: 120px;
      }

      .c-footerbtns .footer-button:first-child {
        margin-right: 20px;
        color: red;
      }
    `)
    );
    document.head.appendChild(style);

    // Build DOM
    const wrapper = document.createElement('div');
    wrapper.setAttribute('data-v-7ba5bd90', '');

    const page = document.createElement('div');
    page.className = 'p-detail';
    page.setAttribute('data-v-40f4caea', '');
    wrapper.appendChild(page);

    const footer = document.createElement('div');
    footer.className = 'c-footerbtns';
    page.appendChild(footer);

    const left = document.createElement('flutter-button');
    left.className = 'footer-button';
    left.setAttribute('type', 'primary');
    left.appendChild(document.createTextNode('Left'));

    const right = document.createElement('flutter-button');
    right.className = 'footer-button';
    right.appendChild(document.createTextNode('right'));

    footer.appendChild(left);
    footer.appendChild(right);

    document.body.appendChild(wrapper);

    await snapshot();
  });
});

