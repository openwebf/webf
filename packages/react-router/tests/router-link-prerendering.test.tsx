import React, { act } from 'react';
import { createRoot, type Root } from 'react-dom/client';
import { Route } from '../src/routes/Route';
import { WebFRouterLink } from '../src/utils/RouterLink';

describe('WebFRouterLink prerendering', () => {
  let container: HTMLDivElement;
  let root: Root;

  beforeAll(() => {
    (globalThis as any).IS_REACT_ACT_ENVIRONMENT = true;
  });

  beforeEach(() => {
    container = document.createElement('div');
    document.body.appendChild(container);
    root = createRoot(container);
  });

  afterEach(async () => {
    await act(async () => {
      root.unmount();
    });
    container.remove();
  });

  it('mounts children when receiving a prerendering event', async () => {
    await act(async () => {
      root.render(
        <WebFRouterLink path="/initial">
          <div data-testid="child" />
        </WebFRouterLink>
      );
    });

    const link = container.querySelector('webf-router-link') as HTMLElement | null;
    expect(link).not.toBeNull();
    expect(link!.querySelector('[data-testid="child"]')).toBeNull();

    await act(async () => {
      link!.dispatchEvent(new Event('prerendering'));
    });

    expect(link!.querySelector('[data-testid="child"]')).not.toBeNull();
  });

  it('mounts <Route> element when receiving a prerendering event (without prerender)', async () => {
    await act(async () => {
      root.render(<Route path="/initial" element={<div data-testid="route-child" />} />);
    });

    const link = container.querySelector('webf-router-link[path="/initial"]') as HTMLElement | null;
    expect(link).not.toBeNull();
    expect(link!.querySelector('[data-testid="route-child"]')).toBeNull();

    await act(async () => {
      link!.dispatchEvent(new Event('prerendering'));
    });

    expect(link!.querySelector('[data-testid="route-child"]')).not.toBeNull();
  });
});
