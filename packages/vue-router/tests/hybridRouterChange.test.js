import assert from 'node:assert/strict';
import test from 'node:test';

import { __unstable_deriveActivePathFromHybridRouterChange } from '../dist/index.esm.js';

test('deriveActivePath: didPopNext trusts event path even if runtime is stale', () => {
  const result = __unstable_deriveActivePathFromHybridRouterChange({
    kind: 'didPopNext',
    path: '/users/123',
    currentActivePath: '/users/124',
    routerPath: '/users/124',
    stackTopPath: '/users/124',
  });

  assert.equal(result.activePath, '/users/123');
  assert.equal(result.reason, 'didPopNext:eventPath');
});

test('deriveActivePath: didPop does not override active path with popped route', () => {
  const result = __unstable_deriveActivePathFromHybridRouterChange({
    kind: 'didPop',
    path: '/users/124',
    currentActivePath: '/users/123',
    routerPath: '/users/124',
    stackTopPath: '/users/123',
  });

  assert.equal(result.activePath, '/users/123');
  assert.equal(result.reason, 'didPop:keepCurrentActivePath');
});

test('deriveActivePath: didPop falls back to stackTop when current is missing', () => {
  const result = __unstable_deriveActivePathFromHybridRouterChange({
    kind: 'didPop',
    path: '/users/124',
    currentActivePath: undefined,
    routerPath: '/users/124',
    stackTopPath: '/users/123',
  });

  assert.equal(result.activePath, '/users/123');
  assert.equal(result.reason, 'didPop:stackTopPath');
});

