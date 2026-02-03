/**
 * CSS Selectors: :has() with display states and special pseudo-classes
 * Based on WPT: css/selectors/has-display-none-checked.html, has-matches-to-uninserted-elements.html
 *
 * Key behaviors:
 * - :has() works with elements inside display:none subtrees
 * - :has() matches work on uninserted (not in DOM) elements
 * - :has() with :valid/:invalid form validation states
 */
describe('CSS Selectors: :has() with display:none subtrees', () => {
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('A1 :has(:checked) works inside display:none subtree', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div style="display: none">
        <input type="checkbox" id="hidden-checkbox">
      </div>
      <div id="fail">FAIL</div>
      <div id="pass" style="display: none">PASS</div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      body:has(#hidden-checkbox:checked) #fail { display: none; }
      body:has(#hidden-checkbox:checked) #pass { display: block !important; }
    `);

    const checkbox = container.querySelector('#hidden-checkbox') as HTMLInputElement;
    const fail = container.querySelector('#fail')!;
    const pass = container.querySelector('#pass')!;

    await waitForFrame();
    console.log('A1 debug connected:', document.documentElement?.isConnected, document.body?.isConnected);

    // Initially unchecked
    expect(getComputedStyle(fail).display).not.toBe('none');
    expect(getComputedStyle(pass).display).toBe('none');

    // Check the hidden checkbox
    checkbox.checked = true;
    await waitForFrame();

    console.log('A1 debug checked:', checkbox.checked, 'attr:', checkbox.hasAttribute('checked'));
    console.log('A1 debug body:has:', document.body.matches('body:has(#hidden-checkbox:checked)'));
    console.log(
      'A1 debug query:',
      document.querySelectorAll('body:has(#hidden-checkbox:checked) #fail').length
    );

    // Now :has(:checked) should match
    expect(getComputedStyle(fail).display).toBe('none');
    expect(getComputedStyle(pass).display).toBe('block');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A2 :not(:has(:checked)) inverse logic', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div style="display: none">
        <input type="checkbox" id="cb">
      </div>
      <div id="indicator" class="unchecked"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      body:not(:has(#cb:checked)) #indicator { background: red; }
      body:has(#cb:checked) #indicator { background: green; }
    `);

    const checkbox = container.querySelector('#cb') as HTMLInputElement;
    const indicator = container.querySelector('#indicator')!;
    const grey = 'rgb(128, 128, 128)';

    await waitForFrame();

    // Initially unchecked -> :not(:has(:checked)) matches
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    checkbox.checked = true;
    await waitForFrame();
    expect(getComputedStyle(indicator).backgroundColor).toBe(green);

    await snapshot();

    checkbox.checked = false;
    await waitForFrame();
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    style.remove();
    container.remove();
  });

  it('A3 Multiple hidden checkboxes', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div style="display: none">
        <input type="checkbox" id="cb1">
        <input type="checkbox" id="cb2">
      </div>
      <div id="indicator"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      body:has(#cb1:checked) #indicator { background: red; }
      body:has(#cb2:checked) #indicator { background: green; }
      body:has(#cb1:checked):has(#cb2:checked) #indicator { background: blue; }
    `);

    const cb1 = container.querySelector('#cb1') as HTMLInputElement;
    const cb2 = container.querySelector('#cb2') as HTMLInputElement;
    const indicator = container.querySelector('#indicator')!;
    const grey = 'rgb(128, 128, 128)';
    const red = 'rgb(255, 0, 0)';
    const green = 'rgb(0, 128, 0)';
    const blue = 'rgb(0, 0, 255)';

    await waitForFrame();

    expect(getComputedStyle(indicator).backgroundColor).toBe(grey);

    cb1.checked = true;
    await waitForFrame();
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    cb2.checked = true;
    await waitForFrame();
    expect(getComputedStyle(indicator).backgroundColor).toBe(blue);

    cb1.checked = false;
    await waitForFrame();
    expect(getComputedStyle(indicator).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() matches on uninserted elements', () => {
  it('B1 :has(child) matches uninserted element with child', async () => {
    const subject = document.createElement('div');
    subject.innerHTML = '<span class="child"></span>';

    expect(subject.matches(':has(.child)')).toBe(true);
    expect(subject.matches(':has(> .child)')).toBe(true);

    await snapshot();
  });

  it('B2 :has(descendant) matches with nested structure', async () => {
    const subject = document.createElement('div');
    subject.innerHTML = '<div class="wrapper"><span class="descendant"></span></div>';

    expect(subject.matches(':has(.descendant)')).toBe(true);
    expect(subject.matches(':has(> .descendant)')).toBe(false); // Not direct child

    await snapshot();
  });

  it('B3 :has(~ sibling) on uninserted element children', async () => {
    const subject = document.createElement('div');
    subject.innerHTML = '<span class="first"></span><span class="direct"></span><span class="indirect"></span>';

    const firstChild = subject.firstElementChild!;

    expect(firstChild.matches(':has(~ .direct)')).toBe(true);
    expect(firstChild.matches(':has(+ .direct)')).toBe(true);
    expect(firstChild.matches(':has(~ .indirect)')).toBe(true);
    expect(firstChild.matches(':has(+ .indirect)')).toBe(false); // Not adjacent

    await snapshot();
  });

  it('B4 :has(*) universal selector on uninserted', async () => {
    const subject = document.createElement('div');
    subject.innerHTML = '<span></span><div></div><p></p>';

    expect(subject.matches(':has(*)')).toBe(true);
    expect(subject.matches(':has(> *)')).toBe(true);
    expect(subject.matches(':has(~ *)')).toBe(false); // No siblings
    expect(subject.matches(':has(+ *)')).toBe(false); // No siblings

    await snapshot();
  });

  it('B5 Empty element does not match :has(*)', async () => {
    const subject = document.createElement('div');

    expect(subject.matches(':has(*)')).toBe(false);
    expect(subject.matches(':has(> *)')).toBe(false);

    await snapshot();
  });

  it('B6 :has() with complex selectors on uninserted', async () => {
    const subject = document.createElement('div');
    subject.innerHTML = `
      <div class="a">
        <span class="b"></span>
      </div>
    `;

    expect(subject.matches(':has(.a .b)')).toBe(true);
    expect(subject.matches(':has(.a > .b)')).toBe(true);
    expect(subject.matches(':has(> .a > .b)')).toBe(true);
    expect(subject.matches(':has(.b > .a)')).toBe(false); // Wrong order

    await snapshot();
  });
});

describe('CSS Selectors: :has() with form validation pseudo-classes', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';
  const yellow = 'rgb(255, 255, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 :has(:valid) with required input', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="form-wrapper">
        <input type="text" id="input" required>
      </div>
      <div id="indicator"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      #form-wrapper:has(:valid) ~ #indicator { background: green; }
      #form-wrapper:has(:invalid) ~ #indicator { background: red; }
    `);

    const input = container.querySelector('#input') as HTMLInputElement;
    const indicator = container.querySelector('#indicator')!;

    // Initially empty and required -> invalid
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    // Add value -> valid
    input.value = 'test';
    expect(getComputedStyle(indicator).backgroundColor).toBe(green);

    await snapshot();

    // Clear value -> invalid again
    input.value = '';
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    style.remove();
    container.remove();
  });

  it('C2 :not(:has(:invalid)) form validation', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="form-wrapper">
        <input type="email" id="email" value="invalid">
      </div>
      <div id="indicator"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      #form-wrapper:not(:has(:invalid)) ~ #indicator { background: green; }
    `);

    const email = container.querySelector('#email') as HTMLInputElement;
    const indicator = container.querySelector('#indicator')!;

    // "invalid" is not a valid email -> :invalid matches
    expect(getComputedStyle(indicator).backgroundColor).toBe(grey);

    // Valid email
    email.value = 'test@example.com';
    expect(getComputedStyle(indicator).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C3 :has(:checked) with radio buttons', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="radio-group">
        <input type="radio" name="choice" id="r1" value="1">
        <input type="radio" name="choice" id="r2" value="2">
        <input type="radio" name="choice" id="r3" value="3">
      </div>
      <div id="indicator"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      #radio-group:has(#r1:checked) ~ #indicator { background: red; }
      #radio-group:has(#r2:checked) ~ #indicator { background: green; }
      #radio-group:has(#r3:checked) ~ #indicator { background: blue; }
    `);

    const r1 = container.querySelector('#r1') as HTMLInputElement;
    const r2 = container.querySelector('#r2') as HTMLInputElement;
    const r3 = container.querySelector('#r3') as HTMLInputElement;
    const indicator = container.querySelector('#indicator')!;
    const grey = 'rgb(128, 128, 128)';
    const red = 'rgb(255, 0, 0)';
    const green = 'rgb(0, 128, 0)';
    const blue = 'rgb(0, 0, 255)';

    expect(getComputedStyle(indicator).backgroundColor).toBe(grey);

    r1.checked = true;
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    r2.checked = true;
    expect(getComputedStyle(indicator).backgroundColor).toBe(green);

    r3.checked = true;
    expect(getComputedStyle(indicator).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C4 :has(:disabled) with optgroup', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="select-wrapper">
        <select id="select">
          <optgroup id="optgroup" label="Group">
            <option>Option 1</option>
            <option>Option 2</option>
          </optgroup>
        </select>
      </div>
      <div id="indicator"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      #select-wrapper:has(#optgroup:disabled) ~ #indicator { background: red; }
    `);

    const optgroup = container.querySelector('#optgroup') as HTMLOptGroupElement;
    const indicator = container.querySelector('#indicator')!;
    const grey = 'rgb(128, 128, 128)';
    const red = 'rgb(255, 0, 0)';

    expect(getComputedStyle(indicator).backgroundColor).toBe(grey);

    optgroup.disabled = true;
    await waitForFrame();
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    await snapshot();

    optgroup.disabled = false;
    await waitForFrame();
    expect(getComputedStyle(indicator).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() with select/option elements', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('D1 :has(option:checked) with select', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="wrapper">
        <select id="select">
          <option id="opt1" value="1">Option 1</option>
          <option id="opt2" value="2">Option 2</option>
        </select>
      </div>
      <div id="indicator"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      #wrapper:has(#opt1:checked) ~ #indicator { background: red; }
      #wrapper:has(#opt2:checked) ~ #indicator { background: green; }
    `);

    const select = container.querySelector('#select') as HTMLSelectElement;
    const opt1 = container.querySelector('#opt1') as HTMLOptionElement;
    const opt2 = container.querySelector('#opt2') as HTMLOptionElement;
    const indicator = container.querySelector('#indicator')!;

    // First option is selected by default
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    opt2.selected = true;
    expect(getComputedStyle(indicator).backgroundColor).toBe(green);

    await snapshot();

    opt1.selected = true;
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    style.remove();
    container.remove();
  });

  it('D2 :has(option:disabled)', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="wrapper">
        <select>
          <option id="opt">Option</option>
        </select>
      </div>
      <div id="indicator"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #indicator { width: 80px; height: 30px; background: grey; }
      #wrapper:has(#opt:disabled) ~ #indicator { background: red; }
    `);

    const opt = container.querySelector('#opt') as HTMLOptionElement;
    const indicator = container.querySelector('#indicator')!;
    const grey = 'rgb(128, 128, 128)';
    const red = 'rgb(255, 0, 0)';

    expect(getComputedStyle(indicator).backgroundColor).toBe(grey);

    opt.disabled = true;
    expect(getComputedStyle(indicator).backgroundColor).toBe(red);

    await snapshot();

    style.remove();
    container.remove();
  });
});
