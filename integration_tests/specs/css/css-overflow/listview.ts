describe('listview', () => {
  it('vertical scrolling', async () => {
    const listview = createElement('webf-listview', {
      style: {
        width: '240px',
        height: '120px',
        border: '2px solid #999',
        boxSizing: 'border-box'
      }
    });

    // Add a series of fixed-size items so horizontal scrolling is required
    for (let i = 0; i < 10; i++) {
      const item = createElement('div', {
        style: {
          display: 'block',
          // width: '100px',
          height: '100px',
          margin: '8px',
          background: i % 2 == 0 ? '#4caf50' : '#2196f3',
          color: 'white',
          fontSize: '20px',
          lineHeight: '100px',
          boxSizing: 'border-box',
        }
      }, [createText(String(i + 1))]);
      listview.appendChild(item);
    }

    BODY.appendChild(listview);
    await snapshot();

    // Scroll horizontally by 150px; in RTL this should move content right-to-left visually.
    await listview.scroll(0, 150);
    await snapshot();

    await listview.scroll(0, 10000);
    await snapshot(0.2);
  });

  it('vertical scrolling in RTL', async () => {
    const listview = createElement('webf-listview', {
      style: {
        width: '240px',
        height: '120px',
        border: '2px solid #999',
        boxSizing: 'border-box',
        direction: 'rtl'
      }
    });

    // Add a series of fixed-size items so horizontal scrolling is required
    for (let i = 0; i < 10; i++) {
      const item = createElement('div', {
        style: {
          display: 'block',
          // width: '100px',
          height: '100px',
          margin: '8px',
          background: i % 2 == 0 ? '#4caf50' : '#2196f3',
          color: 'white',
          fontSize: '20px',
          lineHeight: '100px',
          boxSizing: 'border-box',
        }
      }, [createText(String(i + 1))]);
      listview.appendChild(item);
    }

    BODY.appendChild(listview);
    await snapshot();

    // Scroll horizontally by 150px; in RTL this should move content right-to-left visually.
    await listview.scroll(0, 150);
    await snapshot();

    await listview.scroll(0, 10000);
    await snapshot(0.2);
  });

  it('horizontal scrolling', async () => {
    const listview = createElement('webf-listview', {
      style: {
        width: '240px',
        height: '120px',
        border: '2px solid #999',
        boxSizing: 'border-box',
      },
      'scrollDirection': 'horizontal',
    });

    // Add a series of fixed-size items so horizontal scrolling is required
    for (let i = 0; i < 10; i++) {
      const item = createElement('div', {
        style: {
          display: 'inline-block',
          width: '100px',
          height: '100px',
          margin: '8px',
          background: i % 2 == 0 ? '#4caf50' : '#2196f3',
          color: 'white',
          fontSize: '20px',
          lineHeight: '100px',
          textAlign: 'center',
          boxSizing: 'border-box',
        }
      }, [createText(String(i + 1))]);
      listview.appendChild(item);
    }

    BODY.appendChild(listview);
    await snapshot();

    // Scroll horizontally by 150px; in RTL this should move content right-to-left visually.
    await listview.scroll(150, 0);
    await snapshot();

    await listview.scroll(100000, 0);
    await snapshot(1);
  });

  it('horizontal scrolling RTL', async () => {
    const listview = createElement('webf-listview', {
      style: {
        width: '240px',
        height: '120px',
        border: '2px solid #999',
        boxSizing: 'border-box',
        direction: 'rtl'
      },
      'scrollDirection': 'horizontal',
    });

    // Add a series of fixed-size items so horizontal scrolling is required
    for (let i = 0; i < 10; i++) {
      const item = createElement('div', {
        style: {
          display: 'inline-block',
          width: '100px',
          height: '100px',
          margin: '8px',
          background: i % 2 == 0 ? '#4caf50' : '#2196f3',
          color: 'white',
          fontSize: '20px',
          lineHeight: '100px',
          textAlign: 'center',
          boxSizing: 'border-box',
        }
      }, [createText(String(i + 1))]);
      listview.appendChild(item);
    }

    BODY.appendChild(listview);
    await snapshot();

    // Scroll horizontally by 150px; in RTL this should move content right-to-left visually.
    await listview.scroll(150, 0);
    await snapshot();

    await listview.scroll(100000, 0);
    await snapshot(1);
  });
});

