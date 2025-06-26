// Mock fs module before importing commands
jest.mock('fs');

// Import the functions we want to test (we'll need to export them first)
// For now, let's just define them here for testing
function sanitizePackageName(name: string): string {
  // Remove any leading/trailing whitespace
  let sanitized = name.trim();
  
  // Check if it's a scoped package
  const isScoped = sanitized.startsWith('@');
  let scope = '';
  let packageName = sanitized;
  
  if (isScoped) {
    const parts = sanitized.split('/');
    if (parts.length >= 2) {
      scope = parts[0];
      packageName = parts.slice(1).join('/');
    } else {
      // Invalid scoped package, treat as regular
      packageName = sanitized.substring(1);
    }
  }
  
  // Sanitize scope if present
  if (scope) {
    scope = scope.toLowerCase();
    // Remove invalid characters from scope (keep only @ and alphanumeric/hyphen)
    scope = scope.replace(/[^@a-z0-9-]/g, '');
    if (scope === '@') {
      scope = '@pkg'; // Default scope if only @ remains
    }
  }
  
  // Sanitize package name part
  packageName = packageName.toLowerCase();
  packageName = packageName.replace(/\s+/g, '-');
  packageName = packageName.replace(/[^a-z0-9\-_.]/g, '');
  packageName = packageName.replace(/^[._]+/, '');
  packageName = packageName.replace(/[._]+$/, '');
  packageName = packageName.replace(/[-_.]{2,}/g, '-');
  packageName = packageName.replace(/^-+/, '').replace(/-+$/, '');
  
  // Ensure package name is not empty
  if (!packageName) {
    packageName = 'package';
  }
  
  // Ensure it starts with a letter or number
  if (!/^[a-z0-9]/.test(packageName)) {
    packageName = 'pkg-' + packageName;
  }
  
  // Combine scope and package name
  let result = scope ? `${scope}/${packageName}` : packageName;
  
  // Truncate to 214 characters (npm limit)
  if (result.length > 214) {
    if (scope) {
      // Try to preserve scope
      const maxPackageLength = 214 - scope.length - 1; // -1 for the /
      packageName = packageName.substring(0, maxPackageLength);
      packageName = packageName.replace(/[._-]+$/, '');
      result = `${scope}/${packageName}`;
    } else {
      result = result.substring(0, 214);
      result = result.replace(/[._-]+$/, '');
    }
  }
  
  return result;
}

function isValidNpmPackageName(name: string): boolean {
  // Check basic rules
  if (!name || name.length === 0 || name.length > 214) return false;
  if (name.trim() !== name) return false;
  
  // Check if it's a scoped package
  if (name.startsWith('@')) {
    const parts = name.split('/');
    if (parts.length !== 2) return false; // Scoped packages must have exactly one /
    
    const scope = parts[0];
    const packageName = parts[1];
    
    // Validate scope
    if (!/^@[a-z0-9][a-z0-9-]*$/.test(scope)) return false;
    
    // Validate package name part
    return isValidNpmPackageName(packageName);
  }
  
  // For non-scoped packages
  if (name !== name.toLowerCase()) return false;
  if (name.startsWith('.') || name.startsWith('_')) return false;
  
  // Check for valid characters (letters, numbers, hyphens, underscores, dots)
  if (!/^[a-z0-9][a-z0-9\-_.]*$/.test(name)) return false;
  
  // Check for URL-safe characters
  try {
    if (encodeURIComponent(name) !== name) return false;
  } catch {
    return false;
  }
  
  return true;
}

