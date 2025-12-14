// Integration-style coverage for overflow scroll behaviour that WebF's
// semantics layer consumes (scrollTop / scrollHeight / clientHeight).

describe('Accessibility: overflow scroll semantics interop', () => {
  it('overflow region scrollTop updates and clamps within bounds', async () => {
    document.body.innerHTML = '';

    const region = document.createElement('div');
    region.id = 'chat-region';
    region.setAttribute('role', 'region');
    region.setAttribute('aria-label', 'Chat Messages');
    region.tabIndex = 0;
    Object.assign(region.style, {
      height: '120px',
      width: '260px',
      overflowY: 'auto',
      border: '1px solid #ccc',
      boxSizing: 'border-box',
    } as Partial<CSSStyleDeclaration>);

    // A series of fixed-height messages so that scrollHeight > clientHeight.
    for (let i = 0; i < 40; i++) {
      const message = document.createElement('div');
      message.id = `msg-${i}`;
      message.textContent = `Message ${i + 1}`;
      Object.assign(message.style, {
        height: '40px',
        lineHeight: '40px',
        borderBottom: '1px solid #eee',
      } as Partial<CSSStyleDeclaration>);
      region.appendChild(message);
    }
    document.body.appendChild(region);

    // add listview
    const landmarksContainer = document.createElement('webf-listview');
    landmarksContainer.style.height = '500px';
    landmarksContainer.style.border = '1px solid #000';
    landmarksContainer.className = 'landmarkExample';

    const header = document.createElement('header');
    header.className = 'landmarkHeader';
    header.setAttribute('aria-label', 'Example site header');
    header.appendChild(document.createElement('strong')).textContent = 'Header';
    header.appendChild(document.createElement('p')).textContent =
      'Contains the brand, search box, and global navigation entry points.';

    const nav = document.createElement('nav');
    nav.className = 'landmarkNav';
    nav.setAttribute('aria-label', 'Section navigation');
    nav.appendChild(document.createElement('strong')).textContent = 'Navigation';

    const navList = document.createElement('ul');
    navList.className = 'landmarkNavList';

    [
      ['#accessibility-main-demo', 'Landmark demo'],
      ['#keyboard-menu-demo', 'Keyboard menu'],
      ['#feedback-form-demo', 'Feedback form'],
    ].forEach(([href, label]) => {
      const li = document.createElement('li');
      const anchor = document.createElement('a');
      anchor.setAttribute('href', href);
      anchor.textContent = label;
      li.appendChild(anchor);
      navList.appendChild(li);
    });

    nav.appendChild(navList);

    const article = document.createElement('article');
    article.id = 'accessibility-main-demo';
    article.className = 'landmarkMain';
    article.setAttribute('aria-label', 'Main content');
    article.appendChild(document.createElement('strong')).textContent = 'Main';
    article.appendChild(document.createElement('p')).textContent =
      'Serves the primary user goal. Landmarks make it easy to find with a single shortcut.';

    const aside = document.createElement('aside');
    aside.className = 'landmarkAside';
    aside.setAttribute('aria-label', 'Helpful resources');
    aside.appendChild(document.createElement('strong')).textContent = 'Complementary';
    aside.appendChild(document.createElement('p')).textContent =
      'Holds related resources that support, but do not replace, the main task flow.';

    const footer = document.createElement('footer');
    footer.className = 'landmarkFooter';
    footer.setAttribute('aria-label', 'Example footer');
    footer.appendChild(document.createElement('strong')).textContent = 'Footer';
    footer.appendChild(document.createElement('p')).textContent =
      'Provides persistent help links and secondary navigation.';

    landmarksContainer.appendChild(header);
    landmarksContainer.appendChild(nav);
    landmarksContainer.appendChild(article);
    landmarksContainer.appendChild(aside);
    landmarksContainer.appendChild(footer);

    document.body.appendChild(landmarksContainer);


    // First paint so scroll metrics are stable.
    await snapshot();

    const initialScrollTop = region.scrollTop;
    const maxScroll = region.scrollHeight - region.clientHeight;

    expect(initialScrollTop).toBe(0);
    expect(maxScroll).toBeGreaterThan(0);

    // Scroll somewhere in the middle of the content.
    const midTarget = maxScroll * 0.5;
    region.scrollTop = midTarget;

    const midScrollTop = region.scrollTop;
    expect(midScrollTop).toBeGreaterThan(0);
    expect(midScrollTop).toBeLessThanOrEqual(maxScroll);

    // Scroll well beyond the end; DOM should clamp to the max scrollable
    // offset, which is what the semantics layer uses as scrollExtentMax.
    region.scrollTop = maxScroll + region.clientHeight * 2;

    const bottomScrollTop = region.scrollTop;
    expect(bottomScrollTop).toBeGreaterThan(0);
    expect(bottomScrollTop).toBeLessThanOrEqual(maxScroll);
    // Allow a small tolerance for rounding differences.
    expect(Math.abs(bottomScrollTop - maxScroll)).toBeLessThanOrEqual(1);

    await snapshot();
  });
});

