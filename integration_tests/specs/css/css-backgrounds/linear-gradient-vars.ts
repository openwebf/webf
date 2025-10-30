// Verifies var() expansion in gradient stop lists (Tailwind-style)
describe('Background linear-gradient with CSS vars', () => {
  it('expands var(--tw-gradient-stops) into colors', async () => {
    const div = document.createElement('div');
    // Regular styles
    Object.assign(div.style, {
      width: '96px',
      height: '96px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: '#fff',
      borderRadius: '8px',
    } as any);
    // Tailwind-style CSS variables must be set via setProperty
    div.style.setProperty('--tw-gradient-from', '#6366f1 var(--tw-gradient-from-position)');
    div.style.setProperty('--tw-gradient-to', '#9333ea var(--tw-gradient-to-position)');
    div.style.setProperty('--tw-gradient-stops', 'var(--tw-gradient-from), var(--tw-gradient-to)');
    div.style.backgroundImage = 'linear-gradient(to bottom right, var(--tw-gradient-stops))';
    div.appendChild(document.createTextNode('Fade'));
    append(BODY, div);
    await snapshot(div);
  });

  it('updates when CSS var changes', async (done) => {
    const div = document.createElement('div');
    Object.assign(div.style, {
      width: '96px',
      height: '96px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: '#fff',
      borderRadius: '8px',
    } as any);
    div.style.setProperty('--tw-gradient-from', '#6366f1 var(--tw-gradient-from-position)');
    div.style.setProperty('--tw-gradient-to', '#9333ea var(--tw-gradient-to-position)');
    div.style.setProperty('--tw-gradient-stops', 'var(--tw-gradient-from), var(--tw-gradient-to)');
    div.style.backgroundImage = 'linear-gradient(to bottom right, var(--tw-gradient-stops))';
    div.appendChild(document.createTextNode('Fade'));
    append(BODY, div);
    await snapshot(div);

    requestAnimationFrame(async () => {
      // Change the destination color via var, gradient should update
      div.style.setProperty('--tw-gradient-to', '#ef4444 var(--tw-gradient-to-position)'); // red-500
      await snapshot(div);
      done();
    });
  });
});
