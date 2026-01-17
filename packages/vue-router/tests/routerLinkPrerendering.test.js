import assert from 'node:assert/strict';
import test from 'node:test';
import { defineComponent } from 'vue';

import { Route, WebFRouterLink } from '../dist/index.esm.js';

test('WebFRouterLink: renders slots after prerendering event', () => {
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
  assert.equal(vnode1.children, null);
  assert.equal(typeof vnode1.props.onPrerendering, 'function');

  vnode1.props.onPrerendering({ detail: null });

  const vnode2 = render();
  assert.equal(callbackCalled, true);
  assert.equal(vnode2.children, 'child');
});

test('Route: mounts element after prerendering event (without prerender)', () => {
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
});
