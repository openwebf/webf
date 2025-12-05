/**
 * Type-safe JavaScript API for the WebF DeepLink module.
 *
 * This interface is used by the WebF CLI (`webf module-codegen`) to generate:
 * - An npm package wrapper that forwards calls to `webf.invokeModuleAsync`
 * - Dart bindings that map module `invoke` calls to strongly-typed methods
 */

/**
 * Parameters for opening a deep link.
 */
interface OpenDeepLinkOptions {
  /** The deep link URL to open, e.g. `whatsapp://send?text=Hello`. */
  url: string;
  /** Optional fallback URL if the primary URL cannot be opened. */
  fallbackUrl?: string;
}

/**
 * Result returned from opening a deep link.
 */
interface OpenDeepLinkResult {
  /** Whether the operation was successful. */
  success: boolean;
  /** The URL that was ultimately attempted or opened. */
  url?: string;
  /** Human-readable message about the operation outcome. */
  message?: string;
  /** Whether the fallback URL was used instead of the primary URL. */
  fallback?: boolean;
  /** Error message if the operation failed. */
  error?: string;
  /** Platform information (e.g., `ios`, `android`, `macos`). */
  platform?: string;
}

/**
 * Parameters for registering a deep link handler.
 */
interface RegisterDeepLinkHandlerOptions {
  /** The URL scheme to register (e.g., `myapp`). */
  scheme: string;
  /** Optional host part of the URL (e.g., `action`). */
  host?: string;
}

/**
 * Result returned from registering a deep link handler.
 */
interface RegisterDeepLinkHandlerResult {
  /** Whether registration was successful. */
  success: boolean;
  /** The URL scheme that was registered. */
  scheme: string;
  /** The host part that was registered, if any. */
  host?: string;
  /** Human-readable message about the registration. */
  message: string;
  /** Platform information (e.g., `ios`, `android`, `macos`). */
  platform?: string;
  /** Platform-specific configuration notes or hints. */
  note?: string;
  /** Error message if registration failed. */
  error?: string;
}

/**
 * Public WebF DeepLink module interface.
 *
 * Methods here map 1:1 to the underlying Dart `DeepLinkModule.invoke` methods.
 *
 * Module name: "DeepLink"
 */
interface WebFDeepLink {
  /**
   * Open a deep link URL with optional fallback.
   */
  openDeepLink(options: OpenDeepLinkOptions): Promise<OpenDeepLinkResult>;

  /**
   * Register a deep link handler configuration.
   *
   * Note: actual OS registration still requires platform-specific setup.
   */
  registerDeepLinkHandler(
    options: RegisterDeepLinkHandlerOptions
  ): Promise<RegisterDeepLinkHandlerResult>;
}

