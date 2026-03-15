/** @jsxImportSource react */
import type { ReactElement } from 'react';
import { cn } from './cn';

type ReactHandle = {
  container: HTMLElement;
  flush: (frames?: number) => Promise<void>;
  rerender: (element: ReactElement, options?: { framesToWait?: number }) => Promise<void>;
};

type ShadcnSpecOptions = {
  framesToWait?: number;
  containerClassName?: string;
  width?: number | string;
  minHeight?: number | string;
};

export type ShadcnSpecHandle = ReactHandle & {
  clickCenter: (element: Element) => Promise<void>;
  pressKey: (target: EventTarget, key: string, init?: KeyboardEventInit) => Promise<void>;
  waitForFrames: (frames?: number) => Promise<void>;
  waitForSelector: <T extends Element>(
    selector: string,
    attempts?: number,
    framesPerAttempt?: number,
  ) => Promise<T>;
};

declare global {
  // eslint-disable-next-line no-var
  var nextFrames: ((frames?: number) => Promise<void>) | undefined;
  // eslint-disable-next-line no-var
  var simulateClick: ((x: number, y: number, pointer?: number) => Promise<void>) | undefined;
  // eslint-disable-next-line no-var
  var withReactSpec:
    | ((element: ReactElement, testFn: (handle: ReactHandle) => unknown | Promise<unknown>, options?: { framesToWait?: number }) => Promise<void>)
    | undefined;
}

export async function waitForFrames(frames: number = 1): Promise<void> {
  if (typeof globalThis.nextFrames === 'function') {
    await globalThis.nextFrames(frames);
    return;
  }
  await new Promise((resolve) => requestAnimationFrame(() => resolve(undefined)));
}

export async function pressKey(
  target: EventTarget,
  key: string,
  init: KeyboardEventInit = {},
): Promise<void> {
  target.dispatchEvent(
    new KeyboardEvent('keydown', {
      bubbles: true,
      cancelable: true,
      key,
      ...init,
    }),
  );
  await waitForFrames(1);
  target.dispatchEvent(
    new KeyboardEvent('keyup', {
      bubbles: true,
      cancelable: true,
      key,
      ...init,
    }),
  );
  await waitForFrames(1);
}

export async function clickCenter(element: Element): Promise<void> {
  if (typeof globalThis.simulateClick !== 'function') {
    throw new Error('simulateClick is not available in the integration runtime.');
  }

  const rect = element.getBoundingClientRect();
  const x = rect.left + rect.width / 2;
  const y = rect.top + rect.height / 2;
  await globalThis.simulateClick(x, y);
  await waitForFrames(2);
}

async function waitForSelectorInContainer<T extends Element>(
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

  throw new Error(`Element matching selector "${selector}" was not found.`);
}

export async function withShadcnSpec(
  element: ReactElement,
  testFn: (handle: ShadcnSpecHandle) => unknown | Promise<unknown>,
  options: ShadcnSpecOptions = {},
): Promise<void> {
  if (typeof globalThis.withReactSpec !== 'function') {
    throw new Error('withReactSpec is not available in the integration runtime.');
  }

  const framesToWait = options.framesToWait ?? 2;

  await globalThis.withReactSpec(
    element,
    async (handle) => {
      handle.container.className = cn('shadcn-react-root', options.containerClassName);
      handle.container.style.position = 'relative';
      handle.container.style.width =
        typeof options.width === 'number' ? `${options.width}px` : options.width ?? '320px';
      handle.container.style.minHeight =
        typeof options.minHeight === 'number' ? `${options.minHeight}px` : options.minHeight ?? '240px';

      await handle.flush(framesToWait);

      await testFn({
        ...handle,
        clickCenter,
        pressKey,
        waitForFrames,
        waitForSelector: <T extends Element>(
          selector: string,
          attempts?: number,
          framesPerAttempt?: number,
        ) => waitForSelectorInContainer<T>(handle.container, selector, handle.flush, attempts, framesPerAttempt),
      });
    },
    { framesToWait },
  );
}
