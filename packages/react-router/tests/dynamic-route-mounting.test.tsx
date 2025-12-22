import React, { act } from 'react';
import { createRoot, type Root } from 'react-dom/client';
import { Route } from '../src/routes/Route';
import { Routes, useParams, useRouteContext } from '../src/routes/Routes';
import { WebFRouter } from '../src/routes/utils';

jest.mock('../src/utils/RouterLink', () => {
  const React = require('react');
  return {
    WebFRouterLink: (props: any) =>
      React.createElement(
        'webf-router-link',
        { path: props.path, title: props.title, theme: props.theme },
        props.children
      ),
  };
});

jest.mock('ahooks', () => ({
  useMemoizedFn: (fn: any) => fn,
}));

function installHybridHistory(overrides: Partial<any>) {
  const hybridHistory = {
    path: '/',
    state: undefined,
    buildContextStack: [{ path: '/', state: undefined }],
    pushNamed: jest.fn(),
    pushReplacementNamed: jest.fn(),
    back: jest.fn(),
    pop: jest.fn(),
    popUntil: jest.fn(),
    popAndPushNamed: jest.fn(),
    pushNamedAndRemoveUntil: jest.fn(),
    pushNamedAndRemoveUntilRoute: jest.fn(),
    canPop: jest.fn(() => false),
    maybePop: jest.fn(() => false),
    pushState: jest.fn(),
    replaceState: jest.fn(),
    restorablePopAndPushState: jest.fn(() => 'restoration-id'),
    restorablePopAndPushNamed: jest.fn(async () => 'restoration-id'),
    ...overrides,
  };

  (globalThis as any).webf = { hybridHistory };
  return hybridHistory;
}

describe('Dynamic route mounting', () => {
  let container: HTMLDivElement;
  let root: Root;

  beforeAll(() => {
    (globalThis as any).IS_REACT_ACT_ENVIRONMENT = true;
  });

  async function render(ui: React.ReactNode) {
    await act(async () => {
      root.render(ui);
    });
  }

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
    delete (globalThis as any).webf;
  });

  it('mounts a concrete <webf-router-link> for dynamic stack paths (with descendants)', async () => {
    installHybridHistory({
      path: '/users/123',
      buildContextStack: [{ path: '/', state: undefined }, { path: '/users/123', state: { from: 'stack' } }],
    });

    await render(
      <Routes>
        <Route path="/" prerender element={<div />} />
        <Route
          path="/users/:id"
          prerender
          element={
            <div data-testid="descendant">
              <span data-testid="deep-child">ok</span>
            </div>
          }
        />
      </Routes>
    );

    const link = document.querySelector('webf-router-link[path="/users/123"]') as HTMLElement | null;
    expect(link).not.toBeNull();
    expect(link!.querySelector('[data-testid="descendant"]')).not.toBeNull();
    expect(link!.querySelector('[data-testid="deep-child"]')?.textContent).toBe('ok');
  });

  it('pre-mounts the dynamic route element before calling hybridHistory.pushNamed()', async () => {
    const pushNamed = jest.fn((pathname: string) => {
      const link = document.querySelector(`webf-router-link[path="${pathname}"]`);
      expect(link).not.toBeNull();
    });

    installHybridHistory({
      path: '/',
      buildContextStack: [{ path: '/', state: undefined }],
      pushNamed,
    });

    await render(
      <Routes>
        <Route path="/" prerender element={<div />} />
        <Route path="/users/:id" element={<div />} />
      </Routes>
    );

    let navigationPromise!: Promise<void>;
    await act(async () => {
      navigationPromise = WebFRouter.push('/users/456');
    });
    await act(async () => {});
    await navigationPromise;

    expect(pushNamed).toHaveBeenCalledWith('/users/456', { arguments: undefined });
  });

  it('provides params for the active mounted dynamic route', async () => {
    function UserPage() {
      const { isActive } = useRouteContext();
      const params = useParams();
      return (
        <div data-testid={isActive ? 'active' : 'inactive'}>
          {isActive ? params.id : ''}
        </div>
      );
    }

    installHybridHistory({
      path: '/users/789',
      buildContextStack: [{ path: '/', state: undefined }, { path: '/users/789', state: undefined }],
    });

    await render(
      <Routes>
        <Route path="/" prerender element={<div />} />
        <Route path="/users/:id" prerender element={<UserPage />} />
      </Routes>
    );

    const active = document.querySelector('[data-testid="active"]') as HTMLElement | null;
    expect(active).not.toBeNull();
    expect(active!.textContent).toBe('789');

    const link = active!.closest('webf-router-link') as HTMLElement | null;
    expect(link?.getAttribute('path')).toBe('/users/789');
  });
});
