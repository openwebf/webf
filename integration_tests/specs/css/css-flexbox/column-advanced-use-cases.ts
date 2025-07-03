describe('flexbox column advanced use cases', () => {
  it('should handle sticky positioning in flex column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      height: '300px',
      overflow: 'auto',
      backgroundColor: '#f0f0f0',
      border: '2px solid #333',
    });
    document.body.appendChild(container);

    // Sticky header
    const header = document.createElement('div');
    setElementStyle(header, {
      position: 'sticky',
      top: '0',
      backgroundColor: '#2c3e50',
      color: 'white',
      padding: '15px',
      zIndex: '10',
      boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
    });
    header.textContent = 'Sticky Header';
    container.appendChild(header);

    // Scrollable content
    for (let i = 0; i < 20; i++) {
      const item = document.createElement('div');
      setElementStyle(item, {
        backgroundColor: i % 2 === 0 ? 'white' : '#ecf0f1',
        padding: '20px',
        borderBottom: '1px solid #ddd',
      });
      item.textContent = `Item ${i + 1}`;
      container.appendChild(item);
    }

    // Sticky footer
    const footer = document.createElement('div');
    setElementStyle(footer, {
      position: 'sticky',
      bottom: '0',
      backgroundColor: '#34495e',
      color: 'white',
      padding: '15px',
      marginTop: 'auto',
    });
    footer.textContent = 'Sticky Footer';
    container.appendChild(footer);

    await snapshot();
  });

  it('should handle grid inside flex column items', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '20px',
      padding: '20px',
      backgroundColor: '#f5f5f5',
    });
    document.body.appendChild(container);

    // Header with flex
    const header = document.createElement('div');
    setElementStyle(header, {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      backgroundColor: 'white',
      padding: '15px',
      borderRadius: '8px',
      boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
    });
    const title = document.createElement('h2');
    title.textContent = 'Dashboard';
    setElementStyle(title, { margin: '0' });
    header.appendChild(title);
    const button = document.createElement('button');
    button.textContent = 'Action';
    setElementStyle(button, {
      padding: '8px 16px',
      backgroundColor: '#3498db',
      color: 'white',
      border: 'none',
      borderRadius: '4px',
    });
    header.appendChild(button);
    container.appendChild(header);

    // Grid content area
    const gridContainer = document.createElement('div');
    setElementStyle(gridContainer, {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
      gap: '15px',
      backgroundColor: 'white',
      padding: '20px',
      borderRadius: '8px',
    });
    container.appendChild(gridContainer);

    // Grid items
    ['Stats', 'Charts', 'Reports', 'Settings'].forEach((label, i) => {
      const gridItem = document.createElement('div');
      setElementStyle(gridItem, {
        backgroundColor: ['#3498db', '#e74c3c', '#2ecc71', '#f39c12'][i],
        color: 'white',
        padding: '30px',
        textAlign: 'center',
        borderRadius: '4px',
      });
      gridItem.textContent = label;
      gridContainer.appendChild(gridItem);
    });

    await snapshot();
  });

  it('should handle flex column with absolute positioned children', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      position: 'relative',
      height: '400px',
      backgroundColor: '#ecf0f1',
      padding: '20px',
    });
    document.body.appendChild(container);

    // Regular flex items
    const item1 = document.createElement('div');
    setElementStyle(item1, {
      backgroundColor: '#3498db',
      color: 'white',
      padding: '20px',
      marginBottom: '10px',
    });
    item1.textContent = 'Normal flex item 1';
    container.appendChild(item1);

    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#2ecc71',
      color: 'white',
      padding: '20px',
      marginBottom: '10px',
    });
    item2.textContent = 'Normal flex item 2';
    container.appendChild(item2);

    // Absolute positioned overlay
    const overlay = document.createElement('div');
    setElementStyle(overlay, {
      position: 'absolute',
      top: '50px',
      right: '20px',
      backgroundColor: 'rgba(231, 76, 60, 0.9)',
      color: 'white',
      padding: '15px',
      borderRadius: '8px',
      boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
    });
    overlay.textContent = 'Absolute overlay';
    container.appendChild(overlay);

    // Absolute positioned badge
    const badge = document.createElement('div');
    setElementStyle(badge, {
      position: 'absolute',
      top: '10px',
      right: '10px',
      backgroundColor: '#f39c12',
      color: 'white',
      padding: '5px 10px',
      borderRadius: '20px',
      fontSize: '12px',
    });
    badge.textContent = 'New';
    container.appendChild(badge);

    await snapshot();
  });

  it('should handle flex column with transform animations', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '15px',
      padding: '20px',
      backgroundColor: '#f8f9fa',
    });
    document.body.appendChild(container);

    // Items with different transforms
    const transforms = [
      { transform: 'translateX(20px)', backgroundColor: '#3498db' },
      { transform: 'scale(0.9)', backgroundColor: '#e74c3c' },
      { transform: 'rotate(5deg)', backgroundColor: '#2ecc71' },
      { transform: 'skewX(-5deg)', backgroundColor: '#9b59b6' },
    ];

    transforms.forEach((style, i) => {
      const item = document.createElement('div');
      setElementStyle(item, {
        ...style,
        color: 'white',
        padding: '20px',
        borderRadius: '4px',
        transition: 'transform 0.3s ease',
      });
      item.textContent = `Transformed item ${i + 1}`;
      container.appendChild(item);
    });

    await snapshot();
  });

  it('should handle flex column with pseudo-elements', async () => {
    // Add style tag for pseudo-elements
    const style = document.createElement('style');
    style.textContent = `
      .icon-item::before {
        content: '▶';
        margin-right: 10px;
        color: #3498db;
      }
      .quote-item::before {
        content: '"';
        font-size: 24px;
        color: #e74c3c;
      }
      .quote-item::after {
        content: '"';
        font-size: 24px;
        color: #e74c3c;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '15px',
      padding: '20px',
      backgroundColor: '#f0f0f0',
    });
    document.body.appendChild(container);

    // Item with icon pseudo-element
    const iconItem = document.createElement('div');
    iconItem.className = 'icon-item';
    setElementStyle(iconItem, {
      backgroundColor: 'white',
      padding: '15px',
      borderRadius: '4px',
    });
    iconItem.textContent = 'Item with icon';
    container.appendChild(iconItem);

    // Item with quote pseudo-elements
    const quoteItem = document.createElement('div');
    quoteItem.className = 'quote-item';
    setElementStyle(quoteItem, {
      backgroundColor: 'white',
      padding: '15px',
      borderRadius: '4px',
      fontStyle: 'italic',
    });
    quoteItem.textContent = 'This is a quoted text';
    container.appendChild(quoteItem);

    await snapshot();
  });

  it('should handle flex column with form elements', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '15px',
      padding: '20px',
      backgroundColor: 'white',
      maxWidth: '400px',
      border: '1px solid #ddd',
      borderRadius: '8px',
    });
    document.body.appendChild(container);

    // Form title
    const title = document.createElement('h3');
    title.textContent = 'User Form';
    setElementStyle(title, {
      margin: '0 0 10px 0',
      color: '#2c3e50',
    });
    container.appendChild(title);

    // Text input group
    const inputGroup1 = document.createElement('div');
    setElementStyle(inputGroup1, {
      display: 'flex',
      flexDirection: 'column',
      gap: '5px',
    });
    const label1 = document.createElement('label');
    label1.textContent = 'Name';
    setElementStyle(label1, {
      fontSize: '14px',
      color: '#555',
    });
    inputGroup1.appendChild(label1);
    const input1 = document.createElement('input');
    input1.type = 'text';
    input1.placeholder = 'Enter your name';
    setElementStyle(input1, {
      padding: '10px',
      border: '1px solid #ddd',
      borderRadius: '4px',
    });
    inputGroup1.appendChild(input1);
    container.appendChild(inputGroup1);

    // Select group
    const selectGroup = document.createElement('div');
    setElementStyle(selectGroup, {
      display: 'flex',
      flexDirection: 'column',
      gap: '5px',
    });
    const label2 = document.createElement('label');
    label2.textContent = 'Country';
    setElementStyle(label2, {
      fontSize: '14px',
      color: '#555',
    });
    selectGroup.appendChild(label2);
    const select = document.createElement('select');
    setElementStyle(select, {
      padding: '10px',
      border: '1px solid #ddd',
      borderRadius: '4px',
    });
    ['USA', 'UK', 'Canada'].forEach(country => {
      const option = document.createElement('option');
      option.textContent = country;
      select.appendChild(option);
    });
    selectGroup.appendChild(select);
    container.appendChild(selectGroup);

    // Checkbox group
    const checkGroup = document.createElement('div');
    setElementStyle(checkGroup, {
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
    });
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkGroup.appendChild(checkbox);
    const checkLabel = document.createElement('label');
    checkLabel.textContent = 'I agree to terms';
    checkGroup.appendChild(checkLabel);
    container.appendChild(checkGroup);

    // Submit button
    const submitBtn = document.createElement('button');
    submitBtn.textContent = 'Submit';
    setElementStyle(submitBtn, {
      padding: '12px',
      backgroundColor: '#3498db',
      color: 'white',
      border: 'none',
      borderRadius: '4px',
      marginTop: '10px',
    });
    container.appendChild(submitBtn);

    await snapshot();
  });

  it('should handle flex column with table inside', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '20px',
      padding: '20px',
      backgroundColor: '#f5f5f5',
    });
    document.body.appendChild(container);

    // Header
    const header = document.createElement('h3');
    header.textContent = 'Data Table';
    setElementStyle(header, {
      margin: '0',
      color: '#2c3e50',
    });
    container.appendChild(header);

    // Table container
    const tableContainer = document.createElement('div');
    setElementStyle(tableContainer, {
      backgroundColor: 'white',
      borderRadius: '8px',
      overflow: 'hidden',
      boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
    });
    container.appendChild(tableContainer);

    // Table
    const table = document.createElement('table');
    setElementStyle(table, {
      width: '100%',
      borderCollapse: 'collapse',
    });
    tableContainer.appendChild(table);

    // Table header
    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');
    ['Name', 'Age', 'City'].forEach(text => {
      const th = document.createElement('th');
      th.textContent = text;
      setElementStyle(th, {
        padding: '12px',
        backgroundColor: '#34495e',
        color: 'white',
        textAlign: 'left',
      });
      headerRow.appendChild(th);
    });
    thead.appendChild(headerRow);
    table.appendChild(thead);

    // Table body
    const tbody = document.createElement('tbody');
    const data = [
      ['John Doe', '30', 'New York'],
      ['Jane Smith', '25', 'London'],
      ['Bob Johnson', '35', 'Paris'],
    ];
    data.forEach((row, i) => {
      const tr = document.createElement('tr');
      row.forEach(cell => {
        const td = document.createElement('td');
        td.textContent = cell;
        setElementStyle(td, {
          padding: '12px',
          borderBottom: '1px solid #ddd',
          backgroundColor: i % 2 === 0 ? 'white' : '#f8f9fa',
        });
        tr.appendChild(td);
      });
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);

    await snapshot();
  });

  it('should handle flex column with backdrop filter', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '20px',
      padding: '20px',
      background: 'linear-gradient(45deg, #3498db, #9b59b6)',
      minHeight: '400px',
    });
    document.body.appendChild(container);

    // Glass morphism card
    const glassCard = document.createElement('div');
    setElementStyle(glassCard, {
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      backdropFilter: 'blur(10px)',
      border: '1px solid rgba(255, 255, 255, 0.2)',
      borderRadius: '12px',
      padding: '30px',
      color: 'white',
    });
    const cardTitle = document.createElement('h3');
    cardTitle.textContent = 'Glass Card';
    setElementStyle(cardTitle, { margin: '0 0 10px 0' });
    glassCard.appendChild(cardTitle);
    const cardContent = document.createElement('p');
    cardContent.textContent = 'This card has a glass morphism effect with backdrop blur.';
    setElementStyle(cardContent, { margin: '0' });
    glassCard.appendChild(cardContent);
    container.appendChild(glassCard);

    // Semi-transparent panels
    const panel = document.createElement('div');
    setElementStyle(panel, {
      backgroundColor: 'rgba(0, 0, 0, 0.3)',
      backdropFilter: 'blur(5px)',
      padding: '20px',
      borderRadius: '8px',
      color: 'white',
    });
    panel.textContent = 'Semi-transparent panel with blur';
    container.appendChild(panel);

    await snapshot();
  });

  it('should handle flex column with media objects pattern', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '20px',
      padding: '20px',
      backgroundColor: '#f5f5f5',
    });
    document.body.appendChild(container);

    // Media object 1 - image left
    const media1 = document.createElement('div');
    setElementStyle(media1, {
      display: 'flex',
      gap: '15px',
      backgroundColor: 'white',
      padding: '15px',
      borderRadius: '8px',
      alignItems: 'flex-start',
    });
    const avatar1 = document.createElement('div');
    setElementStyle(avatar1, {
      width: '60px',
      height: '60px',
      backgroundColor: '#3498db',
      borderRadius: '50%',
      flexShrink: '0',
    });
    media1.appendChild(avatar1);
    const content1 = document.createElement('div');
    setElementStyle(content1, {
      flex: '1',
    });
    const name1 = document.createElement('h4');
    name1.textContent = 'John Doe';
    setElementStyle(name1, { margin: '0 0 5px 0' });
    content1.appendChild(name1);
    const text1 = document.createElement('p');
    text1.textContent = 'This is a comment or post content that can be quite long and will wrap naturally.';
    setElementStyle(text1, { margin: '0', color: '#666' });
    content1.appendChild(text1);
    media1.appendChild(content1);
    container.appendChild(media1);

    // Media object 2 - image right
    const media2 = document.createElement('div');
    setElementStyle(media2, {
      display: 'flex',
      gap: '15px',
      backgroundColor: 'white',
      padding: '15px',
      borderRadius: '8px',
      alignItems: 'center',
      flexDirection: 'row-reverse',
    });
    const avatar2 = document.createElement('div');
    setElementStyle(avatar2, {
      width: '48px',
      height: '48px',
      backgroundColor: '#e74c3c',
      borderRadius: '4px',
      flexShrink: '0',
    });
    media2.appendChild(avatar2);
    const content2 = document.createElement('div');
    setElementStyle(content2, {
      flex: '1',
    });
    const text2 = document.createElement('p');
    text2.textContent = 'Right-aligned media object';
    setElementStyle(text2, { margin: '0' });
    content2.appendChild(text2);
    media2.appendChild(content2);
    container.appendChild(media2);

    await snapshot();
  });

  it('should handle flex column with aspect ratio boxes', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      gap: '20px',
      padding: '20px',
      backgroundColor: '#f0f0f0',
      alignItems: 'flex-start',
    });
    document.body.appendChild(container);

    // 16:9 aspect ratio box
    const aspectBox1 = document.createElement('div');
    setElementStyle(aspectBox1, {
      width: '300px',
      aspectRatio: '16 / 9',
      backgroundColor: '#3498db',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: 'white',
      borderRadius: '8px',
    });
    aspectBox1.textContent = '16:9';
    container.appendChild(aspectBox1);

    // 1:1 aspect ratio box
    const aspectBox2 = document.createElement('div');
    setElementStyle(aspectBox2, {
      width: '200px',
      aspectRatio: '1',
      backgroundColor: '#e74c3c',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: 'white',
      borderRadius: '8px',
    });
    aspectBox2.textContent = '1:1';
    container.appendChild(aspectBox2);

    // 4:3 aspect ratio box
    const aspectBox3 = document.createElement('div');
    setElementStyle(aspectBox3, {
      width: '240px',
      aspectRatio: '4 / 3',
      backgroundColor: '#2ecc71',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: 'white',
      borderRadius: '8px',
    });
    aspectBox3.textContent = '4:3';
    container.appendChild(aspectBox3);

    await snapshot();
  });
});