import { pathToRegex, matchPath, matchRoutes, generateKey } from '../src/utils';
import { RouteConfig } from '../src/types';

describe('Router Utils', () => {
  describe('pathToRegex', () => {
    it('should convert simple paths', () => {
      const { regex, paramNames } = pathToRegex('/about');
      expect(regex.test('/about')).toBe(true);
      expect(regex.test('/home')).toBe(false);
      expect(paramNames).toEqual([]);
    });

    it('should convert paths with parameters', () => {
      const { regex, paramNames } = pathToRegex('/user/:id');
      expect(regex.test('/user/123')).toBe(true);
      expect(regex.test('/user/')).toBe(false);
      expect(paramNames).toEqual(['id']);
    });

    it('should convert paths with multiple parameters', () => {
      const { regex, paramNames } = pathToRegex('/user/:id/post/:postId');
      expect(regex.test('/user/123/post/456')).toBe(true);
      expect(paramNames).toEqual(['id', 'postId']);
    });

    it('should handle wildcard paths', () => {
      const { regex, paramNames } = pathToRegex('/files/*');
      expect(regex.test('/files/path/to/file.txt')).toBe(true);
      expect(paramNames).toEqual(['*']);
    });
  });

  describe('matchPath', () => {
    it('should match simple paths', () => {
      const match = matchPath('/about', '/about');
      expect(match).toEqual({ params: {} });
    });

    it('should return null for non-matching paths', () => {
      const match = matchPath('/home', '/about');
      expect(match).toBeNull();
    });

    it('should extract parameters', () => {
      const match = matchPath('/user/123', '/user/:id');
      expect(match).toEqual({ params: { id: '123' } });
    });

    it('should extract multiple parameters', () => {
      const match = matchPath('/user/123/post/456', '/user/:id/post/:postId');
      expect(match).toEqual({ params: { id: '123', postId: '456' } });
    });
  });

  describe('matchRoutes', () => {
    const routes: RouteConfig[] = [
      {
        path: '/',
        element: {} as any,
        children: [
          {
            path: '/about',
            element: {} as any
          },
          {
            path: '/users',
            element: {} as any,
            children: [
              {
                path: '/users/:id',
                element: {} as any
              }
            ]
          }
        ]
      }
    ];

    it('should match root route', () => {
      const matches = matchRoutes(routes, '/');
      expect(matches).toHaveLength(1);
      expect(matches[0].pathname).toBe('/');
    });

    it('should match nested routes', () => {
      const matches = matchRoutes(routes, '/about');
      expect(matches).toHaveLength(2);
      expect(matches[0].pathname).toBe('/');
      expect(matches[1].pathname).toBe('/about');
    });

    it('should match deeply nested routes with params', () => {
      const matches = matchRoutes(routes, '/users/123');
      expect(matches).toHaveLength(3);
      expect(matches[0].pathname).toBe('/');
      expect(matches[1].pathname).toBe('/users');
      expect(matches[2].pathname).toBe('/users/:id');
      expect(matches[2].params).toEqual({ id: '123' });
    });
  });

  describe('generateKey', () => {
    it('should generate unique keys', () => {
      const key1 = generateKey();
      const key2 = generateKey();
      expect(key1).not.toBe(key2);
    });

    it('should generate string keys', () => {
      const key = generateKey();
      expect(typeof key).toBe('string');
      expect(key.length).toBeGreaterThan(0);
    });
  });
});