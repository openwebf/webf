import assert from 'node:assert/strict';
import test from 'node:test';

import { WebFRouter, __unstable_setEnsureRouteMountedCallback } from '../dist/index.esm.js';

function installHybridHistory(overrides = {}) {
  const hybridHistory = {
    path: '/',
    state: undefined,
    buildContextStack: [{ path: '/', state: undefined }],
    pushNamed: (...args) => {
      hybridHistory.__calls.pushNamed.push(args);
    },
    pushReplacementNamed: (...args) => {
      hybridHistory.__calls.pushReplacementNamed.push(args);
    },
    back: (...args) => {
      hybridHistory.__calls.back.push(args);
    },
    pop: (...args) => {
      hybridHistory.__calls.pop.push(args);
    },
    popUntil: (...args) => {
      hybridHistory.__calls.popUntil.push(args);
    },
    popAndPushNamed: (...args) => {
      hybridHistory.__calls.popAndPushNamed.push(args);
    },
    pushNamedAndRemoveUntil: (...args) => {
      hybridHistory.__calls.pushNamedAndRemoveUntil.push(args);
    },
    pushNamedAndRemoveUntilRoute: (...args) => {
      hybridHistory.__calls.pushNamedAndRemoveUntilRoute.push(args);
    },
    canPop: () => false,
    maybePop: () => false,
    pushState: (...args) => {
      hybridHistory.__calls.pushState.push(args);
    },
    replaceState: (...args) => {
      hybridHistory.__calls.replaceState.push(args);
    },
    restorablePopAndPushState: () => 'restoration-id',
    restorablePopAndPushNamed: async () => 'restoration-id',
    __calls: {
      pushNamed: [],
      pushReplacementNamed: [],
      back: [],
      pop: [],
      popUntil: [],
      popAndPushNamed: [],
      pushNamedAndRemoveUntil: [],
      pushNamedAndRemoveUntilRoute: [],
      pushState: [],
      replaceState: [],
    },
    ...overrides,
  };

  globalThis.webf = { hybridHistory };
  return hybridHistory;
}

async function flushMicrotasks() {
  await Promise.resolve();
  await Promise.resolve();
}

test('WebFRouter: throws when hybridHistory is missing', async () => {
  delete globalThis.webf;
  __unstable_setEnsureRouteMountedCallback(null);
  await assert.rejects(() => WebFRouter.push('/missing'), /hybridHistory is not available/);
});

test('WebFRouter.stack: returns buildContextStack (or empty)', () => {
  delete globalThis.webf;
  assert.deepEqual(WebFRouter.stack, []);

  const hybridHistory = installHybridHistory({
    buildContextStack: [{ path: '/', state: 1 }, { path: '/a', state: 2 }],
  });

  assert.deepEqual(WebFRouter.stack, hybridHistory.buildContextStack);

  delete globalThis.webf;
});

test('WebFRouter.push: awaits ensureRouteMounted before pushNamed', async () => {
  const hybridHistory = installHybridHistory();

  let resolveEnsure;
  __unstable_setEnsureRouteMountedCallback(
    () =>
      new Promise((resolve) => {
        resolveEnsure = resolve;
      })
  );

  const navigationPromise = WebFRouter.push('/users/456');
  await flushMicrotasks();
  assert.equal(hybridHistory.__calls.pushNamed.length, 0);

  resolveEnsure();
  await navigationPromise;

  assert.deepEqual(hybridHistory.__calls.pushNamed, [['/users/456', { arguments: undefined }]]);

  __unstable_setEnsureRouteMountedCallback(null);
  delete globalThis.webf;
});

test('WebFRouter.replace: awaits ensureRouteMounted before pushReplacementNamed', async () => {
  const hybridHistory = installHybridHistory();

  let resolveEnsure;
  __unstable_setEnsureRouteMountedCallback(
    () =>
      new Promise((resolve) => {
        resolveEnsure = resolve;
      })
  );

  const navigationPromise = WebFRouter.replace('/users/456', { from: 'test' });
  await flushMicrotasks();
  assert.equal(hybridHistory.__calls.pushReplacementNamed.length, 0);

  resolveEnsure();
  await navigationPromise;

  assert.deepEqual(hybridHistory.__calls.pushReplacementNamed, [['/users/456', { arguments: { from: 'test' } }]]);

  __unstable_setEnsureRouteMountedCallback(null);
  delete globalThis.webf;
});

