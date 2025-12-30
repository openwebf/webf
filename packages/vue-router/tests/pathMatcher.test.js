import assert from 'node:assert/strict';
import test from 'node:test';

import { matchPath, matchRoutes, pathToRegex } from '../dist/index.esm.js';

test('pathToRegex: converts simple paths', () => {
  const { regex, paramNames } = pathToRegex('/about');
  assert.equal(regex.test('/about'), true);
  assert.equal(regex.test('/home'), false);
  assert.deepEqual(paramNames, []);
});

test('pathToRegex: converts paths with parameters', () => {
  const { regex, paramNames } = pathToRegex('/user/:id');
  assert.equal(regex.test('/user/123'), true);
  assert.equal(regex.test('/user/'), false);
  assert.deepEqual(paramNames, ['id']);
});

test('pathToRegex: handles wildcard paths', () => {
  const { regex, paramNames } = pathToRegex('/files/*');
  assert.equal(regex.test('/files/path/to/file.txt'), true);
  assert.deepEqual(paramNames, ['*']);
});

test('pathToRegex: handles catch-all "*" pattern', () => {
  const { regex, paramNames } = pathToRegex('*');
  assert.equal(regex.test('/anything/here'), true);
  assert.deepEqual(paramNames, ['*']);
});

test('matchPath: extracts parameters and splats', () => {
  const match = matchPath('/user/:id', '/user/123');
  assert.ok(match);
  assert.deepEqual(match.params, { id: '123' });

  const splat = matchPath('/files/*', '/files/path/to/file.txt');
  assert.ok(splat);
  assert.deepEqual(splat.params, { '*': 'path/to/file.txt' });

  const catchAll = matchPath('*', '/any/path');
  assert.ok(catchAll);
  assert.deepEqual(catchAll.params, { '*': '/any/path' });
});

test('matchRoutes: matches dynamic routes in order', () => {
  const match = matchRoutes(['/', '/users/:id', '*'], '/users/123');
  assert.ok(match);
  assert.equal(match.path, '/users/:id');
  assert.deepEqual(match.params, { id: '123' });
});

