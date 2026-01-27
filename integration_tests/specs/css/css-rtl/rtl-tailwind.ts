import styles from './rtl-tailwind.css';

describe('RTL Tailwind CSS', () => {
  beforeEach(() => {
    styles.use();
  });

  afterEach(() => {
    styles.unuse();
  });

  // ============================================
  // 1. Tailwind Logical Properties (ps-*, pe-*, ms-*, me-*)
  // ============================================

  describe('Logical Properties', () => {
    it('should apply padding-inline-start (ps-*) correctly in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'ps-8 bg-blue-200 p-2';
      box.textContent = 'ps-8 (padding-start: 32px)';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply padding-inline-end (pe-*) correctly in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'pe-8 bg-green-200 p-2';
      box.textContent = 'pe-8 (padding-end: 32px)';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply margin-inline-start (ms-*) correctly in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'ms-8 bg-purple-200 p-2';
      box.textContent = 'ms-8 (margin-start: 32px)';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply margin-inline-end (me-*) correctly in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'me-8 bg-pink-200 p-2';
      box.textContent = 'me-8 (margin-end: 32px)';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should compare logical vs physical spacing in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const logicalBox = document.createElement('div');
      logicalBox.className = 'ms-4 me-8 ps-2 pe-4 bg-blue-100 mb-2 border border-blue-300';
      logicalBox.textContent = 'Logical: ms-4 me-8 ps-2 pe-4';

      const physicalBox = document.createElement('div');
      physicalBox.className = 'ml-4 mr-8 pl-2 pr-4 bg-green-100 border border-green-300';
      physicalBox.textContent = 'Physical: ml-4 mr-8 pl-2 pr-4';

      container.appendChild(logicalBox);
      container.appendChild(physicalBox);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply combined inline spacing (px-*, mx-*) in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'px-6 mx-4 bg-yellow-200 py-2';
      box.textContent = 'px-6 mx-4 (symmetric)';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });
  });

  // ============================================
  // 2. Flexbox RTL
  // ============================================

  describe('Flexbox RTL', () => {
    it('should render flex-row in RTL context', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const flexBox = document.createElement('div');
      flexBox.className = 'flex flex-row gap-2 p-2 bg-slate-100';

      ['1', '2', '3'].forEach((num, i) => {
        const item = document.createElement('div');
        const colors = ['bg-red-500', 'bg-green-500', 'bg-blue-500'];
        item.className = `w-16 h-10 flex items-center justify-center text-white text-sm font-medium ${colors[i]}`;
        item.textContent = num;
        flexBox.appendChild(item);
      });

      container.appendChild(flexBox);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should render flex-row-reverse in RTL context', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const flexBox = document.createElement('div');
      flexBox.className = 'flex flex-row-reverse gap-2 p-2 bg-slate-200';

      ['1', '2', '3'].forEach((num, i) => {
        const item = document.createElement('div');
        const colors = ['bg-red-500', 'bg-green-500', 'bg-blue-500'];
        item.className = `w-16 h-10 flex items-center justify-center text-white text-sm font-medium ${colors[i]}`;
        item.textContent = num;
        flexBox.appendChild(item);
      });

      container.appendChild(flexBox);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should render justify-start in RTL context', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const flexBox = document.createElement('div');
      flexBox.className = 'flex justify-start gap-2 p-2 bg-slate-100';

      ['A', 'B'].forEach((text, i) => {
        const item = document.createElement('div');
        const colors = ['bg-red-500', 'bg-green-500'];
        item.className = `w-16 h-10 flex items-center justify-center text-white text-sm font-medium ${colors[i]}`;
        item.textContent = text;
        flexBox.appendChild(item);
      });

      container.appendChild(flexBox);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should render justify-end in RTL context', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const flexBox = document.createElement('div');
      flexBox.className = 'flex justify-end gap-2 p-2 bg-slate-200';

      ['A', 'B'].forEach((text, i) => {
        const item = document.createElement('div');
        const colors = ['bg-red-500', 'bg-green-500'];
        item.className = `w-16 h-10 flex items-center justify-center text-white text-sm font-medium ${colors[i]}`;
        item.textContent = text;
        flexBox.appendChild(item);
      });

      container.appendChild(flexBox);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle space-x in RTL context', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const flexBox = document.createElement('div');
      flexBox.className = 'flex space-x-4 p-2 bg-blue-50';

      ['1', '2', '3'].forEach((num, i) => {
        const item = document.createElement('div');
        const colors = ['bg-red-500', 'bg-green-500', 'bg-blue-500'];
        item.className = `w-12 h-10 flex items-center justify-center text-white text-sm font-medium ${colors[i]}`;
        item.textContent = num;
        flexBox.appendChild(item);
      });

      container.appendChild(flexBox);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle space-x-reverse in RTL context', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const flexBox = document.createElement('div');
      flexBox.className = 'flex flex-row-reverse space-x-4 space-x-reverse p-2 bg-blue-100';

      ['1', '2', '3'].forEach((num, i) => {
        const item = document.createElement('div');
        const colors = ['bg-red-500', 'bg-green-500', 'bg-blue-500'];
        item.className = `w-12 h-10 flex items-center justify-center text-white text-sm font-medium ${colors[i]}`;
        item.textContent = num;
        flexBox.appendChild(item);
      });

      container.appendChild(flexBox);
      document.body.appendChild(container);

      await snapshot();
    });
  });

  // ============================================
  // 3. Grid RTL
  // ============================================

  describe('Grid RTL', () => {
    it('should render grid layout in RTL context', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const grid = document.createElement('div');
      grid.className = 'grid grid-cols-3 gap-2 p-2 bg-gray-100';

      const colors = ['bg-red-500', 'bg-orange-500', 'bg-yellow-500', 'bg-green-500', 'bg-blue-500', 'bg-purple-500'];

      colors.forEach((color, i) => {
        const item = document.createElement('div');
        item.className = `h-10 flex items-center justify-center text-white text-sm font-medium ${color}`;
        item.textContent = String(i + 1);
        grid.appendChild(item);
      });

      container.appendChild(grid);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should compare grid in LTR vs RTL', async () => {
      const wrapper = document.createElement('div');
      wrapper.className = 'w-[340px]';

      // LTR Grid
      const ltrContainer = document.createElement('div');
      ltrContainer.className = 'p-4 border border-gray-300 mb-2';
      ltrContainer.style.direction = 'ltr';

      const ltrLabel = document.createElement('div');
      ltrLabel.className = 'mb-2 text-sm font-medium';
      ltrLabel.textContent = 'LTR Grid:';
      ltrContainer.appendChild(ltrLabel);

      const ltrGrid = document.createElement('div');
      ltrGrid.className = 'grid grid-cols-3 gap-2';

      ['1', '2', '3'].forEach((num, i) => {
        const item = document.createElement('div');
        item.className = `h-10 flex items-center justify-center text-white text-sm font-medium bg-blue-${(i + 3) * 100}`;
        item.textContent = num;
        ltrGrid.appendChild(item);
      });

      ltrContainer.appendChild(ltrGrid);
      wrapper.appendChild(ltrContainer);

      // RTL Grid
      const rtlContainer = document.createElement('div');
      rtlContainer.className = 'p-4 border border-gray-300';
      rtlContainer.style.direction = 'rtl';

      const rtlLabel = document.createElement('div');
      rtlLabel.className = 'mb-2 text-sm font-medium';
      rtlLabel.textContent = 'RTL Grid:';
      rtlContainer.appendChild(rtlLabel);

      const rtlGrid = document.createElement('div');
      rtlGrid.className = 'grid grid-cols-3 gap-2';

      ['1', '2', '3'].forEach((num, i) => {
        const item = document.createElement('div');
        item.className = `h-10 flex items-center justify-center text-white text-sm font-medium bg-green-${(i + 3) * 100}`;
        item.textContent = num;
        rtlGrid.appendChild(item);
      });

      rtlContainer.appendChild(rtlGrid);
      wrapper.appendChild(rtlContainer);

      document.body.appendChild(wrapper);

      await snapshot();
    });
  });

  // ============================================
  // 4. Text Alignment RTL
  // ============================================

  describe('Text Alignment RTL', () => {
    it('should handle text-start in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const text = document.createElement('div');
      text.className = 'text-start bg-gray-100 p-2';
      text.textContent = 'text-start (right in RTL)';

      container.appendChild(text);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle text-end in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const text = document.createElement('div');
      text.className = 'text-end bg-gray-200 p-2';
      text.textContent = 'text-end (left in RTL)';

      container.appendChild(text);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should compare all text alignments in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const alignments = [
        { className: 'text-start', label: 'text-start (logical)' },
        { className: 'text-end', label: 'text-end (logical)' },
        { className: 'text-left', label: 'text-left (physical)' },
        { className: 'text-right', label: 'text-right (physical)' },
        { className: 'text-center', label: 'text-center' },
      ];

      alignments.forEach(({ className, label }, i) => {
        const text = document.createElement('div');
        const bgColors = ['bg-gray-100', 'bg-gray-200', 'bg-gray-100', 'bg-gray-200', 'bg-gray-100'];
        text.className = `${className} ${bgColors[i]} p-2 mb-1`;
        text.textContent = label;
        container.appendChild(text);
      });

      document.body.appendChild(container);

      await snapshot();
    });
  });

  // ============================================
  // 5. Border RTL
  // ============================================

  describe('Border RTL', () => {
    it('should apply border-s (border-inline-start) in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'border-s-4 border-s-blue-500 p-4 bg-blue-50';
      box.textContent = 'border-s-4 (start border)';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply border-e (border-inline-end) in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'border-e-4 border-e-red-500 p-4 bg-red-50';
      box.textContent = 'border-e-4 (end border)';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply rounded-s (border-start-radius) in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'rounded-s-xl bg-green-300 p-4';
      box.textContent = 'rounded-s-xl';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply rounded-e (border-end-radius) in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const box = document.createElement('div');
      box.className = 'rounded-e-xl bg-purple-300 p-4';
      box.textContent = 'rounded-e-xl';

      container.appendChild(box);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should compare borders in LTR vs RTL', async () => {
      const wrapper = document.createElement('div');
      wrapper.className = 'w-[340px]';

      // LTR
      const ltrContainer = document.createElement('div');
      ltrContainer.className = 'p-4 border border-gray-300 mb-2';
      ltrContainer.style.direction = 'ltr';

      const ltrLabel = document.createElement('div');
      ltrLabel.className = 'mb-2 text-sm font-medium';
      ltrLabel.textContent = 'LTR:';
      ltrContainer.appendChild(ltrLabel);

      const ltrBox1 = document.createElement('div');
      ltrBox1.className = 'border-s-4 border-s-blue-500 p-2 bg-blue-50 mb-2';
      ltrBox1.textContent = 'border-s (left)';
      ltrContainer.appendChild(ltrBox1);

      const ltrBox2 = document.createElement('div');
      ltrBox2.className = 'border-e-4 border-e-red-500 p-2 bg-red-50';
      ltrBox2.textContent = 'border-e (right)';
      ltrContainer.appendChild(ltrBox2);

      wrapper.appendChild(ltrContainer);

      // RTL
      const rtlContainer = document.createElement('div');
      rtlContainer.className = 'p-4 border border-gray-300';
      rtlContainer.style.direction = 'rtl';

      const rtlLabel = document.createElement('div');
      rtlLabel.className = 'mb-2 text-sm font-medium';
      rtlLabel.textContent = 'RTL:';
      rtlContainer.appendChild(rtlLabel);

      const rtlBox1 = document.createElement('div');
      rtlBox1.className = 'border-s-4 border-s-blue-500 p-2 bg-blue-50 mb-2';
      rtlBox1.textContent = 'border-s (right)';
      rtlContainer.appendChild(rtlBox1);

      const rtlBox2 = document.createElement('div');
      rtlBox2.className = 'border-e-4 border-e-red-500 p-2 bg-red-50';
      rtlBox2.textContent = 'border-e (left)';
      rtlContainer.appendChild(rtlBox2);

      wrapper.appendChild(rtlContainer);

      document.body.appendChild(wrapper);

      await snapshot();
    });
  });

  // ============================================
  // 6. Position RTL (start/end insets)
  // ============================================

  describe('Position RTL', () => {
    it('should apply start-* (inset-inline-start) in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const posContainer = document.createElement('div');
      posContainer.className = 'relative w-full h-24 bg-gray-200 border border-gray-400';

      const box = document.createElement('div');
      box.className = 'absolute start-2 top-2 w-12 h-12 bg-red-400 flex items-center justify-center text-white text-sm';
      box.textContent = 'S';

      posContainer.appendChild(box);
      container.appendChild(posContainer);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should apply end-* (inset-inline-end) in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const posContainer = document.createElement('div');
      posContainer.className = 'relative w-full h-24 bg-gray-200 border border-gray-400';

      const box = document.createElement('div');
      box.className = 'absolute end-2 top-2 w-12 h-12 bg-blue-400 flex items-center justify-center text-white text-sm';
      box.textContent = 'E';

      posContainer.appendChild(box);
      container.appendChild(posContainer);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should position both start and end elements in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const posContainer = document.createElement('div');
      posContainer.className = 'relative w-full h-24 bg-gray-200 border border-gray-400';

      const startBox = document.createElement('div');
      startBox.className = 'absolute start-2 top-2 w-12 h-12 bg-red-400 flex items-center justify-center text-white text-sm';
      startBox.textContent = 'S';

      const endBox = document.createElement('div');
      endBox.className = 'absolute end-2 top-2 w-12 h-12 bg-blue-400 flex items-center justify-center text-white text-sm';
      endBox.textContent = 'E';

      posContainer.appendChild(startBox);
      posContainer.appendChild(endBox);
      container.appendChild(posContainer);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should compare position in LTR vs RTL', async () => {
      const wrapper = document.createElement('div');
      wrapper.className = 'w-[340px]';

      // LTR
      const ltrContainer = document.createElement('div');
      ltrContainer.className = 'p-4 border border-gray-300 mb-2';
      ltrContainer.style.direction = 'ltr';

      const ltrLabel = document.createElement('div');
      ltrLabel.className = 'mb-2 text-sm font-medium';
      ltrLabel.textContent = 'LTR: S=left, E=right';
      ltrContainer.appendChild(ltrLabel);

      const ltrPosContainer = document.createElement('div');
      ltrPosContainer.className = 'relative w-full h-20 bg-gray-200 border border-gray-400';

      const ltrStart = document.createElement('div');
      ltrStart.className = 'absolute start-2 top-2 w-10 h-10 bg-red-400 flex items-center justify-center text-white text-xs';
      ltrStart.textContent = 'S';

      const ltrEnd = document.createElement('div');
      ltrEnd.className = 'absolute end-2 top-2 w-10 h-10 bg-blue-400 flex items-center justify-center text-white text-xs';
      ltrEnd.textContent = 'E';

      ltrPosContainer.appendChild(ltrStart);
      ltrPosContainer.appendChild(ltrEnd);
      ltrContainer.appendChild(ltrPosContainer);
      wrapper.appendChild(ltrContainer);

      // RTL
      const rtlContainer = document.createElement('div');
      rtlContainer.className = 'p-4 border border-gray-300';
      rtlContainer.style.direction = 'rtl';

      const rtlLabel = document.createElement('div');
      rtlLabel.className = 'mb-2 text-sm font-medium';
      rtlLabel.textContent = 'RTL: S=right, E=left';
      rtlContainer.appendChild(rtlLabel);

      const rtlPosContainer = document.createElement('div');
      rtlPosContainer.className = 'relative w-full h-20 bg-gray-200 border border-gray-400';

      const rtlStart = document.createElement('div');
      rtlStart.className = 'absolute start-2 top-2 w-10 h-10 bg-red-400 flex items-center justify-center text-white text-xs';
      rtlStart.textContent = 'S';

      const rtlEnd = document.createElement('div');
      rtlEnd.className = 'absolute end-2 top-2 w-10 h-10 bg-blue-400 flex items-center justify-center text-white text-xs';
      rtlEnd.textContent = 'E';

      rtlPosContainer.appendChild(rtlStart);
      rtlPosContainer.appendChild(rtlEnd);
      rtlContainer.appendChild(rtlPosContainer);
      wrapper.appendChild(rtlContainer);

      document.body.appendChild(wrapper);

      await snapshot();
    });
  });

  // ============================================
  // 7. Mixed Direction Content
  // ============================================

  describe('Mixed Direction Content', () => {
    it('should handle nested LTR inside RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const rtlBlock = document.createElement('div');
      rtlBlock.className = 'p-2 bg-green-50 mb-2 border-s-4 border-s-green-500';
      rtlBlock.textContent = 'RTL: مرحبا بالعالم (Hello World)';

      const ltrBlock = document.createElement('div');
      ltrBlock.className = 'p-2 bg-blue-50 border-s-4 border-s-blue-500';
      ltrBlock.style.direction = 'ltr';
      ltrBlock.textContent = 'LTR: Hello World (مرحبا بالعالم)';

      container.appendChild(rtlBlock);
      container.appendChild(ltrBlock);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle flexbox with mixed direction children', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const flexBox = document.createElement('div');
      flexBox.className = 'flex flex-row gap-2 p-2 bg-slate-100';

      const rtlItem = document.createElement('div');
      rtlItem.className = 'px-3 py-2 bg-red-500 text-white text-sm rounded';
      rtlItem.textContent = 'عربي';

      const ltrItem = document.createElement('div');
      ltrItem.className = 'px-3 py-2 bg-green-500 text-white text-sm rounded';
      ltrItem.style.direction = 'ltr';
      ltrItem.textContent = 'English';

      const mixedItem = document.createElement('div');
      mixedItem.className = 'px-3 py-2 bg-blue-500 text-white text-sm rounded';
      mixedItem.textContent = 'Mix مزيج';

      flexBox.appendChild(rtlItem);
      flexBox.appendChild(ltrItem);
      flexBox.appendChild(mixedItem);
      container.appendChild(flexBox);
      document.body.appendChild(container);

      await snapshot();
    });
  });

  // ============================================
  // 8. RTL with Arabic Text
  // ============================================

  describe('RTL with Arabic Text', () => {
    it('should render Arabic text in RTL container with Tailwind styles', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const card = document.createElement('div');
      card.className = 'bg-gradient-to-br from-indigo-500 to-purple-600 p-4 rounded-lg text-white';

      const title = document.createElement('h2');
      title.className = 'text-xl font-bold mb-2';
      title.textContent = 'مرحبا بكم';

      const content = document.createElement('p');
      content.className = 'text-sm opacity-90';
      content.textContent = 'هذا نص تجريبي لاختبار دعم اللغة العربية مع Tailwind CSS';

      card.appendChild(title);
      card.appendChild(content);
      container.appendChild(card);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle RTL list with Tailwind spacing', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const list = document.createElement('ul');
      list.className = 'list-disc ps-6';

      const items = ['العنصر الأول', 'العنصر الثاني', 'العنصر الثالث'];

      items.forEach(text => {
        const li = document.createElement('li');
        li.className = 'mb-1 ps-2';
        li.textContent = text;
        list.appendChild(li);
      });

      container.appendChild(list);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle RTL form layout with Tailwind', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const form = document.createElement('div');
      form.className = 'flex flex-col gap-3';

      const fields = [
        { label: 'الاسم', placeholder: 'أدخل اسمك' },
        { label: 'البريد الإلكتروني', placeholder: 'أدخل بريدك' },
      ];

      fields.forEach(({ label, placeholder }) => {
        const fieldGroup = document.createElement('div');
        fieldGroup.className = 'flex flex-col gap-1';

        const labelEl = document.createElement('label');
        labelEl.className = 'font-semibold text-sm text-gray-700';
        labelEl.textContent = label;

        const input = document.createElement('input');
        input.type = 'text';
        input.placeholder = placeholder;
        input.className = 'px-3 py-2 border border-gray-300 rounded-md text-sm';

        fieldGroup.appendChild(labelEl);
        fieldGroup.appendChild(input);
        form.appendChild(fieldGroup);
      });

      container.appendChild(form);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle RTL button group with Tailwind', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const buttonGroup = document.createElement('div');
      buttonGroup.className = 'flex gap-2';

      const primaryBtn = document.createElement('button');
      primaryBtn.className = 'px-4 py-2 bg-blue-500 text-white rounded-md text-sm font-medium';
      primaryBtn.textContent = 'حفظ';

      const secondaryBtn = document.createElement('button');
      secondaryBtn.className = 'px-4 py-2 bg-gray-200 text-gray-700 rounded-md text-sm font-medium';
      secondaryBtn.textContent = 'إلغاء';

      const dangerBtn = document.createElement('button');
      dangerBtn.className = 'px-4 py-2 bg-red-500 text-white rounded-md text-sm font-medium ms-auto';
      dangerBtn.textContent = 'حذف';

      buttonGroup.appendChild(primaryBtn);
      buttonGroup.appendChild(secondaryBtn);
      buttonGroup.appendChild(dangerBtn);
      container.appendChild(buttonGroup);
      document.body.appendChild(container);

      await snapshot();
    });
  });

  // ============================================
  // 9. Scroll and Overflow RTL
  // ============================================

  describe('Scroll and Overflow RTL', () => {
    it('should handle horizontal scroll in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const scrollContainer = document.createElement('div');
      scrollContainer.className = 'overflow-x-auto pb-2';

      const content = document.createElement('div');
      content.className = 'flex gap-2 w-[600px]';

      for (let i = 1; i <= 8; i++) {
        const item = document.createElement('div');
        item.className = 'flex-shrink-0 w-16 h-16 bg-blue-500 text-white flex items-center justify-center rounded';
        item.textContent = String(i);
        content.appendChild(item);
      }

      scrollContainer.appendChild(content);
      container.appendChild(scrollContainer);
      document.body.appendChild(container);

      await snapshot();
    });
  });

  // ============================================
  // 10. Divide utilities RTL
  // ============================================

  describe('Divide Utilities RTL', () => {
    it('should handle divide-x in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const divideContainer = document.createElement('div');
      divideContainer.className = 'flex divide-x divide-gray-400';

      ['أ', 'ب', 'ج'].forEach(text => {
        const item = document.createElement('div');
        item.className = 'px-4 py-2 bg-gray-100';
        item.textContent = text;
        divideContainer.appendChild(item);
      });

      container.appendChild(divideContainer);
      document.body.appendChild(container);

      await snapshot();
    });

    it('should handle divide-x-reverse in RTL', async () => {
      const container = document.createElement('div');
      container.className = 'w-[340px] p-4 border border-gray-300';
      container.style.direction = 'rtl';

      const divideContainer = document.createElement('div');
      divideContainer.className = 'flex flex-row-reverse divide-x divide-x-reverse divide-gray-400';

      ['أ', 'ب', 'ج'].forEach(text => {
        const item = document.createElement('div');
        item.className = 'px-4 py-2 bg-gray-100';
        item.textContent = text;
        divideContainer.appendChild(item);
      });

      container.appendChild(divideContainer);
      document.body.appendChild(container);

      await snapshot();
    });
  });
});
