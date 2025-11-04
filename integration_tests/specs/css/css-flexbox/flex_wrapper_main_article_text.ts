describe('Flex wrapper/main long text wrapping', () => {
  function createStyles() {
    const style = document.createElement('style');
    style.textContent = `
      .caseTitle { margin: 8px 0; font-weight: bold; font-size: 12px; }
      .wrapper {
        display: flex;
        box-sizing: border-box;
        padding: 8px;
        margin: 8px 0;
        border: 1px solid #ccc;
        background: #f9fafb;
        gap: 8px;
      }
      .main {
        box-sizing: border-box;
        padding: 8px;
        border: 1px dashed #6b8ef3;
        line-height: 1.4;
        /* No min-width here; we toggle it per case to reproduce wrapping issues */
      }
      .minWidthZero { min-width: 0; }
      .fixedSidebar { width: 48px; height: 48px; background:#e2e8f0; border:1px solid #cbd5e1; flex: 0 0 auto; }
    `;
    document.head.appendChild(style);
  }

  function createArticleText(): string {
    return (
      'The flexible box layout module (usually referred to as flexbox) is a one-dimensional layout model for ' +
      'distributing space between items and includes numerous alignment capabilities. This article gives an outline ' +
      'of the main features of flexbox, which we will explore in more detail in the rest of these guides.'
    );
  }

  function buildCase({ withMinWidthZero }: { withMinWidthZero: boolean }) {
    const container = document.createElement('div');
    container.style.width = '360px';

    const title = document.createElement('div');
    title.className = 'caseTitle';
    title.textContent = withMinWidthZero
      ? 'Case A: flex child with min-width: 0'
      : 'Case B: flex child with default min-width (auto)';

    const wrapper = document.createElement('div');
    wrapper.className = 'wrapper';

    // Simulate a common layout: a small fixed-size sibling + the text area
    const sidebar = document.createElement('div');
    sidebar.className = 'fixedSidebar';

    const main = document.createElement('div');
    main.className = 'main';
    main.style.flex = '1 1 auto';
    if (withMinWidthZero) main.classList.add('minWidthZero');
    main.textContent = createArticleText();

    wrapper.appendChild(sidebar);
    wrapper.appendChild(main);
    container.appendChild(title);
    container.appendChild(wrapper);

    return { container, wrapper, main };
  }

  it('renders article text in flex wrapper with/without min-width:0 across widths', async () => {
    createStyles();

    // Build two comparable cases
    const caseA = buildCase({ withMinWidthZero: true });
    const caseB = buildCase({ withMinWidthZero: false });

    // Stack vertically for comparison
    const host = document.createElement('div');
    host.style.display = 'flex';
    host.style.flexDirection = 'column';
    host.style.gap = '12px';
    host.appendChild(caseA.container);
    host.appendChild(caseB.container);
    document.body.appendChild(host);

    // Baseline snapshot at 360px width
    await snapshot();

    // Reduce width to amplify wrapping/overflow differences
    caseA.container.style.width = '280px';
    caseB.container.style.width = '280px';
    await snapshot();

    // Very narrow to stress text shrink/wrap and min-width behavior
    caseA.container.style.width = '200px';
    caseB.container.style.width = '200px';
    await snapshot();

    // Extreme narrow
    caseA.container.style.width = '140px';
    caseB.container.style.width = '140px';
    await snapshot();
  });
});