describe('npm package name sanitization', () => {
  describe('sanitizePackageName', () => {
    it('should convert uppercase to lowercase', () => {
      expect(sanitizePackageName('MyPackage')).toBe('mypackage');
      expect(sanitizePackageName('HELLO-WORLD')).toBe('hello-world');
    });
    
    it('should replace spaces with hyphens', () => {
      expect(sanitizePackageName('my package')).toBe('my-package');
      expect(sanitizePackageName('hello   world   app')).toBe('hello-world-app');
    });
    
    it('should remove invalid characters', () => {
      expect(sanitizePackageName('my@package!')).toBe('mypackage');
      expect(sanitizePackageName('hello#world$')).toBe('helloworld');
      expect(sanitizePackageName('test(1)_package')).toBe('test1_package');
    });
    
    it('should remove leading dots and underscores', () => {
      expect(sanitizePackageName('.package')).toBe('package');
      expect(sanitizePackageName('_package')).toBe('package');
      expect(sanitizePackageName('...package')).toBe('package');
    });
    
    it('should remove trailing dots and underscores', () => {
      expect(sanitizePackageName('package.')).toBe('package');
      expect(sanitizePackageName('package_')).toBe('package');
      expect(sanitizePackageName('package...')).toBe('package');
    });
    
    it('should handle consecutive special characters', () => {
      expect(sanitizePackageName('my--package')).toBe('my-package');
      expect(sanitizePackageName('hello___world')).toBe('hello-world');
      expect(sanitizePackageName('test...app')).toBe('test-app');
    });
    
    it('should ensure package starts with letter or number', () => {
      expect(sanitizePackageName('-package')).toBe('package');
      expect(sanitizePackageName('--package')).toBe('package');
      expect(sanitizePackageName('_test')).toBe('test');
      expect(sanitizePackageName('.app')).toBe('app');
      expect(sanitizePackageName('---')).toBe('package'); // all special chars removed, falls back to default
      expect(sanitizePackageName('-')).toBe('package'); // single hyphen removed, falls back to default
    });
    
    it('should handle empty or invalid input', () => {
      expect(sanitizePackageName('')).toBe('package');
      expect(sanitizePackageName('   ')).toBe('package');
      expect(sanitizePackageName('___')).toBe('package');
    });
    
    it('should truncate long names', () => {
      const longName = 'a'.repeat(220);
      const result = sanitizePackageName(longName);
      expect(result.length).toBeLessThanOrEqual(214);
      expect(result).toBe('a'.repeat(214));
    });
    
    it('should handle Flutter package names', () => {
      expect(sanitizePackageName('webf_cupertino_ui')).toBe('webf_cupertino_ui');
      expect(sanitizePackageName('WebF Cupertino UI')).toBe('webf-cupertino-ui');
      expect(sanitizePackageName('flutter_package_name')).toBe('flutter_package_name');
    });
    
    it('should handle scoped packages', () => {
      expect(sanitizePackageName('@openwebf/react-cupertino-ui')).toBe('@openwebf/react-cupertino-ui');
      expect(sanitizePackageName('@OpenWebF/React-Cupertino-UI')).toBe('@openwebf/react-cupertino-ui');
      expect(sanitizePackageName('@my-org/my-package')).toBe('@my-org/my-package');
      expect(sanitizePackageName('  @scope/package  ')).toBe('@scope/package');
      expect(sanitizePackageName('@SCOPE/PACKAGE')).toBe('@scope/package');
      expect(sanitizePackageName('@/package')).toBe('@pkg/package'); // Invalid scope
      expect(sanitizePackageName('@123/package')).toBe('@123/package'); // Numeric scope is valid
      expect(sanitizePackageName('@scope/my package')).toBe('@scope/my-package');
      expect(sanitizePackageName('@scope/.package')).toBe('@scope/package');
      expect(sanitizePackageName('@scope/_package')).toBe('@scope/package');
    });
  });
  
  describe('isValidNpmPackageName', () => {
    it('should accept valid package names', () => {
      expect(isValidNpmPackageName('mypackage')).toBe(true);
      expect(isValidNpmPackageName('my-package')).toBe(true);
      expect(isValidNpmPackageName('my_package')).toBe(true);
      expect(isValidNpmPackageName('my.package')).toBe(true);
      expect(isValidNpmPackageName('package123')).toBe(true);
      expect(isValidNpmPackageName('@openwebf/react-cupertino-ui')).toBe(true);
      expect(isValidNpmPackageName('@scope/package')).toBe(true);
      expect(isValidNpmPackageName('@my-org/my-package')).toBe(true);
      expect(isValidNpmPackageName('@123/package')).toBe(true);
    });
    
    it('should reject invalid package names', () => {
      expect(isValidNpmPackageName('MyPackage')).toBe(false); // uppercase
      expect(isValidNpmPackageName('my package')).toBe(false); // space
      expect(isValidNpmPackageName('.package')).toBe(false); // starts with dot
      expect(isValidNpmPackageName('_package')).toBe(false); // starts with underscore
      expect(isValidNpmPackageName('my@package')).toBe(false); // special char in wrong position
      expect(isValidNpmPackageName('')).toBe(false); // empty
      expect(isValidNpmPackageName(' package ')).toBe(false); // leading/trailing space
      expect(isValidNpmPackageName('@')).toBe(false); // just @
      expect(isValidNpmPackageName('@/')).toBe(false); // missing both parts
      expect(isValidNpmPackageName('@scope')).toBe(false); // missing package name
      expect(isValidNpmPackageName('@/package')).toBe(false); // missing scope name
      expect(isValidNpmPackageName('@Scope/package')).toBe(false); // uppercase in scope
      expect(isValidNpmPackageName('@scope/Package')).toBe(false); // uppercase in package
      expect(isValidNpmPackageName('@scope/.package')).toBe(false); // package starts with dot
      expect(isValidNpmPackageName('@scope/_package')).toBe(false); // package starts with underscore
    });
    
    it('should reject names that are too long', () => {
      const longName = 'a'.repeat(215);
      expect(isValidNpmPackageName(longName)).toBe(false);
    });
    
    it('should reject non-URL-safe names', () => {
      expect(isValidNpmPackageName('my package')).toBe(false);
      expect(isValidNpmPackageName('package?name')).toBe(false);
    });
  });
});