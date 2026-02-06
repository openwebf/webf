export * from './routes/index'
export * from './utils/RouterLink';

// Platform detection
export { isWebF, isBrowser, detectPlatform, platform } from './platform';
export type { PlatformType } from './platform';

// Browser history (for testing and advanced usage)
export { resetBrowserHistory } from './platform/browserHistory';