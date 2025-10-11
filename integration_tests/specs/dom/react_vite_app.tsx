/** @jsxImportSource react */
import React, { useState } from 'react';
import styles from './react_vite_app.css';

function App() {
  const [count, setCount] = useState(0);
  return (
    <>
      <div>
        <a href="https://vite.dev" target="_blank">
          {/* Using existing assets to mimic Vite logo */}
          <img src="assets/100x100-blue-and-orange.png" className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          {/* Using existing assets to mimic React logo */}
          <img src="assets/100x100-green.png" className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <button onClick={() => setCount((c) => c + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  );
}

describe('React Vite App', () => {
  it('renders logos, updates count, and centers inline-block with text-align:center', async () => {
    styles.use();
    try {
      await withReactSpec(
        <App />,
        async ({ container, flush }) => {
          // Match Vite template which styles #root
          container.id = 'root';

          await flush(2);

          const h1 = container.querySelector('h1');
          const p = container.querySelector('p.read-the-docs');
          const logos = container.querySelectorAll('img.logo');
          const reactLogo = container.querySelector('img.logo.react');
          const button = container.querySelector('button') as HTMLButtonElement | null;

          expect(h1?.textContent).toBe('Vite + React');
          expect(p?.textContent).toContain('Click on the Vite and React logos');
          expect(logos.length).toBe(2);
          expect(reactLogo).not.toBeNull();

          // Validate computed styles
          const csContainer = getComputedStyle(container);
          expect(csContainer.textAlign).toBe('center');

          // Button present and initial label correct
          expect(button).not.toBeNull();
          expect(button!.textContent).toContain('count is 0');

          // Geometric centering check: within ~2px tolerance
          const containerRect = container.getBoundingClientRect();
          const buttonRect = button!.getBoundingClientRect();
          const expectedLeft = containerRect.left + (containerRect.width - buttonRect.width) / 2;
          expect(Math.abs(buttonRect.left - expectedLeft)).toBeLessThanOrEqual(2);

          // Verify counter increments update label
          button!.click();
          await flush(4);
          expect(button!.textContent).toContain('count is 1');
          button!.click();
          await flush(4);
          expect(button!.textContent).toContain('count is 2');

          await snapshot();
        },
        { framesToWait: 2 },
      );
    } finally {
      styles.unuse();
    }
  });
});
