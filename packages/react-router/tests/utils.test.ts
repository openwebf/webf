import { matchPath, matchRoutes, pathToRegex } from '../src/routes/utils';

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

    it('should handle catch-all "*" pattern', () => {
      const { regex, paramNames } = pathToRegex('*');
      expect(regex.test('/anything/here')).toBe(true);
      expect(paramNames).toEqual(['*']);
    });
  });

  describe('matchPath', () => {
    it('should match simple paths', () => {
      const match = matchPath('/about', '/about');
      expect(match).not.toBeNull();
      expect(match?.params).toEqual({});
    });

    it('should return null for non-matching paths', () => {
      const match = matchPath('/home', '/about');
      expect(match).toBeNull();
    });

    it('should extract parameters', () => {
      const match = matchPath('/user/:id', '/user/123');
      expect(match).not.toBeNull();
      expect(match?.params).toEqual({ id: '123' });
    });

    it('should extract multiple parameters', () => {
      const match = matchPath('/user/:id/post/:postId', '/user/123/post/456');
      expect(match).not.toBeNull();
      expect(match?.params).toEqual({ id: '123', postId: '456' });
    });

    it('should extract splat from wildcard paths', () => {
      const match = matchPath('/files/*', '/files/path/to/file.txt');
      expect(match).not.toBeNull();
      expect(match?.params).toEqual({ '*': 'path/to/file.txt' });
    });

    it('should match catch-all "*" pattern', () => {
      const match = matchPath('*', '/any/path');
      expect(match).not.toBeNull();
      expect(match?.params).toEqual({ '*': '/any/path' });
    });
  });

  describe('matchRoutes', () => {
    it('should match root route', () => {
      const match = matchRoutes(['/', '*'], '/');
      expect(match?.path).toBe('/');
    });

    it('should match dynamic routes in order', () => {
      const match = matchRoutes(['/', '/users/:id', '*'], '/users/123');
      expect(match?.path).toBe('/users/:id');
      expect(match?.params).toEqual({ id: '123' });
    });
  });
});
