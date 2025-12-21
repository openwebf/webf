// Repro for Tailwind-style gradients where empty custom properties (e.g.
// `--tw-gradient-from-position: ;`) must not contribute a literal ';' token.
// If the parser incorrectly treats the empty value as ';', the resulting
// linear-gradient() becomes invalid and is dropped.
describe('Background Tailwind gradient with empty position vars', () => {
  it('renders bg-gradient-to-tr from-blue-500 to-cyan-400', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .bg-gradient-to-tr {
        background-image: linear-gradient(to top right, var(--tw-gradient-stops));
      }

      /* Tailwind sets these "position" vars to empty by default. */
      .from-blue-500, .to-cyan-400 {
        --tw-gradient-from-position: ;
        --tw-gradient-to-position: ;
      }

      .from-blue-500 {
        --tw-gradient-from: #3b82f6 var(--tw-gradient-from-position);
        --tw-gradient-to: rgb(59 130 246 / 0) var(--tw-gradient-to-position);
        --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to);
      }

      .to-cyan-400 {
        --tw-gradient-to: #22d3ee var(--tw-gradient-to-position);
      }
    `;
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.className = 'bg-gradient-to-tr from-blue-500 to-cyan-400';
    Object.assign(div.style, {
      width: '200px',
      height: '100px',
      borderRadius: '16px',
    } as any);
    document.body.appendChild(div);

    await waitForFrame();

    const computedBg = getComputedStyle(div).backgroundImage || '';
    // A correct implementation must not leak ';' from empty custom properties into the computed gradient.
    expect(computedBg.includes(';')).toBe(false);
    expect(computedBg).not.toBe('none');

    await snapshot(div);
  });
});

