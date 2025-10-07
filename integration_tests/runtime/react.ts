import type { ReactElement } from 'react';
import { createRoot, Root } from 'react-dom/client';

const DEFAULT_CONTAINER_ID = 'react-spec-root';

type ReactSpecOptions = {
  framesToWait?: number;
};

type ReactSpecHandle = {
  root: Root;
  container: HTMLElement;
  rerender: (element: ReactElement, options?: { framesToWait?: number }) => Promise<void>;
  flush: (frames?: number) => Promise<void>;
};

// Reuse harness frame utilities (if present) so React updates settle before assertions.
const waitForFrames = (count: number = 1): Promise<void> => {
  if (count <= 0) {
    return Promise.resolve();
  }
  const nextFramesFn = (globalThis as any).nextFrames as ((frames?: number) => Promise<void>) | undefined;
  if (typeof nextFramesFn === 'function') {
    return nextFramesFn(count);
  }
  return new Promise((resolve) => {
    let remaining = count;
    const tick = () => {
      if (remaining <= 0) {
        resolve();
        return;
      }
      remaining -= 1;
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  });
};

const ensureContainer = (options: ReactSpecOptions): { container: HTMLElement } => {
  const container = document.createElement('div');
  document.body.appendChild(container);
  return { container};
};

export async function renderReactSpec(
  element: ReactElement,
  options: ReactSpecOptions = {}
): Promise<ReactSpecHandle> {
  const { container } = ensureContainer(options);
  const root = createRoot(container);
  root.render(element);

  const framesToWait = options.framesToWait ?? 1;
  await waitForFrames(framesToWait);

  const handle: ReactSpecHandle = {
    root,
    container,
    rerender: async (nextElement, rerenderOptions = {}) => {
      root.render(nextElement);
      const frames = rerenderOptions.framesToWait ?? framesToWait;
      await waitForFrames(frames);
    },
    flush: async (frames = framesToWait) => {
      await waitForFrames(frames);
    }
  };

  return handle;
}

// Convenience wrapper that guarantees cleanup even when assertions throw.
export async function withReactSpec(
  element: ReactElement,
  testFn: (handle: ReactSpecHandle) => unknown | Promise<unknown>,
  options: ReactSpecOptions = {}
): Promise<void> {
  const handle = await renderReactSpec(element, options);
  try {
    await testFn(handle);
  } finally {}
}

declare global {
  // eslint-disable-next-line no-var
  var renderReactSpec: typeof renderReactSpec;
  // eslint-disable-next-line no-var
  var withReactSpec: typeof withReactSpec;
}

globalThis.renderReactSpec = renderReactSpec;
globalThis.withReactSpec = withReactSpec;
