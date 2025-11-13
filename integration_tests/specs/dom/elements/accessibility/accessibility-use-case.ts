// Integration coverage for the Accessibility use case page patterns.
// Mirrors the skip link, roving tabindex menu, live announcements, and FAQ toggle behaviours.

describe('Accessibility use case patterns', () => {
  it('keeps the skip link focusable and targeted to the main content', async () => {
    document.body.innerHTML = '';

    const skipLink = document.createElement('a');
    skipLink.className = 'skipLink';
    skipLink.setAttribute('href', '#accessibilityMainContent');
    skipLink.textContent = 'Skip to main content';

    const main = document.createElement('main');
    main.id = 'accessibilityMainContent';
    main.setAttribute('role', 'main');

    document.body.appendChild(skipLink);
    document.body.appendChild(main);

    expect(skipLink.getAttribute('href')).toBe('#accessibilityMainContent');
    expect(main.id).toBe('accessibilityMainContent');
    await snapshot();
  });

  it('labels the section navigation landmark and preserves internal links', async () => {
    document.body.innerHTML = '';

    const nav = document.createElement('nav');
    nav.className = 'landmarkNav';
    nav.setAttribute('aria-label', 'Section navigation');

    const heading = document.createElement('strong');
    heading.textContent = 'Navigation';
    nav.appendChild(heading);

    const list = document.createElement('ul');
    list.className = 'landmarkNavList';
    nav.appendChild(list);

    const links = [
      ['#accessibility-main-demo', 'Landmark demo'],
      ['#keyboard-menu-demo', 'Keyboard menu'],
      ['#feedback-form-demo', 'Feedback form'],
    ] as const;

    links.forEach(([fragment, label]) => {
      const li = document.createElement('li');
      const anchor = document.createElement('a');
      anchor.setAttribute('href', fragment);
      anchor.textContent = label;

      li.appendChild(anchor);
      list.appendChild(li);
    });

    document.body.appendChild(nav);

    expect(nav.tagName).toBe('NAV');
    expect(nav.getAttribute('aria-label')).toBe('Section navigation');
    expect(heading.textContent).toBe('Navigation');

    const renderedLinks = Array.from(nav.querySelectorAll('a'));
    expect(renderedLinks.length).toBe(3);
    renderedLinks.forEach((anchor, index) => {
      const [fragment, label] = links[index];
      expect(anchor.getAttribute('href')).toBe(fragment);
      expect(anchor.textContent).toBe(label);
    });
    await snapshot();
  });

  it('supports roving tabindex menu interactions with live announcements', async () => {
    type MenuItem = { label: string; description: string };

    const MENU_ITEMS: MenuItem[] = [
      {
        label: 'Overview',
        description: 'Highlights the page purpose and reinforces orientation cues for assistive technology.',
      },
      {
        label: 'Keyboard Shortcuts',
        description: 'Summarises keys that help power users and screen reader operators move quickly.',
      },
      {
        label: 'Support',
        description: 'Points to human support options when automated answers fall short.',
      },
    ];

    const menu = document.createElement('div');
    menu.setAttribute('role', 'menubar');
    menu.setAttribute('aria-label', 'Accessibility resources');

    const summaryTitle = document.createElement('h3');
    const summaryBody = document.createElement('p');

    const liveRegion = document.createElement('div');
    liveRegion.setAttribute('role', 'status');
    liveRegion.setAttribute('aria-live', 'polite');
    liveRegion.setAttribute('aria-atomic', 'true');

    const menuButtons: HTMLButtonElement[] = [];
    let focusIndex = 0;

    const announce = (message: string) => {
      liveRegion.textContent = message;
    };

    const setFocus = (index: number) => {
      focusIndex = index;
      summaryTitle.textContent = MENU_ITEMS[index].label;
      summaryBody.textContent = MENU_ITEMS[index].description;

      menuButtons.forEach((button, buttonIndex) => {
        button.tabIndex = buttonIndex === index ? 0 : -1;
        if (buttonIndex === index) {
          button.classList.add('menuButtonActive');
          if (typeof button.focus === 'function') {
            button.focus();
          }
        } else {
          button.classList.remove('menuButtonActive');
        }
      });
    };

    const handleMenuSelect = (item: MenuItem, index: number) => {
      setFocus(index);
      announce(`${item.label} menu item activated.`);
    };

    const handleMenuKeyDown = (event: KeyboardEvent, index: number) => {
      if (event.defaultPrevented) {
        return;
      }

      if (event.key === 'ArrowRight' || event.key === 'ArrowDown') {
        event.preventDefault();
        const nextIndex = (index + 1) % MENU_ITEMS.length;
        setFocus(nextIndex);
        announce(`Moved to ${MENU_ITEMS[nextIndex].label} menu item.`);
        return;
      }

      if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') {
        event.preventDefault();
        const prevIndex = (index - 1 + MENU_ITEMS.length) % MENU_ITEMS.length;
        setFocus(prevIndex);
        announce(`Moved to ${MENU_ITEMS[prevIndex].label} menu item.`);
        return;
      }

      if (event.key === 'Home') {
        event.preventDefault();
        setFocus(0);
        announce('Moved to Overview menu item.');
        return;
      }

      if (event.key === 'End') {
        event.preventDefault();
        const lastIndex = MENU_ITEMS.length - 1;
        setFocus(lastIndex);
        announce(`Moved to ${MENU_ITEMS[lastIndex].label} menu item.`);
        return;
      }

      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        handleMenuSelect(MENU_ITEMS[index], index);
      }
    };

    MENU_ITEMS.forEach((item, index) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.setAttribute('role', 'menuitem');
      button.textContent = item.label;
      button.tabIndex = index === focusIndex ? 0 : -1;
      button.addEventListener('keydown', (event: KeyboardEvent) => handleMenuKeyDown(event, index));
      button.addEventListener('click', () => handleMenuSelect(item, index));
      menuButtons.push(button);
      menu.appendChild(button);
    });

    document.body.appendChild(menu);
    document.body.appendChild(summaryTitle);
    document.body.appendChild(summaryBody);
    document.body.appendChild(liveRegion);

    setFocus(0);

    const rightEvent = new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true });
    menuButtons[0].dispatchEvent(rightEvent);
    expect(menuButtons[1].tabIndex).toBe(0);
    expect(menuButtons[0].tabIndex).toBe(-1);
    expect(summaryTitle.textContent).toBe('Keyboard Shortcuts');
    expect(liveRegion.textContent).toBe('Moved to Keyboard Shortcuts menu item.');

    const endEvent = new KeyboardEvent('keydown', { key: 'End', bubbles: true });
    menuButtons[1].dispatchEvent(endEvent);
    expect(menuButtons[2].tabIndex).toBe(0);
    expect(summaryTitle.textContent).toBe('Support');
    expect(liveRegion.textContent).toBe('Moved to Support menu item.');

    const homeEvent = new KeyboardEvent('keydown', { key: 'Home', bubbles: true });
    menuButtons[2].dispatchEvent(homeEvent);
    expect(menuButtons[0].tabIndex).toBe(0);
    expect(summaryTitle.textContent).toBe('Overview');
    expect(liveRegion.textContent).toBe('Moved to Overview menu item.');

    const enterEvent = new KeyboardEvent('keydown', { key: 'Enter', bubbles: true });
    menuButtons[0].dispatchEvent(enterEvent);
    expect(liveRegion.textContent).toBe('Overview menu item activated.');
  });

  it('validates the accessible feedback form and announces issues', async () => {
    document.body.innerHTML = '';

    const form = document.createElement('form');
    form.noValidate = true;

    const nameInput = document.createElement('input');
    nameInput.name = 'name';
    nameInput.id = 'name';
    form.appendChild(nameInput);

    const emailInput = document.createElement('input');
    emailInput.name = 'email';
    emailInput.id = 'email';
    emailInput.type = 'email';
    form.appendChild(emailInput);

    const messageInput = document.createElement('textarea');
    messageInput.name = 'message';
    messageInput.id = 'message';
    form.appendChild(messageInput);

    const hint = document.createElement('p');
    hint.id = 'feedback-form-hint';
    form.appendChild(hint);

    const errorBox = document.createElement('div');
    errorBox.className = 'errorMessage';
    errorBox.setAttribute('role', 'alert');
    errorBox.hidden = true;
    form.appendChild(errorBox);

    const successBox = document.createElement('div');
    successBox.className = 'successMessage';
    successBox.setAttribute('role', 'status');
    successBox.setAttribute('aria-live', 'polite');
    successBox.hidden = true;
    form.appendChild(successBox);

    const liveRegion = document.createElement('div');
    liveRegion.className = 'liveRegion';
    liveRegion.setAttribute('role', 'status');
    liveRegion.setAttribute('aria-live', 'polite');
    liveRegion.setAttribute('aria-atomic', 'true');

    let lastAnnouncement = '';
    const announce = (message: string) => {
      lastAnnouncement = message;
      liveRegion.textContent = message;
    };

    const handleFormSubmit = (form) => {
      var formData = new FormData(form);

      errorBox.hidden = true;
      errorBox.textContent = '';
      successBox.hidden = true;
      successBox.textContent = '';

      const name = nameInput.value;// (formData.get('name') as string | null)?.trim() ?? '';
      const email = emailInput.value;//(formData.get('email') as string | null)?.trim() ?? '';
      const message = messageInput.value;//(formData.get('message') as string | null)?.trim() ?? '';

      if (!name || name === '') {
        errorBox.hidden = false;
        errorBox.textContent = 'Please enter your name before submitting.';
        announce('Form error: Name is missing.');
        return;
      }

      const emailPattern = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
      
      if (!emailPattern.test(email)) {
        errorBox.hidden = false;
        errorBox.textContent = 'Enter a valid email address (example: name@domain.com).';
        announce('Form error: Email address is invalid.');
        return;
      }

      if (message.length < 10) {
        errorBox.hidden = false;
        errorBox.textContent = 'Tell us a little more so we can help (at least 10 characters).';
        announce('Form error: Message is too short.');
        return;
      }

      successBox.hidden = false;
      successBox.textContent = 'Thank you! We will reach out if we need more details.';
      announce('Accessibility feedback form submitted successfully.');
    };

    document.body.appendChild(form);
    document.body.appendChild(liveRegion);

    handleFormSubmit(form);
    expect(errorBox.hidden).toBe(false);
    expect(errorBox.textContent).toBe('Please enter your name before submitting.');
    expect(lastAnnouncement).toBe('Form error: Name is missing.');
    await snapshot(0.1);

    nameInput.value = 'Ada Lovelace';
    handleFormSubmit(form);
    expect(errorBox.hidden).toBe(false);
    expect(errorBox.textContent).toBe('Enter a valid email address (example: name@domain.com).');
    expect(lastAnnouncement).toBe('Form error: Email address is invalid.');
    await snapshot(0.1);

    emailInput.value = 'ada@example.dev';
    messageInput.value = 'Too short';
    handleFormSubmit(form);
    expect(errorBox.hidden).toBe(false);
    expect(errorBox.textContent).toBe('Tell us a little more so we can help (at least 10 characters).');
    expect(lastAnnouncement).toBe('Form error: Message is too short.');
    await snapshot(0.1);

    messageInput.value = 'Accessibility in WebF is great!';
    handleFormSubmit(form);
    expect(errorBox.hidden).toBe(true);
    expect(successBox.hidden).toBe(false);
    expect(successBox.textContent).toBe('Thank you! We will reach out if we need more details.');
    expect(lastAnnouncement).toBe('Accessibility feedback form submitted successfully.');
    await snapshot(0.1);
  });

  it('announces FAQ toggle state changes and keeps region synced', async () => {
    const faqToggle = document.createElement('button');
    faqToggle.type = 'button';
    faqToggle.id = 'faq-toggle';
    faqToggle.setAttribute('aria-expanded', 'false');
    faqToggle.setAttribute('aria-controls', 'faq-panel');

    const faqPanel = document.createElement('div');
    faqPanel.id = 'faq-panel';
    faqPanel.hidden = true;

    const liveRegion = document.createElement('div');
    liveRegion.setAttribute('role', 'status');
    liveRegion.setAttribute('aria-live', 'polite');
    liveRegion.setAttribute('aria-atomic', 'true');

    const announcements: string[] = [];
    const announce = (message: string) => {
      liveRegion.textContent = message;
      announcements.push(message);
    };

    const toggleFaq = () => {
      const expanded = faqToggle.getAttribute('aria-expanded') === 'true';
      const next = !expanded;
      faqToggle.setAttribute('aria-expanded', next ? 'true' : 'false');
      faqPanel.hidden = !next;
      announce(next ? 'FAQ details expanded.' : 'FAQ details collapsed.');
    };

    // faqToggle.addEventListener('click', toggleFaq);
    document.body.appendChild(faqToggle);
    document.body.appendChild(faqPanel);
    document.body.appendChild(liveRegion);
    await snapshot();

    // faqToggle.click();
    toggleFaq();
    expect(faqToggle.getAttribute('aria-expanded')).toBe('true');
    expect(faqPanel.hidden).toBe(false);
    expect(liveRegion.textContent).toBe('FAQ details expanded.');
    expect(announcements[0]).toBe('FAQ details expanded.');
    await snapshot();

    // faqToggle.click();
    toggleFaq();
    expect(faqToggle.getAttribute('aria-expanded')).toBe('false');
    expect(faqPanel.hidden).toBe(true);
    expect(liveRegion.textContent).toBe('FAQ details collapsed.');
    expect(announcements[1]).toBe('FAQ details collapsed.');
    await snapshot();
  });
});
