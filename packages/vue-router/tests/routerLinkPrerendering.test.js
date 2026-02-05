import assert from 'node:assert/strict';
import test from 'node:test';
import { defineComponent } from 'vue';

import { Route, WebFRouterLink, isWebF } from '../dist/index.esm.js';

// Install mock WebF environment for testing WebF-specific behavior
function installWebFMock() {
  globalThis.webf = {
    hybridHistory: {
      path: '/',
      state: undefined,
      buildContextStack: [{ path: '/', state: undefined }],
    }
  };
}

function cleanupWebFMock() {
  delete globalThis.webf;
}

test('WebFRouterLink: (WebF mode) renders slots after prerendering event', () => {
  installWebFMock();

  let callbackCalled = false;

  const render = WebFRouterLink.setup(
    {
      path: '/initial',
      onPrerendering: () => {
        callbackCalled = true;
      },
    },
    {
      slots: {
        default: () => 'child',
      },
    }
  );

  const vnode1 = render();
  assert.equal(vnode1.type, 'webf-router-link');
  assert.equal(vnode1.children, null);
  assert.equal(typeof vnode1.props.onPrerendering, 'function');

  vnode1.props.onPrerendering({ detail: null });

  const vnode2 = render();
  assert.equal(callbackCalled, true);
  assert.equal(vnode2.children, 'child');

  cleanupWebFMock();
});

test('WebFRouterLink: (Browser mode) renders slots immediately', () => {
  cleanupWebFMock(); // Ensure no WebF mock

  const render = WebFRouterLink.setup(
    {
      path: '/initial',
    },
    {
      slots: {
        default: () => 'child',
      },
    }
  );

  const vnode = render();
  // In browser mode, renders a div with data attributes
  assert.equal(vnode.type, 'div');
  assert.equal(vnode.props['data-router-link'], '');
  assert.equal(vnode.props['data-path'], '/initial');
  // Content is rendered immediately in browser mode
  assert.equal(vnode.children, 'child');
});

test('Route: (WebF mode) mounts element after prerendering event (without prerender)', () => {
  installWebFMock();

  const Page = defineComponent({ name: 'Page', render() {} });

  const routeRender = Route.setup({ path: '/initial', prerender: false, element: Page });
  const routerLinkComponentVnode = routeRender();
  assert.equal(routerLinkComponentVnode.type.name, 'WebFRouterLink');

  const routerLinkRender = WebFRouterLink.setup(routerLinkComponentVnode.props, {
    slots: routerLinkComponentVnode.children,
  });

  const linkVnode1 = routerLinkRender();
  assert.equal(linkVnode1.type, 'webf-router-link');
  assert.equal(linkVnode1.children, null);
  assert.equal(typeof linkVnode1.props.onPrerendering, 'function');

  linkVnode1.props.onPrerendering({ detail: null });

  const linkVnode2 = routerLinkRender();
  assert.ok(linkVnode2.children);
  const childVNode = Array.isArray(linkVnode2.children) ? linkVnode2.children[0] : linkVnode2.children;
  assert.equal(childVNode.type, Page);

  cleanupWebFMock();
});

test('Route: (Browser mode) renders element immediately', () => {
  cleanupWebFMock();

  const Page = defineComponent({ name: 'Page', render() {} });

  const routeRender = Route.setup({ path: '/initial', prerender: false, element: Page });
  const routerLinkComponentVnode = routeRender();
  assert.equal(routerLinkComponentVnode.type.name, 'WebFRouterLink');

  const routerLinkRender = WebFRouterLink.setup(routerLinkComponentVnode.props, {
    slots: routerLinkComponentVnode.children,
  });

  const linkVnode = routerLinkRender();
  // In browser mode, renders a div
  assert.equal(linkVnode.type, 'div');
  assert.equal(linkVnode.props['data-router-link'], '');
  // Content should be rendered immediately
  assert.ok(linkVnode.children);
});
