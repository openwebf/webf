/**
 * Platform detection and abstraction layer
 *
 * Detects whether running in WebF or standard browser environment
 * and provides a unified interface for platform-specific APIs.
 *
 * WebF types are provided by @openwebf/webf-enterprise-typings package.
 * In browser environments, the router works without WebF types.
 */

export type PlatformType = 'webf' | 'browser';

/**
 * Get the WebF hybridHistory object if available
 * Types come from @openwebf/webf-enterprise-typings peer dependency
 */
export function getWebFHybridHistory(): any | undefined {
  return (globalThis as any)?.webf?.hybridHistory;
}

/**
 * Detect the current platform
 */
export function detectPlatform(): PlatformType {
  // Check for WebF's hybridHistory API
  if (getWebFHybridHistory()) {
    return 'webf';
  }
  return 'browser';
}

/**
 * Check if running in WebF environment
 */
export function isWebF(): boolean {
  return detectPlatform() === 'webf';
}

/**
 * Check if running in browser environment
 */
export function isBrowser(): boolean {
  return detectPlatform() === 'browser';
}

/**
 * Get the current platform type (evaluated once at module load)
 */
export const platform: PlatformType = detectPlatform();
