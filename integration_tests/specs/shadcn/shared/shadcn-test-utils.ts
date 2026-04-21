import React from 'react';
import styles from './shadcn-component.css';

export type FlushFn = (frames?: number) => Promise<void>;
export type VerifyFn = (container: HTMLElement, flush: FlushFn) => Promise<void> | void;

export async function waitForText(
  container: HTMLElement,
  expectedText: string,
  flush: FlushFn,
  attempts = 24,
  framesPerAttempt = 1,
): Promise<void> {
  for (let i = 0; i < attempts; i += 1) {
    if (container.textContent?.includes(expectedText)) {
      return;
    }

    await flush(framesPerAttempt);
  }

  throw new Error(`Expected text "${expectedText}" was not rendered.`);
}

export function findButtonByText(
  container: HTMLElement,
  text: string,
): HTMLButtonElement | undefined {
  return Array.from(container.querySelectorAll('button')).find(
    (node) => node.textContent?.trim() === text,
  ) as HTMLButtonElement | undefined;
}

export function findButtonContainingText(
  container: HTMLElement,
  text: string,
): HTMLButtonElement | undefined {
  return Array.from(container.querySelectorAll('button')).find((node) =>
    node.textContent?.includes(text),
  ) as HTMLButtonElement | undefined;
}

export async function clickButtonByText(
  container: HTMLElement,
  flush: FlushFn,
  text: string,
): Promise<HTMLButtonElement> {
  await flush(1);
  const button = findButtonByText(container, text);

  if (!button) {
    throw new Error(`Unable to find button with text "${text}".`);
  }

  button.click();
  await flush(2);
  return button;
}

export async function clickButtonContainingText(
  container: HTMLElement,
  flush: FlushFn,
  text: string,
): Promise<HTMLButtonElement> {
  await flush(1);
  const button = findButtonContainingText(container, text);

  if (!button) {
    throw new Error(`Unable to find button containing text "${text}".`);
  }

  button.click();
  await flush(2);
  return button;
}

export async function runShadcnCase(
  element: React.ReactElement,
  expectedTexts: string[],
  verify?: VerifyFn,
  framesToWait = 8,
) {
  styles.use();

  try {
    await resizeViewport(430, 1200);

    await withReactSpec(
      element,
      async ({ container, flush }) => {
        await flush(framesToWait);

        for (const text of expectedTexts) {
          await waitForText(container, text, flush);
        }

        await verify?.(container, flush);
      },
      {
        containerStyle: {
          width: '100%',
        },
        framesToWait: 4,
      },
    );
  } finally {
    styles.unuse();
    await resizeViewport(-1, -1);
  }
}
