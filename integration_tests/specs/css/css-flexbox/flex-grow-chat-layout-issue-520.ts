// Repro for https://github.com/openwebf/webf/issues/520
// Flex-grow in a column flex container should fix the middle column size
// so it fills remaining space between header and footer and scrolls.

describe('flex-grow column chat layout (issue #520)', () => {
  it('list fills remaining height and scrolls; items keep intrinsic height', async () => {
    document.body.style.margin = '0';

    // Chat root
    const chat = document.createElement('div');
    chat.style.display = 'flex';
    chat.style.flexDirection = 'column';
    chat.style.height = '100vh';
    chat.style.width = '100%';

    // Header
    const header = document.createElement('div');
    header.className = 'header';
    header.style.display = 'flex';
    header.style.justifyContent = 'space-between';
    header.style.alignItems = 'center';
    header.style.backgroundColor = '#333';
    header.style.color = '#fff';
    header.style.padding = '10px 20px';

    const h1 = document.createElement('h1');
    h1.textContent = 'My Website';
    const link = document.createElement('a');
    link.href = '#';
    link.textContent = 'Logout';
    link.style.color = '#fff';
    header.appendChild(h1);
    header.appendChild(link);

    // List (flex item that should grow and scroll)
    const list = document.createElement('div');
    list.className = 'list';
    list.style.display = 'flex';
    list.style.flexDirection = 'column';
    list.style.justifyContent = 'center';
    list.style.alignItems = 'center';
    list.style.flexGrow = '1';
    list.style.overflow = 'scroll';
    list.style.backgroundColor = '#f1f1f1';
    list.style.padding = '20px';

    for (let i = 1; i <= 14; i++) {
      const item = document.createElement('div');
      item.className = 'list-item';
      item.textContent = `Item ${i}`;
      item.style.margin = '10px';
      item.style.padding = '10px';
      item.style.border = '1px solid #ccc';
      item.style.backgroundColor = '#fff';
      item.style.width = '100%';
      item.style.maxWidth = '500px';
      item.style.boxSizing = 'border-box';
      list.appendChild(item);
    }

    // Footer
    const footer = document.createElement('div');
    footer.className = 'footer';
    footer.style.display = 'flex';
    footer.style.justifyContent = 'center';
    footer.style.alignItems = 'center';
    footer.style.backgroundColor = '#333';
    footer.style.color = '#fff';
    footer.style.padding = '10px 20px';
    footer.style.gap = '8px';

    const input = document.createElement('input');
    input.className = 'input';
    input.placeholder = 'Enter your message...';
    input.style.display = 'flex';
    input.style.flexGrow = '1';
    input.style.padding = '10px';
    input.style.fontSize = '16px';
    input.style.border = 'none';
    input.style.borderRadius = '0';
    input.style.backgroundColor = '#f1f1f1';
    input.style.boxSizing = 'border-box';
    input.style.outline = 'none';

    const button = document.createElement('button');
    button.className = 'button';
    button.textContent = 'Send';
    button.style.backgroundColor = '#4CAF50';
    button.style.color = '#fff';
    button.style.padding = '10px';
    button.style.fontSize = '16px';
    button.style.border = 'none';
    button.style.borderRadius = '0';

    footer.appendChild(input);
    footer.appendChild(button);

    chat.appendChild(header);
    chat.appendChild(list);
    chat.appendChild(footer);
    document.body.appendChild(chat);

    await snapshot();

    // Programmatic assertions to ensure expected layout behavior
    const chatH = chat.offsetHeight;
    const headerH = header.offsetHeight;
    const listH = list.offsetHeight;
    const footerH = footer.offsetHeight;

    // Flex-grow should make list fill remaining vertical space exactly
    expect(Math.round(headerH + listH + footerH)).toBe(Math.round(chatH));

    // The list should be scrollable with many items
    expect(list.scrollHeight).toBeGreaterThan(list.clientHeight);

    const firstItem = list.querySelector('.list-item') as HTMLElement;
    const secondItem = list.querySelectorAll('.list-item')[1] as HTMLElement;
    expect(firstItem.offsetHeight).toBe(secondItem.offsetHeight);
    // Items should not be stretched to container height
    expect(firstItem.offsetHeight).toBeLessThan(listH);
  });
});

