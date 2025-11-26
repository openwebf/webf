import React, { useEffect, useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './AccessibilityPage.module.css';

type MenuItem = {
  label: string;
  description: string;
};

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

export const AccessibilityPage: React.FC = () => {
  const [focusIndex, setFocusIndex] = useState(0);
  const [activeMenu, setActiveMenu] = useState<MenuItem>(MENU_ITEMS[0]);
  const [announcement, setAnnouncement] = useState(
    'Interactive examples ready. Use the skip link or jump straight into the keyboard menu demo.'
  );
  const [faqExpanded, setFaqExpanded] = useState(false);
  const [formSubmitted, setFormSubmitted] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const menuRefs = useRef<Array<HTMLButtonElement | null>>([]);

  useEffect(() => {
    menuRefs.current[focusIndex]?.focus();
  }, [focusIndex]);

  const announce = (message: string) => {
    setAnnouncement(message);
  };

  const handleMenuSelect = (item: MenuItem, index: number) => {
    setActiveMenu(item);
    setFocusIndex(index);
    announce(`${item.label} menu item activated.`);
  };

  const handleMenuKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>, index: number) => {
    if (event.defaultPrevented) {
      return;
    }

    if (event.key === 'ArrowRight' || event.key === 'ArrowDown') {
      event.preventDefault();
      const nextIndex = (index + 1) % MENU_ITEMS.length;
      setFocusIndex(nextIndex);
      setActiveMenu(MENU_ITEMS[nextIndex]);
      announce(`Moved to ${MENU_ITEMS[nextIndex].label} menu item.`);
      return;
    }

    if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') {
      event.preventDefault();
      const prevIndex = (index - 1 + MENU_ITEMS.length) % MENU_ITEMS.length;
      setFocusIndex(prevIndex);
      setActiveMenu(MENU_ITEMS[prevIndex]);
      announce(`Moved to ${MENU_ITEMS[prevIndex].label} menu item.`);
      return;
    }

    if (event.key === 'Home') {
      event.preventDefault();
      setFocusIndex(0);
      setActiveMenu(MENU_ITEMS[0]);
      announce('Moved to Overview menu item.');
      return;
    }

    if (event.key === 'End') {
      event.preventDefault();
      const lastIndex = MENU_ITEMS.length - 1;
      setFocusIndex(lastIndex);
      setActiveMenu(MENU_ITEMS[lastIndex]);
      announce(`Moved to ${MENU_ITEMS[lastIndex].label} menu item.`);
      return;
    }

    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      handleMenuSelect(MENU_ITEMS[index], index);
    }
  };

  const handleFormSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setFormSubmitted(false);

    const formData = new FormData(event.currentTarget);
    const name = (formData.get('name') as string | null)?.trim() ?? '';
    const email = (formData.get('email') as string | null)?.trim() ?? '';
    const message = (formData.get('message') as string | null)?.trim() ?? '';

    if (!name) {
      setFormError('Please enter your name before submitting.');
      announce('Form error: Name is missing.');
      return;
    }

    const emailPattern = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
    if (!emailPattern.test(email)) {
      setFormError('Enter a valid email address (example: name@domain.com).');
      announce('Form error: Email address is invalid.');
      return;
    }

    if (message.length < 10) {
      setFormError('Tell us a little more so we can help (at least 10 characters).');
      announce('Form error: Message is too short.');
      return;
    }

    setFormError(null);
    setFormSubmitted(true);
    event.currentTarget.reset();
    announce('Accessibility feedback form submitted successfully.');
  };

  const toggleFaq = () => {
    setFaqExpanded((previous) => {
      const next = !previous;
      announce(next ? 'FAQ details expanded.' : 'FAQ details collapsed.');
      return next;
    });
  };

  return (
    <div id="main" className={styles.pageWrapper}>
      <a className={styles.skipLink} href="#accessibilityMainContent">
        Skip to main content
      </a>
      <header className={styles.introHeader} role="banner">
        <h1 id="accessibility-page-title" className={styles.pageTitle}>
          Accessibility Use Cases
        </h1>
        <p className={styles.pageSubtitle}>
          Explore practical accessibility patterns: meaningful landmarks, keyboard interactions, live announcements, and
          inclusive forms that work for everyone.
        </p>
      </header>

      <WebFListView className={styles.list}>
        <main
          id="accessibilityMainContent"
          className={styles.componentSection}
          role="main"
          aria-labelledby="accessibility-page-title"
        >
          <div className={styles.componentBlock}>
            <section className={styles.componentItem} aria-labelledby="landmark-demo-title">
              <h2 id="landmark-demo-title" className={styles.itemLabel}>
                Landmarks &amp; Skip Navigation
              </h2>
              <p className={styles.itemDesc}>
                Structure pages so assistive technologies can offer shortcuts. Skip links paired with semantic landmarks
                let keyboard users move directly to the content they need.
              </p>

              <div className={styles.landmarkExample}>
                <header className={styles.landmarkHeader} aria-label="Example site header">
                  <strong>Header</strong>
                  <p>Contains the brand, search box, and global navigation entry points.</p>
                </header>
                <nav className={styles.landmarkNav} aria-label="Section navigation">
                  <strong>Navigation</strong>
                  <ul className={styles.landmarkNavList}>
                    <li>
                      <a href="#accessibility-main-demo">Landmark demo</a>
                    </li>
                    <li>
                      <a href="#keyboard-menu-demo">Keyboard menu</a>
                    </li>
                    <li>
                      <a href="#feedback-form-demo">Feedback form</a>
                    </li>
                  </ul>
                </nav>
                <article id="accessibility-main-demo" className={styles.landmarkMain} aria-label="Main content">
                  <strong>Main</strong>
                  <p>Serves the primary user goal. Landmarks make it easy to find with a single shortcut.</p>
                </article>
                <aside className={styles.landmarkAside} aria-label="Helpful resources">
                  <strong>Complementary</strong>
                  <p>Holds related resources that support, but do not replace, the main task flow.</p>
                </aside>
                <footer className={styles.landmarkFooter} aria-label="Example footer">
                  <strong>Footer</strong>
                  <p>Provides persistent help links and secondary navigation.</p>
                </footer>
              </div>
            </section>

            <section id="keyboard-menu-demo" className={styles.componentItem} aria-labelledby="keyboard-menu-title">
              <h2 id="keyboard-menu-title" className={styles.itemLabel}>
                Keyboard-Friendly Navigation
              </h2>
              <p className={styles.itemDesc}>
                Use roving tab-index patterns to keep arrow key navigation inside a widget while preserving Tab for
                entering and exiting. The active item is announced as focus moves.
              </p>

              <div className={styles.menuContainer}>
                <div className={styles.menu} role="menubar" aria-label="Accessibility resources">
                  {MENU_ITEMS.map((item, index) => (
                    <button
                      key={item.label}
                      type="button"
                      role="menuitem"
                      tabIndex={focusIndex === index ? 0 : -1}
                      className={`${styles.menuButton} ${focusIndex === index ? styles.menuButtonActive : ''}`}
                      ref={(element) => {
                        menuRefs.current[index] = element;
                      }}
                      aria-describedby={`menu-item-desc-${index}`}
                      onClick={() => handleMenuSelect(item, index)}
                      onKeyDown={(event) => handleMenuKeyDown(event, index)}
                    >
                      {item.label}
                    </button>
                  ))}
                </div>
                <div className={styles.menuSummary} aria-live="polite">
                  <h3 className={styles.menuSummaryTitle}>{activeMenu.label}</h3>
                  <p id={`menu-item-desc-${focusIndex}`} className={styles.menuSummaryBody}>
                    {activeMenu.description}
                  </p>
                  <p className={styles.menuHint}>
                    Tip: Use Arrow keys to move between items, Enter or Space to activate, Home and End to jump to the
                    first or last item.
                  </p>
                </div>
              </div>
            </section>

            <section id="feedback-form-demo" className={styles.componentItem} aria-labelledby="feedback-form-title">
              <h2 id="feedback-form-title" className={styles.itemLabel}>
                Accessible Feedback Form
              </h2>
              <p className={styles.itemDesc}>
                Labels, instructions, and inline validation errors are connected to their inputs so screen readers and
                voice control software capture every requirement.
              </p>

              <form
                className={styles.feedbackForm}
                noValidate
                aria-describedby="feedback-form-hint"
                onSubmit={handleFormSubmit}
              >
                <div className={styles.formGroup}>
                  <label htmlFor="name" className={styles.formLabel}>
                    Full name <span aria-hidden="true">*</span>
                  </label>
                  <input
                    id="name"
                    name="name"
                    type="text"
                    className={styles.textInput}
                    required
                    aria-required="true"
                    autoComplete="name"
                    placeholder="Ada Lovelace"
                  />
                </div>

                <div className={styles.formGroup}>
                  <label htmlFor="email" className={styles.formLabel}>
                    Email address <span aria-hidden="true">*</span>
                  </label>
                  <input
                    id="email"
                    name="email"
                    type="email"
                    className={styles.textInput}
                    required
                    aria-required="true"
                    autoComplete="email"
                    placeholder="ada@example.dev"
                    aria-describedby="email-helper"
                  />
                  <p id="email-helper" className={styles.formHint}>
                    We use your address to follow up on accessibility issues. It stays private.
                  </p>
                </div>

                <div className={styles.formGroup}>
                  <label htmlFor="message" className={styles.formLabel}>
                    Describe the issue <span aria-hidden="true">*</span>
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    className={styles.textarea}
                    rows={4}
                    required
                    aria-required="true"
                    placeholder="Tell us what you tried, what happened, and what you expected instead."
                  />
                </div>

                <p id="feedback-form-hint" className={styles.formHint}>
                  Required fields are marked with an asterisk. You can submit the form using Enter from the message field.
                </p>

                {formError && (
                  <div className={styles.errorMessage} role="alert">
                    {formError}
                  </div>
                )}

                {formSubmitted && !formError && (
                  <div className={styles.successMessage} role="status" aria-live="polite">
                    Thank you! We will reach out if we need more details.
                  </div>
                )}

                <button type="submit" className={styles.submitButton}>
                  Submit feedback
                </button>
              </form>
            </section>

            <section className={styles.componentItem} aria-labelledby="faq-toggle-title">
              <h2 id="faq-toggle-title" className={styles.itemLabel}>
                Discernible Expansion Controls
              </h2>
              <p className={styles.itemDesc}>
                Toggle buttons expose or hide supporting context. The control announces its state so users always know
                what happened.
              </p>

              <button
                type="button"
                className={styles.faqToggle}
                aria-expanded={faqExpanded}
                aria-controls="faq-panel"
                onClick={toggleFaq}
              >
                {faqExpanded ? 'Hide' : 'Show'} accessibility FAQ
              </button>
              <div
                id="faq-panel"
                className={`${styles.faqContent} ${faqExpanded ? styles.faqContentVisible : ''}`}
                hidden={!faqExpanded}
              >
                <h3 className={styles.faqTitle}>Why does this matter?</h3>
                <p>
                  Accessible patterns reduce cognitive load, prevent focus traps, and ensure assistive technology conveys
                  everything your visual design promises. Every example on this page works with a keyboard and a screen
                  reader without additional configuration.
                </p>
                <ul className={styles.faqList}>
                  <li>Focus styles remain visible for users who rely on sight and touch.</li>
                  <li>ARIA attributes are only used when semantic HTML is not enough.</li>
                  <li>Live regions announce changes without stealing focus from the user.</li>
                </ul>
              </div>
            </section>
          </div>
          <div
            className={styles.liveRegion}
            role="status"
            aria-live="polite"
            aria-atomic="true"
            aria-label="Accessibility announcements"
          >
            {announcement}
          </div>
        </main>
      </WebFListView>
    </div>
  );
};

export default AccessibilityPage;
