// Basic ARIA attribute reflection and presence tests.

describe('Accessibility: ARIA attributes reflection', () => {
  // Test ARIA attributes
  it('should support aria-label', async (done) => {
    const button = document.createElement('button');
    button.setAttribute('aria-label', 'Close dialog');
    button.textContent = 'X';
    document.body.appendChild(button);

    expect(button.getAttribute('aria-label')).toBe('Close dialog');
    done();
  });

  it('should support aria-labelledby', async (done) => {
    const label = document.createElement('div');
    label.id = 'my-label';
    label.textContent = 'Email Address';
    document.body.appendChild(label);

    // Use a generic element here; input-specific case is tested separately.
    const target = document.createElement('div');
    target.setAttribute('aria-labelledby', 'my-label');
    document.body.appendChild(target);

    expect(target.getAttribute('aria-labelledby')).toBe('my-label');
    done();
  });

  it('should support aria-describedby', async (done) => {
    const description = document.createElement('div');
    description.id = 'password-help';
    description.textContent = 'Password must be at least 8 characters';
    document.body.appendChild(description);

    // Use a generic element here; input-specific case is tested separately.
    const target = document.createElement('div');
    target.setAttribute('aria-describedby', 'password-help');
    document.body.appendChild(target);

    expect(target.getAttribute('aria-describedby')).toBe('password-help');
    done();
  });

  it('should support role attribute', async (done) => {
    const nav = document.createElement('div');
    nav.setAttribute('role', 'navigation');
    document.body.appendChild(nav);

    expect(nav.getAttribute('role')).toBe('navigation');
    done();
  });

  it('should support alt attribute on images', async (done) => {
    const img = document.createElement('img');
    img.src = 'assets/100x100-green.png';
    img.setAttribute('alt', 'A green square');
    document.body.appendChild(img);

    onImageLoad(img, async () => {
      expect(img.alt).toBe('A green square');
      expect(img.getAttribute('alt')).toBe('A green square');
      done();
    });
  });

  it('should support aria-hidden', async (done) => {
    const decorative = document.createElement('span');
    decorative.setAttribute('aria-hidden', 'true');
    decorative.textContent = '🎨'; // Decorative emoji
    document.body.appendChild(decorative);

    expect(decorative.getAttribute('aria-hidden')).toBe('true');
    done();
  });

  it('should support aria-disabled', async (done) => {
    const button = document.createElement('button');
    button.setAttribute('aria-disabled', 'true');
    button.textContent = 'Submit';
    document.body.appendChild(button);

    expect(button.getAttribute('aria-disabled')).toBe('true');
    done();
  });

  it('should support aria-checked', async (done) => {
    const checkbox = document.createElement('div');
    checkbox.setAttribute('role', 'checkbox');
    checkbox.setAttribute('aria-checked', 'false');
    document.body.appendChild(checkbox);

    expect(checkbox.getAttribute('aria-checked')).toBe('false');

    // Update to checked
    checkbox.setAttribute('aria-checked', 'true');
    expect(checkbox.getAttribute('aria-checked')).toBe('true');

    // Mixed state
    checkbox.setAttribute('aria-checked', 'mixed');
    expect(checkbox.getAttribute('aria-checked')).toBe('mixed');

    done();
  });

  it('should support aria-expanded', async (done) => {
    const button = document.createElement('button');
    button.setAttribute('aria-expanded', 'false');
    button.textContent = 'Show more';
    document.body.appendChild(button);

    expect(button.getAttribute('aria-expanded')).toBe('false');

    // Expand
    button.setAttribute('aria-expanded', 'true');
    expect(button.getAttribute('aria-expanded')).toBe('true');

    done();
  });

  // Live regions
  it('should support aria-live', async (done) => {
    const status = document.createElement('div');
    status.setAttribute('role', 'status');
    status.setAttribute('aria-live', 'polite');
    document.body.appendChild(status);

    expect(status.getAttribute('aria-live')).toBe('polite');

    // Update content - would be announced by screen readers
    status.textContent = 'Form saved successfully';

    done();
  });

  it('should support assertive live regions', async (done) => {
    const alert = document.createElement('div');
    alert.setAttribute('role', 'alert');
    alert.setAttribute('aria-live', 'assertive');
    document.body.appendChild(alert);

    expect(alert.getAttribute('aria-live')).toBe('assertive');

    // Critical update - would interrupt screen reader
    alert.textContent = 'Error: Invalid input';

    done();
  });

  it('should support aria-atomic for live regions', async (done) => {
    const region = document.createElement('div');
    region.setAttribute('aria-live', 'polite');
    region.setAttribute('aria-atomic', 'true');
    document.body.appendChild(region);

    expect(region.getAttribute('aria-atomic')).toBe('true');
    done();
  });

  it('should support aria-relevant for live regions', async (done) => {
    const log = document.createElement('div');
    log.setAttribute('role', 'log');
    log.setAttribute('aria-live', 'polite');
    log.setAttribute('aria-relevant', 'additions');
    document.body.appendChild(log);

    expect(log.getAttribute('aria-relevant')).toBe('additions');
    done();
  });

  // Form accessibility
  it('should support aria-required', async (done) => {
    const input = document.createElement('input');
    input.setAttribute('aria-required', 'true');
    input.setAttribute('aria-label', 'Email address');
    document.body.appendChild(input);

    expect(input.getAttribute('aria-required')).toBe('true');
    done();
  });

  it('should support aria-invalid', async (done) => {
    const input = document.createElement('input');
    input.setAttribute('aria-invalid', 'true');
    input.setAttribute('aria-describedby', 'email-error');
    document.body.appendChild(input);

    const error = document.createElement('div');
    error.id = 'email-error';
    error.textContent = 'Please enter a valid email address';
    document.body.appendChild(error);

    expect(input.getAttribute('aria-invalid')).toBe('true');
    done();
  });

  it('should support aria-labelledby on input with placeholder', async (done) => {
    const label = document.createElement('div');
    label.id = 'my-label';
    label.textContent = 'Email Address';
    // Optional CSS: label could be hidden and still serve as an accessible name source
    label.style.display = 'block';
    document.body.appendChild(label);

    const input = document.createElement('input');
    input.placeholder = 'enter email';
    input.setAttribute('aria-labelledby', 'my-label');
    document.body.appendChild(input);

    expect(input.getAttribute('aria-labelledby')).toBe('my-label');
    expect(input.getAttribute('placeholder')).toBe('enter email');
    done();
  });

  it('should support aria-describedby on input', async (done) => {
    const help = document.createElement('div');
    help.id = 'email-help';
    help.textContent = 'We will not share your email.';
    document.body.appendChild(help);

    const input = document.createElement('input');
    input.setAttribute('aria-describedby', 'email-help');
    document.body.appendChild(input);

    expect(input.getAttribute('aria-describedby')).toBe('email-help');
    done();
  });

  it('should support multiple aria-labelledby ids on input', async (done) => {
    const l1 = document.createElement('div');
    l1.id = 'l1';
    l1.textContent = 'Email';
    const l2 = document.createElement('div');
    l2.id = 'l2';
    l2.textContent = 'Address';
    document.body.appendChild(l1);
    document.body.appendChild(l2);

    const input = document.createElement('input');
    input.setAttribute('aria-labelledby', 'l1 l2');
    document.body.appendChild(input);

    expect(input.getAttribute('aria-labelledby')).toBe('l1 l2');
    done();
  });

  it('should reflect aria-pressed on toggle button', async (done) => {
    const btn = document.createElement('button');
    btn.setAttribute('aria-pressed', 'false');
    document.body.appendChild(btn);
    expect(btn.getAttribute('aria-pressed')).toBe('false');
    btn.setAttribute('aria-pressed', 'mixed');
    expect(btn.getAttribute('aria-pressed')).toBe('mixed');
    btn.setAttribute('aria-pressed', 'true');
    expect(btn.getAttribute('aria-pressed')).toBe('true');
    done();
  });

  it('should allow hidden label used by aria-labelledby', async (done) => {
    const label = document.createElement('div');
    label.id = 'hidden-label';
    label.textContent = 'Hidden Email Label';
    label.style.display = 'none';
    document.body.appendChild(label);

    const input = document.createElement('input');
    input.placeholder = 'enter email';
    input.setAttribute('aria-labelledby', 'hidden-label');
    document.body.appendChild(input);

    expect(input.getAttribute('aria-labelledby')).toBe('hidden-label');
    expect(input.getAttribute('placeholder')).toBe('enter email');
    done();
  });

  it('should support aria-readonly on input', async (done) => {
    const input = document.createElement('input');
    input.setAttribute('aria-readonly', 'true');
    document.body.appendChild(input);
    expect(input.getAttribute('aria-readonly')).toBe('true');
    done();
  });

  it('should update aria-labelledby dynamically', async (done) => {
    const l1 = document.createElement('div');
    l1.id = 'dyn-l1';
    l1.textContent = 'First';
    const l2 = document.createElement('div');
    l2.id = 'dyn-l2';
    l2.textContent = 'Second';
    document.body.appendChild(l1);
    document.body.appendChild(l2);

    const input = document.createElement('input');
    input.setAttribute('aria-labelledby', 'dyn-l1');
    document.body.appendChild(input);
    expect(input.getAttribute('aria-labelledby')).toBe('dyn-l1');

    input.setAttribute('aria-labelledby', 'dyn-l2');
    expect(input.getAttribute('aria-labelledby')).toBe('dyn-l2');
    done();
  });

  it('should reflect empty alt on images', async (done) => {
    const img = document.createElement('img');
    img.src = 'assets/100x100-green.png';
    img.setAttribute('alt', '');
    document.body.appendChild(img);
    onImageLoad(img, async () => {
      expect(img.getAttribute('alt')).toBe('');
      done();
    });
  });

  // Navigation
  it('should support aria-current', async (done) => {
    const nav = document.createElement('nav');
    const link1 = document.createElement('a');
    link1.href = '/home';
    link1.textContent = 'Home';
    link1.setAttribute('aria-current', 'page');

    const link2 = document.createElement('a');
    link2.href = '/about';
    link2.textContent = 'About';

    nav.appendChild(link1);
    nav.appendChild(link2);
    document.body.appendChild(nav);

    expect(link1.getAttribute('aria-current')).toBe('page');
    expect(link2.getAttribute('aria-current')).toBeNull();
    done();
  });

  // Complex widgets (attribute reflection only)
  it('should support slider accessibility', async (done) => {
    const slider = document.createElement('div');
    slider.setAttribute('role', 'slider');
    slider.setAttribute('aria-valuemin', '0');
    slider.setAttribute('aria-valuemax', '100');
    slider.setAttribute('aria-valuenow', '50');
    slider.setAttribute('aria-label', 'Volume');
    document.body.appendChild(slider);

    expect(slider.getAttribute('aria-valuenow')).toBe('50');

    // Update value
    slider.setAttribute('aria-valuenow', '75');
    expect(slider.getAttribute('aria-valuenow')).toBe('75');

    done();
  });

  it('should support tabpanel accessibility', async (done) => {
    const tablist = document.createElement('div');
    tablist.setAttribute('role', 'tablist');

    const tab1 = document.createElement('button');
    tab1.setAttribute('role', 'tab');
    tab1.setAttribute('aria-selected', 'true');
    tab1.setAttribute('aria-controls', 'panel1');
    tab1.textContent = 'Tab 1';

    const tab2 = document.createElement('button');
    tab2.setAttribute('role', 'tab');
    tab2.setAttribute('aria-selected', 'false');
    tab2.setAttribute('aria-controls', 'panel2');
    tab2.textContent = 'Tab 2';

    tablist.appendChild(tab1);
    tablist.appendChild(tab2);
    document.body.appendChild(tablist);

    const panel1 = document.createElement('div');
    panel1.id = 'panel1';
    panel1.setAttribute('role', 'tabpanel');
    panel1.setAttribute('aria-labelledby', tab1.id);
    panel1.textContent = 'Panel 1 content';
    document.body.appendChild(panel1);

    const panel2 = document.createElement('div');
    panel2.id = 'panel2';
    panel2.setAttribute('role', 'tabpanel');
    panel2.setAttribute('aria-labelledby', tab2.id);
    panel2.setAttribute('aria-hidden', 'true');
    panel2.textContent = 'Panel 2 content';
    document.body.appendChild(panel2);

    expect(tab1.getAttribute('aria-selected')).toBe('true');
    expect(tab2.getAttribute('aria-selected')).toBe('false');
    expect(panel2.getAttribute('aria-hidden')).toBe('true');

    done();
  });


  // Extract standalone input element as its own case to validate
  // behavior without any associated label node present.
  it('should support standalone input element', async (done) => {
    const input = document.createElement('input');
    input.id = 'usernameID';
    input.name = 'username';
    input.autocomplete = 'username';
    input.placeholder = 'Enter username';
    document.body.appendChild(input);

    // Basic reflections
    expect(input.tagName.toLowerCase()).toBe('input');
    expect(input.getAttribute('id')).toBe('usernameID');
    expect(input.getAttribute('name')).toBe('username');
    expect(input.getAttribute('autocomplete')).toBe('username');
    expect(input.getAttribute('placeholder')).toBe('Enter username');
    done();
  });
});
