// Snapshot + structural test for the WebF Accessibility use case page.
// Mirrors the layout defined in use_cases/src/pages/AccessibilityPage.tsx so
// we track regressions where <webf-listview> hosts complex accessible content.

describe('Accessibility: WebFListView layout', () => {
  it('renders skip link, menubar section, form, FAQ, and live region inside listview', async () => {
    document.body.innerHTML = '';

    const root = document.createElement('div');
    root.id = 'main';
    root.style.fontFamily = 'system-ui, -apple-system, BlinkMacSystemFont, Segoe UI';
    root.style.background = '#f1f5f9';
    root.style.padding = '16px';
    root.style.display = 'flex';
    root.style.flexDirection = 'column';
    root.style.gap = '16px';

    const skipLink = document.createElement('a');
    skipLink.className = 'skip-link';
    skipLink.href = '#accessibilityMainContent';
    skipLink.textContent = 'Skip to main content';
    skipLink.style.alignSelf = 'flex-start';
    skipLink.style.padding = '8px 12px';
    skipLink.style.borderRadius = '999px';
    skipLink.style.backgroundColor = '#1d4ed8';
    skipLink.style.color = '#fff';

    const header = document.createElement('header');
    header.setAttribute('role', 'banner');
    header.style.display = 'flex';
    header.style.flexDirection = 'column';
    header.style.gap = '8px';
    header.tabIndex = -1;

    const title = document.createElement('h1');
    title.textContent = 'Accessibility Use Cases';
    title.style.margin = '0';

    const subtitle = document.createElement('p');
    subtitle.textContent =
      'Skip links, keyboard navigation, live announcements, and inclusive forms in action.';
    subtitle.style.margin = '0';

    header.appendChild(title);
    header.appendChild(subtitle);

    const listview = document.createElement('webf-listview');
    listview.style.display = 'block';
    listview.style.padding = '20px';
    listview.style.borderRadius = '18px';
    listview.style.backgroundColor = '#fff';
    listview.style.height = '600px';
    listview.style.overflow = 'auto';
    listview.style.border = '1px solid rgba(148, 163, 184, 0.35)';
    listview.style.boxShadow = '0 25px 45px rgba(15, 23, 42, 0.18)';

    const main = document.createElement('main');
    main.id = 'accessibilityMainContent';
    main.setAttribute('role', 'main');
    main.style.display = 'flex';
    main.style.flexDirection = 'column';
    main.style.gap = '20px';

    const listviewRegions: HTMLElement[] = [];
    const registerRegion = (element: HTMLElement) => {
      element.tabIndex = -1;
      listviewRegions.push(element);
    };

    const focusRegion = (element: HTMLElement) => {
      if (document.activeElement === element) {
        return;
      }
      if (typeof element.focus === 'function') {
        try {
          element.focus({ preventScroll: true } as any);
        } catch (_) {
          element.focus();
        }
      }
    };

    const nextFrame = (callback: () => void): number => {
      if (typeof requestAnimationFrame === 'function') {
        return requestAnimationFrame(callback);
      }
      return setTimeout(callback, 16);
    };

    const cancelFrame = (handle: number) => {
      if (typeof cancelAnimationFrame === 'function') {
        cancelAnimationFrame(handle);
      } else {
        clearTimeout(handle);
      }
    };

    const createSection = (headingText: string, descriptionText: string) => {
      const section = document.createElement('section');
      section.style.border = '1px solid rgba(15, 23, 42, 0.08)';
      section.style.borderRadius = '16px';
      section.style.padding = '16px';
      section.style.background = 'linear-gradient(145deg, #fff, #f8fafc)';
      section.style.display = 'flex';
      section.style.flexDirection = 'column';
      section.style.gap = '12px';

      const heading = document.createElement('h2');
      heading.textContent = headingText;
      heading.style.margin = '0';
      heading.style.fontSize = '18px';

      const description = document.createElement('p');
      description.textContent = descriptionText;
      description.style.margin = '0';
      description.style.color = '#475569';

      section.appendChild(heading);
      section.appendChild(description);
      registerRegion(section);
      return section;
    };

    // Keyboard menu section (roving tabindex demo).
    const menuSection = createSection(
      'Keyboard-Friendly Navigation',
      'Roving tab index keeps arrow key interactions scoped while Tab/Shift+Tab still exit the widget.'
    );
    menuSection.id = 'keyboard-menu-demo';
    menuSection.setAttribute('aria-labelledby', 'keyboard-menu-title');

    const menuContainerHeading = menuSection.querySelector('h2');
    if (menuContainerHeading) {
      menuContainerHeading.id = 'keyboard-menu-title';
    }

    const menu = document.createElement('div');
    menu.setAttribute('role', 'menubar');
    menu.setAttribute('aria-label', 'Accessibility resources');
    menu.style.display = 'flex';
    menu.style.flexWrap = 'wrap';
    menu.style.gap = '8px';

    const menuItems = [
      {
        label: 'Overview',
        description:
          'Highlights the page purpose and reinforces orientation cues for assistive technology.'
      },
      {
        label: 'Keyboard Shortcuts',
        description: 'Summarises keys that help screen reader users move quickly.'
      },
      {
        label: 'Support',
        description: 'Points to human support options when automated answers fall short.'
      }
    ];

    const summaryPanel = document.createElement('div');
    summaryPanel.className = 'menu-summary';
    summaryPanel.style.border = '1px solid rgba(15, 23, 42, 0.08)';
    summaryPanel.style.borderRadius = '12px';
    summaryPanel.style.padding = '12px';
    summaryPanel.style.backgroundColor = '#fff';
    summaryPanel.style.display = 'flex';
    summaryPanel.style.flexDirection = 'column';
    summaryPanel.style.gap = '8px';
    summaryPanel.setAttribute('aria-live', 'polite');
    summaryPanel.setAttribute('aria-atomic', 'true');

    const summaryTitle = document.createElement('h3');
    summaryTitle.style.margin = '0';
    summaryTitle.textContent = menuItems[0].label;

    const summaryBody = document.createElement('p');
    summaryBody.id = 'menu-item-desc-0';
    summaryBody.style.margin = '0';
    summaryBody.style.color = '#0f172a';
    summaryBody.textContent = menuItems[0].description;

    summaryPanel.appendChild(summaryTitle);
    summaryPanel.appendChild(summaryBody);

    const menuButtons: HTMLButtonElement[] = [];
    let currentActiveIndex = 0;

    const updateActiveMenu = (activeIndex: number) => {
      currentActiveIndex = activeIndex;
      summaryTitle.textContent = menuItems[activeIndex].label;
      summaryBody.textContent = menuItems[activeIndex].description;
      summaryBody.id = `menu-item-desc-${activeIndex}`;

      menuButtons.forEach((button, index) => {
        const isActive = index === activeIndex;
        button.tabIndex = isActive ? 0 : -1;
        button.setAttribute('data-active', String(isActive));
        button.style.backgroundColor = isActive ? '#1d4ed8' : 'transparent';
        button.style.color = isActive ? '#fff' : '#1d4ed8';
        button.style.boxShadow = isActive ? 'inset 0 0 0 1px #1d4ed8' : 'inset 0 0 0 1px #1d4ed8';
      });
    };

    menuItems.forEach((item, index) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.textContent = item.label;
      button.setAttribute('role', 'menuitem');
      button.setAttribute('aria-describedby', `menu-item-desc-${index}`);
      button.style.padding = '10px 16px';
      button.style.borderRadius = '999px';
      button.style.border = 'none';
      button.style.fontWeight = '600';
      button.style.cursor = 'pointer';
      button.style.transition = 'background-color 0.2s ease';
      menuButtons.push(button);

      const activate = () => {
        updateActiveMenu(index);
      };

      button.addEventListener('click', activate);
      button.addEventListener('focus', activate);

      menu.appendChild(button);
    });

    updateActiveMenu(0);

    const menuLayout = document.createElement('div');
    menuLayout.style.display = 'flex';
    menuLayout.style.flexDirection = 'column';
    menuLayout.style.gap = '12px';
    menuLayout.appendChild(menu);
    menuLayout.appendChild(summaryPanel);

    menuSection.appendChild(menuLayout);

    // Accessible feedback form.
    const formSection = createSection(
      'Accessible Feedback Form',
      'Labels, instructions, and validation messages remain linked to their inputs.'
    );
    formSection.id = 'feedback-form-demo';
    formSection.setAttribute('aria-labelledby', 'feedback-form-title');
    const formHeading = formSection.querySelector('h2');
    if (formHeading) {
      formHeading.id = 'feedback-form-title';
    }

    const form = document.createElement('form');
    form.noValidate = true;
    form.className = 'feedback-form';
    form.setAttribute('aria-describedby', 'feedback-form-hint');
    form.style.display = 'flex';
    form.style.flexDirection = 'column';
    form.style.gap = '12px';

    const createField = (labelText: string, input: HTMLInputElement | HTMLTextAreaElement, hint?: string) => {
      const wrapper = document.createElement('div');
      wrapper.style.display = 'flex';
      wrapper.style.flexDirection = 'column';
      wrapper.style.gap = '4px';

      const label = document.createElement('label');
      label.htmlFor = input.id;
      label.textContent = labelText;
      label.style.fontWeight = '600';

      input.required = true;
      input.setAttribute('aria-required', 'true');
      input.style.padding = '10px';
      input.style.borderRadius = '8px';
      input.style.border = '1px solid rgba(15, 23, 42, 0.15)';

      wrapper.appendChild(label);
      wrapper.appendChild(input);

      if (hint) {
        const hintParagraph = document.createElement('p');
        hintParagraph.id = `${input.id}-hint`;
        hintParagraph.textContent = hint;
        hintParagraph.style.margin = '0';
        hintParagraph.style.fontSize = '12px';
        hintParagraph.style.color = '#475569';
        wrapper.appendChild(hintParagraph);
        input.setAttribute('aria-describedby', hintParagraph.id);
      }

      return wrapper;
    };

    const nameInput = document.createElement('input');
    nameInput.id = 'name';
    nameInput.name = 'name';
    nameInput.placeholder = 'Ada Lovelace';

    const emailInput = document.createElement('input');
    emailInput.id = 'email';
    emailInput.name = 'email';
    emailInput.type = 'email';
    emailInput.placeholder = 'ada@example.dev';

    const messageInput = document.createElement('textarea');
    messageInput.id = 'message';
    messageInput.name = 'message';
    messageInput.rows = 4;
    messageInput.placeholder = 'Tell us what you tried, what happened, and what you expected instead.';

    form.appendChild(createField('Full name *', nameInput));
    form.appendChild(
      createField('Email address *', emailInput, 'We use your address to follow up on accessibility issues.')
    );
    form.appendChild(createField('Describe the issue *', messageInput));

    const formHint = document.createElement('p');
    formHint.id = 'feedback-form-hint';
    formHint.textContent = 'Required fields are marked with an asterisk.';
    formHint.style.margin = '0';
    formHint.style.fontSize = '12px';
    formHint.style.color = '#475569';

    const errorMessage = document.createElement('div');
    errorMessage.className = 'errorMessage';
    errorMessage.setAttribute('role', 'alert');
    errorMessage.textContent = 'Please enter your name before submitting.';
    errorMessage.style.padding = '12px';
    errorMessage.style.borderRadius = '10px';
    errorMessage.style.background = '#fee2e2';
    errorMessage.style.color = '#b91c1c';

    const successMessage = document.createElement('div');
    successMessage.className = 'successMessage';
    successMessage.setAttribute('role', 'status');
    successMessage.setAttribute('aria-live', 'polite');
    successMessage.textContent = 'Thank you! We will reach out if we need more details.';
    successMessage.style.padding = '12px';
    successMessage.style.borderRadius = '10px';
    successMessage.style.background = '#dcfce7';
    successMessage.style.color = '#166534';

    const submitButton = document.createElement('button');
    submitButton.type = 'submit';
    submitButton.textContent = 'Submit feedback';
    submitButton.style.backgroundColor = '#0f172a';
    submitButton.style.color = '#fff';
    submitButton.style.border = 'none';
    submitButton.style.borderRadius = '999px';
    submitButton.style.padding = '12px 20px';
    submitButton.style.fontWeight = '600';

    form.appendChild(formHint);
    form.appendChild(errorMessage);
    form.appendChild(successMessage);
    form.appendChild(submitButton);

    formSection.appendChild(form);

    // FAQ toggle section.
    const faqSection = createSection(
      'Discernible Expansion Controls',
      'Toggle buttons announce their expanded state so users always know what changed.'
    );
    faqSection.id = 'faq-toggle';

    const faqButton = document.createElement('button');
    faqButton.type = 'button';
    faqButton.setAttribute('aria-expanded', 'true');
    faqButton.setAttribute('aria-controls', 'faq-panel');
    faqButton.textContent = 'Hide accessibility FAQ';
    faqButton.style.alignSelf = 'flex-start';
    faqButton.style.padding = '10px 18px';
    faqButton.style.borderRadius = '999px';
    faqButton.style.border = '1px solid #1d4ed8';
    faqButton.style.backgroundColor = '#1d4ed8';
    faqButton.style.color = '#fff';

    const faqPanel = document.createElement('div');
    faqPanel.id = 'faq-panel';
    faqPanel.hidden = false;
    faqPanel.style.display = 'flex';
    faqPanel.style.flexDirection = 'column';
    faqPanel.style.gap = '8px';

    const faqHeading = document.createElement('h3');
    faqHeading.textContent = 'Why does this matter?';
    faqHeading.style.margin = '0';

    const faqText = document.createElement('p');
    faqText.textContent =
      'Accessible patterns reduce cognitive load, prevent focus traps, and ensure assistive technology conveys everything your visual design promises.';
    faqText.style.margin = '0';

    const faqList = document.createElement('ul');
    ['Focus styles stay visible.', 'ARIA is only used when semantics need help.', 'Live regions announce changes.'].forEach(
      (item) => {
        const li = document.createElement('li');
        li.textContent = item;
        faqList.appendChild(li);
      }
    );

    faqPanel.appendChild(faqHeading);
    faqPanel.appendChild(faqText);
    faqPanel.appendChild(faqList);

    faqSection.appendChild(faqButton);
    faqSection.appendChild(faqPanel);

    const liveRegion = document.createElement('div');
    liveRegion.className = 'liveRegion';
    liveRegion.setAttribute('role', 'status');
    liveRegion.setAttribute('aria-live', 'polite');
    liveRegion.setAttribute('aria-atomic', 'true');
    liveRegion.textContent =
      'Interactive examples ready. Use the skip link or jump straight into the keyboard menu demo.';
    liveRegion.style.padding = '12px';
    liveRegion.style.borderRadius = '10px';
    liveRegion.style.background = '#1d4ed8';
    liveRegion.style.color = '#fff';
    registerRegion(liveRegion);

    main.appendChild(menuSection);
    main.appendChild(formSection);
    main.appendChild(faqSection);
    main.appendChild(liveRegion);

    listview.appendChild(main);

    root.appendChild(skipLink);
    root.appendChild(header);
    root.appendChild(listview);

    document.body.appendChild(root);
    const listViewportPadding = 24;
    const syncFocusWithViewport = () => {
      const active = document.activeElement as HTMLElement | null;
      const listRect = listview.getBoundingClientRect();
      if (active && listview.contains(active)) {
        const rect = active.getBoundingClientRect();
        const overlap = Math.min(listRect.bottom, rect.bottom) - Math.max(listRect.top, rect.top);
        if (overlap > listViewportPadding) {
          return;
        }
      }

      const nextRegion = listviewRegions.find((region) => {
        const rect = region.getBoundingClientRect();
        const overlap = Math.min(listRect.bottom, rect.bottom) - Math.max(listRect.top, rect.top);
        return overlap > listViewportPadding;
      });

      if (nextRegion) {
        focusRegion(nextRegion);
      }
    };

    const scheduleViewportSync = (() => {
      let frameHandle: number | null = null;
      return () => {
        if (frameHandle !== null) {
          cancelFrame(frameHandle);
        }
        frameHandle = nextFrame(() => {
          frameHandle = null;
          syncFocusWithViewport();
        });
      };
    })();

    listview.addEventListener('scroll', scheduleViewportSync);

    const awaitScrollSync = () =>
      new Promise<void>((resolve) => {
        nextFrame(() => resolve());
      });

    focusRegion(header);
    listview.scrollTop = 320;
    listview.dispatchEvent(new Event('scroll'));
    await awaitScrollSync();

    await snapshot();
  });
});
