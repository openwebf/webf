fdescribe('Bidirectional Text (Phase 1)', () => {
  // Basic RTL Text Tests (1.1-1.6)

  it('should render RTL text correctly', async () => {
    const div = document.createElement('div');
    div.style.direction = 'rtl';
    div.style.width = '300px';
    div.textContent = 'مرحبا بك في WebF';
    document.body.appendChild(div);

    await snapshot();
  });

  it('should handle mixed LTR and RTL text', async () => {
    const div = document.createElement('div');
    div.style.width = '350px';
    div.textContent = 'Hello مرحبا World عالم!';
    document.body.appendChild(div);

    await snapshot();
  });

  it('should respect unicode-bidi property', async () => {
    const div = document.createElement('div');
    div.style.width = '350px';
    div.innerHTML = `
      <span style="unicode-bidi: embed; direction: rtl;">RTL text</span>
      in LTR context
    `;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should handle nested direction changes', async () => {
    const div = document.createElement('div');
    div.style.direction = 'rtl';
    div.style.width = '350px';
    div.innerHTML = `
      RTL: مرحبا
      <span style="direction: ltr;">LTR: Hello</span>
      عالم
    `;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should handle bidi text with inline formatting', async () => {
    const div = document.createElement('div');
    div.style.width = '350px';
    div.innerHTML = `
      English <strong>bold</strong> text مع <em>نص عربي</em> مائل
    `;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should support unicode-bidi: isolate', async () => {
    const div = document.createElement('div');
    div.style.width = '350px';
    div.innerHTML = `
      User <span style="unicode-bidi: isolate;">اسم:محمد</span> (ID: 123)
    `;
    document.body.appendChild(div);

    await snapshot();
  });

  // RTL Box Model Tests (1.7-1.18)

  it('should apply margins correctly in RTL context', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.border = '1px solid black';

    const div1 = document.createElement('div');
    div1.style.marginLeft = '20px';
    div1.style.marginRight = '40px';
    div1.style.background = 'lightblue';
    div1.textContent = 'RTL: margin-left should be on physical left (end)';

    const div2 = document.createElement('div');
    div2.style.marginInlineStart = '20px';
    div2.style.marginInlineEnd = '40px';
    div2.style.background = 'lightgreen';
    div2.textContent = 'RTL: logical margins should adapt to direction';

    container.appendChild(div1);
    container.appendChild(div2);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should apply padding correctly in RTL context', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const div1 = document.createElement('div');
    div1.style.paddingLeft = '20px';
    div1.style.paddingRight = '40px';
    div1.style.background = 'lightblue';
    div1.style.border = '1px solid blue';
    div1.textContent = 'RTL: padding-left (20px) on physical left';

    const div2 = document.createElement('div');
    div2.style.paddingInlineStart = '20px';
    div2.style.paddingInlineEnd = '40px';
    div2.style.background = 'lightgreen';
    div2.style.border = '1px solid green';
    div2.textContent = 'RTL: logical padding adapts to direction';

    container.appendChild(div1);
    container.appendChild(div2);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should apply borders correctly in RTL context', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const div1 = document.createElement('div');
    div1.style.borderLeft = '5px solid red';
    div1.style.borderRight = '10px solid blue';
    div1.style.padding = '10px';
    div1.textContent = 'Physical borders: left=red(5px), right=blue(10px)';

    const div2 = document.createElement('div');
    div2.style.borderInlineStart = '5px solid red';
    div2.style.borderInlineEnd = '10px solid blue';
    div2.style.padding = '10px';
    div2.style.marginTop = '10px';
    div2.textContent = 'Logical borders: start=red, end=blue';

    container.appendChild(div1);
    container.appendChild(div2);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle text-align with RTL box model', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.border = '1px solid black';

    const alignments = [
      { align: 'left', bg: '#f0f0f0', text: 'text-align: left (physical left)' },
      { align: 'right', bg: '#e0e0e0', text: 'text-align: right (physical right)' },
      { align: 'start', bg: '#d0d0d0', text: 'text-align: start (logical - should be right in RTL)' },
      { align: 'end', bg: '#c0c0c0', text: 'text-align: end (logical - should be left in RTL)' }
    ];

    alignments.forEach(({ align, bg, text }) => {
      const div = document.createElement('div');
      div.style.textAlign = align;
      div.style.padding = '10px';
      div.style.background = bg;
      div.textContent = text;
      container.appendChild(div);
    });

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle positioned elements in RTL context', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.height = '200px';
    container.style.position = 'relative';
    container.style.border = '2px solid black';

    const positions = [
      { left: '10px', top: '10px', bg: 'red', text: 'left: 10px' },
      { right: '10px', top: '10px', bg: 'blue', text: 'right: 10px' },
      { insetInlineStart: '10px', top: '70px', bg: 'green', text: 'inset-inline-start' },
      { insetInlineEnd: '10px', top: '70px', bg: 'orange', text: 'inset-inline-end' }
    ];

    positions.forEach(({ left, right, insetInlineStart, insetInlineEnd, top, bg, text }) => {
      const div = document.createElement('div');
      div.style.position = 'absolute';
      div.style.width = '50px';
      div.style.height = '50px';
      div.style.background = bg;
      div.style.top = top;

      if (left) div.style.left = left;
      if (right) div.style.right = right;
      if (insetInlineStart) div.style.insetInlineStart = insetInlineStart;
      if (insetInlineEnd) div.style.insetInlineEnd = insetInlineEnd;

      div.textContent = text;
      container.appendChild(div);
    });

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle inline element box model in RTL', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.fontSize = '16px';

    const p = document.createElement('p');
    p.innerHTML = `
      RTL text with
      <span style="margin-left: 10px; margin-right: 20px; padding: 5px; background: yellow;">
        physical margins
      </span>
      and
      <span style="margin-inline-start: 10px; margin-inline-end: 20px; padding: 5px; background: lightblue;">
        logical margins
      </span>
    `;

    container.appendChild(p);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle nested direction changes with box model', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.padding = '20px';
    container.style.border = '2px solid black';

    const nestedDiv = document.createElement('div');
    nestedDiv.style.direction = 'ltr';
    nestedDiv.style.margin = '10px';
    nestedDiv.style.padding = '10px';
    nestedDiv.style.border = '1px solid blue';
    nestedDiv.innerHTML = `
      LTR nested with margins
      <span style="direction: rtl; display: inline-block; margin: 5px; padding: 5px; background: yellow;">
        RTL inline-block
      </span>
    `;

    container.textContent = 'RTL container with padding';
    container.appendChild(nestedDiv);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle overflow scrolling in RTL', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '300px';
    container.style.height = '100px';
    container.style.overflow = 'auto';
    container.style.border = '1px solid black';

    const content = document.createElement('div');
    content.style.width = '500px';
    content.style.padding = '10px';
    content.textContent = 'محتوى عربي طويل جداً يتجاوز عرض الحاوية ويحتاج إلى التمرير الأفقي Long Arabic content that exceeds container width and needs horizontal scrolling';

    container.appendChild(content);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle all logical properties in RTL context', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const div = document.createElement('div');
    div.style.marginBlockStart = '10px';
    div.style.marginBlockEnd = '10px';
    div.style.marginInlineStart = '20px';
    div.style.marginInlineEnd = '30px';
    div.style.paddingBlockStart = '5px';
    div.style.paddingBlockEnd = '5px';
    div.style.paddingInlineStart = '15px';
    div.style.paddingInlineEnd = '25px';
    div.style.borderBlockStart = '2px solid red';
    div.style.borderBlockEnd = '2px solid blue';
    div.style.borderInlineStart = '3px solid green';
    div.style.borderInlineEnd = '4px solid orange';
    div.style.background = '#f0f0f0';
    div.textContent = 'Full logical box model in RTL';

    container.appendChild(div);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should calculate box dimensions correctly in RTL', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const div = document.createElement('div');
    div.style.width = '200px';
    div.style.paddingLeft = '20px';
    div.style.paddingRight = '30px';
    div.style.borderLeft = '5px solid red';
    div.style.borderRight = '10px solid blue';
    div.style.marginLeft = '10px';
    div.style.marginRight = '15px';
    div.style.background = 'lightgray';
    div.innerHTML = `
      Total width = 200 + 20 + 30 + 5 + 10 = 265px<br>
      With margins: 265 + 10 + 15 = 290px
    `;

    container.appendChild(div);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle transform-origin in RTL context', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.height = '200px';
    container.style.fontSize = '14px';
    container.style.position = 'relative';

    const div1 = document.createElement('div');
    div1.style.position = 'absolute';
    div1.style.left = '50px';
    div1.style.top = '50px';
    div1.style.width = '100px';
    div1.style.height = '50px';
    div1.style.background = 'red';
    div1.style.transform = 'rotate(45deg)';
    div1.style.transformOrigin = 'left center';
    div1.textContent = 'Physical left origin';

    const div2 = document.createElement('div');
    div2.style.position = 'absolute';
    div2.style.right = '50px';
    div2.style.top = '50px';
    div2.style.width = '100px';
    div2.style.height = '50px';
    div2.style.background = 'blue';
    div2.style.transform = 'rotate(45deg)';
    div2.style.transformOrigin = 'right center';
    div2.textContent = 'Physical right origin';

    container.appendChild(div1);
    container.appendChild(div2);
    document.body.appendChild(container);

    await snapshot();
  });

  // Additional RTL-specific edge cases

  it('should handle RTL with inline-block elements', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.border = '1px solid black';
    container.style.padding = '10px';

    const elements = ['أول', 'ثاني', 'ثالث', 'رابع'];

    elements.forEach((text, index) => {
      const span = document.createElement('span');
      span.style.display = 'inline-block';
      span.style.width = '80px';
      span.style.height = '40px';
      span.style.background = `hsl(${index * 90}, 70%, 70%)`;
      span.style.margin = '5px';
      span.style.textAlign = 'center';
      span.style.lineHeight = '40px';
      span.textContent = text;
      container.appendChild(span);
    });

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle RTL with list items', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const ul = document.createElement('ul');
    ul.style.paddingInlineStart = '20px';

    const items = ['العنصر الأول', 'العنصر الثاني', 'العنصر الثالث'];

    items.forEach(text => {
      const li = document.createElement('li');
      li.textContent = text;
      ul.appendChild(li);
    });

    container.appendChild(ul);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle RTL with percentage widths', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.border = '1px solid black';

    const percentages = ['25%', '50%', '75%', '100%'];

    percentages.forEach(width => {
      const div = document.createElement('div');
      div.style.width = width;
      div.style.height = '30px';
      div.style.background = `rgba(0, 100, 200, ${parseFloat(width) / 100})`;
      div.style.marginBottom = '5px';
      div.textContent = `Width: ${width}`;
      container.appendChild(div);
    });

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle RTL with flexbox', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.display = 'flex';
    container.style.justifyContent = 'space-between';
    container.style.border = '1px solid black';
    container.style.padding = '10px';

    const items = ['أول', 'ثاني', 'ثالث'];

    items.forEach((text, index) => {
      const div = document.createElement('div');
      div.style.width = '100px';
      div.style.height = '50px';
      div.style.background = `hsl(${index * 120}, 70%, 70%)`;
      div.style.display = 'flex';
      div.style.alignItems = 'center';
      div.style.justifyContent = 'center';
      div.textContent = text;
      container.appendChild(div);
    });

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle mixed scripts with RTL', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';
    container.style.padding = '10px';
    container.style.border = '1px solid black';

    container.innerHTML = `
      <p>العربية: مرحبا بالعالم</p>
      <p>עברית: שלום עולם</p>
      <p>فارسی: سلام دنیا</p>
      <p>اردو: ہیلو دنیا</p>
      <p>Mixed: Hello مرحبا 世界 שלום</p>
    `;

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle RTL with CSS counters', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .rtl-counter {
        counter-reset: section;
      }
      .rtl-counter div::before {
        counter-increment: section;
        content: counter(section) ". ";
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.className = 'rtl-counter';
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const items = ['البند الأول', 'البند الثاني', 'البند الثالث'];

    items.forEach(text => {
      const div = document.createElement('div');
      div.textContent = text;
      container.appendChild(div);
    });

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle RTL text-indent', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const p1 = document.createElement('p');
    p1.style.textIndent = '2em';
    p1.style.border = '1px solid gray';
    p1.style.padding = '10px';
    p1.textContent = 'هذه فقرة باللغة العربية مع مسافة بادئة في بداية السطر الأول. يجب أن تظهر المسافة البادئة على الجانب الأيمن في سياق RTL.';

    const p2 = document.createElement('p');
    p2.style.textIndent = '-20px';
    p2.style.paddingInlineStart = '20px';
    p2.style.border = '1px solid gray';
    p2.style.padding = '10px';
    p2.textContent = '• هذه فقرة مع مسافة بادئة سالبة لإنشاء تأثير النقطة المعلقة في RTL';

    container.appendChild(p1);
    container.appendChild(p2);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should render UL bullets in RTL', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const ul = document.createElement('ul');
    ul.style.paddingInlineStart = '20px';

    const items = ['العنصر الأول', 'العنصر الثاني', 'العنصر الثالث'];

    items.forEach(text => {
      const li = document.createElement('li');
      li.textContent = text;
      ul.appendChild(li);
    });

    container.appendChild(ul);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should render OL decimal in RTL as 1. 2. 3.', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const ol = document.createElement('ol');
    ol.style.paddingInlineStart = '20px';
    // ensure default list-style-type applies to OL

    const items = ['البند الأول', 'البند الثاني', 'البند الثالث'];

    items.forEach(text => {
      const li = document.createElement('li');
      li.textContent = text;
      ol.appendChild(li);
    });

    container.appendChild(ol);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should support list-style-type alpha/roman in RTL', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '350px';

    const specs: Array<{ type: string; label: string }[]> = [
      [
        { type: 'lower-alpha', label: 'lower-alpha' },
        { type: 'upper-alpha', label: 'upper-alpha' },
      ],
      [
        { type: 'lower-roman', label: 'lower-roman' },
        { type: 'upper-roman', label: 'upper-roman' },
      ],
    ];

    specs.forEach(row => {
      const rowDiv = document.createElement('div');
      rowDiv.style.display = 'flex';
      rowDiv.style.justifyContent = 'space-between';
      rowDiv.style.marginBottom = '12px';

      row.forEach(spec => {
        const block = document.createElement('div');
        block.style.width = '160px';
        const ol = document.createElement('ol');
        ol.style.listStyleType = spec.type;
        ol.style.paddingInlineStart = '20px';
        ['البند الأول', 'البند الثاني', 'البند الثالث'].forEach(text => {
          const li = document.createElement('li');
          li.textContent = text + ' (' + spec.label + ')';
          ol.appendChild(li);
        });
        block.appendChild(ol);
        rowDiv.appendChild(block);
      });

      container.appendChild(rowDiv);
    });

    document.body.appendChild(container);

    await snapshot();
  });
});
