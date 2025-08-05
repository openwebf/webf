/**
 * Route parameters extracted from dynamic routes
 */
export interface RouteParams {
  [key: string]: string;
}

/**
 * Route match result
 */
export interface RouteMatch {
  path: string;
  params: RouteParams;
  isExact: boolean;
}

/**
 * Convert a route pattern to a regular expression
 * @param pattern Route pattern like "/user/:userId" or "/category/:catId/product/:prodId"
 * @returns Object with regex and parameter names
 */
export function pathToRegex(pattern: string): { regex: RegExp; paramNames: string[] } {
  const paramNames: string[] = [];
  
  // Escape special regex characters except : and *
  let regexPattern = pattern.replace(/[.+?^${}()|[\]\\]/g, '\\$&');
  
  // Replace :param with named capture groups
  regexPattern = regexPattern.replace(/:([^\/]+)/g, (_, paramName) => {
    paramNames.push(paramName);
    return '([^/]+)';
  });
  
  // Add anchors for exact matching
  regexPattern = `^${regexPattern}$`;
  
  return {
    regex: new RegExp(regexPattern),
    paramNames
  };
}

/**
 * Match a pathname against a route pattern and extract parameters
 * @param pattern Route pattern like "/user/:userId"
 * @param pathname Actual pathname like "/user/123"
 * @returns Match result with extracted parameters or null if no match
 */
export function matchPath(pattern: string, pathname: string): RouteMatch | null {
  const { regex, paramNames } = pathToRegex(pattern);
  const match = pathname.match(regex);
  
  if (!match) {
    return null;
  }
  
  // Extract parameters from capture groups
  const params: RouteParams = {};
  paramNames.forEach((paramName, index) => {
    params[paramName] = match[index + 1]; // +1 because match[0] is the full match
  });
  
  return {
    path: pattern,
    params,
    isExact: true
  };
}

/**
 * Find the best matching route from a list of route patterns
 * @param routes Array of route patterns
 * @param pathname Current pathname
 * @returns Best match or null if no routes match
 */
export function matchRoutes(routes: string[], pathname: string): RouteMatch | null {
  for (const route of routes) {
    const match = matchPath(route, pathname);
    if (match) {
      return match;
    }
  }
  return null;
}