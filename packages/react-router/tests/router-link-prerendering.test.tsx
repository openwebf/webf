import React, { act } from 'react';
import { createRoot, type Root } from 'react-dom/client';
import { Route } from '../src/routes/Route';
import { WebFRouterLink } from '../src/utils/RouterLink';
import { resetBrowserHistory } from '../src/platform/browserHistory';

describe('WebFRouterLink prerendering', () => {
  let container: HTMLDivElement;
  let root: Root;

  beforeAll(() => {
    (globalThis as any).IS_REACT_ACT_ENVIRONMENT = true;
  });

  beforeEach(() => {
    // Reset browser history for each test
    resetBrowserHistory();
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

  describe('in browser environment', () => {
    it('mounts children when route matches current path', async () => {
      // Set the initial path to match the route
      window.history.replaceState({}, '', '/initial');
      resetBrowserHistory();

      await act(async () => {
        root.render(
          <WebFRouterLink path="/initial">
            <div data-testid="child" />
          </WebFRouterLink>
        );
      });

      // In browser environment, we use a div with data-path attribute
      const link = container.querySelector('[data-path="/initial"]') as HTMLElement | null;
      expect(link).not.toBeNull();
      // Since the path matches, children should be rendered
      expect(link!.querySelector('[data-testid="child"]')).not.toBeNull();
    });

    it('does not mount children when route does not match current path', async () => {
      // Set a different initial path
      window.history.replaceState({}, '', '/other');
      resetBrowserHistory();

      await act(async () => {
        root.render(
          <WebFRouterLink path="/initial">
            <div data-testid="child" />
          </WebFRouterLink>
        );
      });

      // In browser environment, we use a div with data-path attribute
      const link = container.querySelector('[data-path="/initial"]') as HTMLElement | null;
      expect(link).not.toBeNull();
      // Since the path doesn't match, children should not be rendered
      expect(link!.querySelector('[data-testid="child"]')).toBeNull();
    });

    it('mounts <Route> element when route matches current path', async () => {
      // Set the initial path to match the route
      window.history.replaceState({}, '', '/initial');
      resetBrowserHistory();

      await act(async () => {
        root.render(<Route path="/initial" element={<div data-testid="route-child" />} />);
      });

      // In browser environment, we use a div with data-path attribute
      const link = container.querySelector('[data-path="/initial"]') as HTMLElement | null;
      expect(link).not.toBeNull();
      // Since the path matches, children should be rendered
      expect(link!.querySelector('[data-testid="route-child"]')).not.toBeNull();
    });

    it('mounts children when navigating to matching route', async () => {
      // Start with a different path
      window.history.replaceState({}, '', '/other');
      resetBrowserHistory();

      await act(async () => {
        root.render(
          <WebFRouterLink path="/initial">
            <div data-testid="child" />
          </WebFRouterLink>
        );
      });

      const link = container.querySelector('[data-path="/initial"]') as HTMLElement | null;
      expect(link).not.toBeNull();
      // Children should not be rendered yet
      expect(link!.querySelector('[data-testid="child"]')).toBeNull();

      // Navigate to the matching path
      await act(async () => {
        window.history.pushState({}, '', '/initial');
        const event = new CustomEvent('hybridrouterchange', {
          bubbles: true,
          composed: true,
          detail: { path: '/initial', state: null, kind: 'didPush' },
        });
        (event as any).path = '/initial';
        (event as any).state = null;
        (event as any).kind = 'didPush';
        document.dispatchEvent(event);
      });

      // Now children should be rendered
      expect(link!.querySelector('[data-testid="child"]')).not.toBeNull();
    });
  });
});
