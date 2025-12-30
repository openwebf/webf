import assert from 'node:assert/strict';
import test from 'node:test';
import { defineComponent } from 'vue';

import { Route, Routes, useRoutes } from '../dist/index.esm.js';

test('useRoutes(): returns a <Routes> vnode with <Route> children', () => {
  const Home = defineComponent({ name: 'Home', render() {} });
  const User = defineComponent({ name: 'User', render() {} });

  const vnode = useRoutes([
    { path: '/', title: 'Home', element: Home, prerender: true, theme: 'material' },
    { path: '/users/:id', title: 'User', element: User, theme: 'cupertino' },
  ]);

  assert.ok(vnode);
  assert.equal(vnode.type, Routes);
  assert.ok(vnode.children && typeof vnode.children.default === 'function');

  const children = vnode.children.default();
  assert.equal(Array.isArray(children), true);
  assert.equal(children.length, 2);

  assert.equal(children[0].type, Route);
  assert.equal(children[0].props.path, '/');
  assert.equal(children[0].props.title, 'Home');
  assert.equal(children[0].props.prerender, true);
  assert.equal(children[0].props.theme, 'material');
  assert.equal(children[0].props.element, Home);

  assert.equal(children[1].type, Route);
  assert.equal(children[1].props.path, '/users/:id');
  assert.equal(children[1].props.title, 'User');
  assert.equal(children[1].props.prerender, undefined);
  assert.equal(children[1].props.theme, 'cupertino');
  assert.equal(children[1].props.element, User);
});

