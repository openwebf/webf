describe('background-attachment: fixed with linear-gradient', () => {
  it('fixed gradient stays pinned while content scrolls', async () => {
    // Scroll container
    const scroller = createElement('div', {
      style: {
        width: '360px',
        height: '160px',
        overflow: 'auto',
        border: '1px solid #999',
        position: 'relative'
      }
    });

    // Tall inner content with a tiled gradient background
    const content = createElement('div', {
      style: {
        width: '100%',
        height: '640px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#111',
        fontSize: '12px',
        backgroundImage:
          'linear-gradient(45deg, rgba(59,130,246,0.15) 25%, transparent 25%, transparent 50%, rgba(59,130,246,0.15) 50%, rgba(59,130,246,0.15) 75%, transparent 75%, transparent)',
        backgroundSize: '32px 32px',
        backgroundRepeat: 'repeat',
        backgroundAttachment: 'fixed'
      }
    });
    content.appendChild(document.createTextNode('Scroll me'));

    scroller.appendChild(content);
    append(BODY, scroller);

    // Initial snapshot
    await snapshot(scroller);

    // Scroll inner content; gradient should remain visually pinned
    scroller.scrollTop = 120;
    await waitForFrame();
    await snapshot(scroller);
  });
});

