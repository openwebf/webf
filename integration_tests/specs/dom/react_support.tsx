/** @jsxImportSource react */
import React from 'react';
import styles from './react_support.css';

type CounterScenario = {
  key: string;
  name: string;
  description: string;
  increments: number;
  initialCount?: number;
  buttonLabel?: string;
};

const scenarios: CounterScenario[] = [
  {
    key: 'single',
    name: 'renders a Tailwind-styled React component and responds to interactions',
    description: 'Single click updates the counter and validates Tailwind styling works in React.',
    increments: 1,
    buttonLabel: 'Increment',
  },
  {
    key: 'multiple',
    name: 'handles multiple increments and a custom starting count',
    description: 'Demonstrates repeated state updates with Tailwind-styled UI elements.',
    increments: 3,
    initialCount: 2,
    buttonLabel: 'Add +1',
  },
];

const TailwindCounter = ({ scenario }: { scenario: CounterScenario }) => {
  const { description, key, buttonLabel = 'Increment', initialCount = 0 } = scenario;
  const [count, setCount] = React.useState(initialCount);
  const incrementTestId = `increment-${key}`;
  const countTestId = `count-${key}`;

  return (
    <div className="react-spec-container">
      <section className="react-card">
        <header className="flex flex-col gap-1">
          <span className="text-xs uppercase tracking-wide text-emerald-100">Tailwind + React</span>
          <h1 className="text-2xl font-semibold">Counter Example</h1>
        </header>
        <p className="text-emerald-50/80 text-sm">{description}</p>
        <div className="flex items-center gap-3">
          <button
            type="button"
            className="react-button"
            data-testid={incrementTestId}
            onClick={() => setCount((value) => value + 1)}
          >
            {buttonLabel}
          </button>
          <span className="text-lg font-semibold tabular-nums" data-testid={countTestId}>
            {count}
          </span>
        </div>
      </section>
    </div>
  );
};

async function waitForElement<T extends Element>(
  container: HTMLElement,
  selector: string,
  flush: (frames?: number) => Promise<void>,
  attempts = 8,
  framesPerAttempt = 1,
): Promise<T> {
  for (let i = 0; i < attempts; i += 1) {
    const node = container.querySelector(selector) as T | null;
    if (node) return node;
    await flush(framesPerAttempt);
  }
  throw new Error(`Element matching selector "${selector}" was not found within ${attempts} attempts.`);
}

// Validates Tailwind CSS support within React-rendered specs across multiple scenarios.
describe('React integration', () => {
  scenarios.forEach((scenario) => {
    it(scenario.name, async () => {
      const expectedCount = (scenario.initialCount ?? 0) + scenario.increments;
      const incrementSelector = `[data-testid="increment-${scenario.key}"]`;
      const countSelector = `[data-testid="count-${scenario.key}"]`;

      styles.use();

      try {
        await withReactSpec(
          <TailwindCounter scenario={scenario} />,
          async ({ container, flush }) => {
            const increment = await waitForElement<HTMLButtonElement>(container, incrementSelector, flush);

            for (let i = 0; i < scenario.increments; i += 1) {
              increment.click();
              await flush(2);
            }

            await flush(2);
            const countLabel = await waitForElement<HTMLSpanElement>(container, countSelector, flush);
            expect(countLabel.textContent).toBe(String(expectedCount));

            await snapshot();
          },
          {
            containerId: `react-spec-container-${scenario.key}`,
            framesToWait: 2,
          },
        );
      } finally {
        styles.unuse();
      }
    });
  });
});
