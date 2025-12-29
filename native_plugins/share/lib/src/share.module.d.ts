/**
 * Type-safe JavaScript API for the WebF Share module.
 *
 * This interface is used by the WebF CLI (`webf module-codegen`) to generate:
 * - An npm package wrapper that forwards calls to `webf.invokeModuleAsync`
 * - Dart bindings that map module `invoke` calls to strongly-typed methods
 */
interface ShareTextOptions {
  /** Title/subject for the share operation. */
  title?: string;
  /** Text content to share. */
  text?: string;
  /** Optional URL to include in the shared content. */
  url?: string;
}

/**
 * Result returned from save operations in the Share module.
 */
interface ShareSaveResult {
  /** "true" on success, "false" on failure (string for backward compatibility). */
  success: string;
  /** Full path where the file was saved, when available. */
  filePath?: string;
  /** Platform-specific storage location info (e.g., "Downloads", "Documents"). */
  platformInfo?: string;
  /** Human-readable message about the operation. */
  message: string;
  /** Error message if the operation failed. */
  error?: string;
}

/**
 * Public WebF Share module interface.
 *
 * Methods here map 1:1 to the underlying Dart `ShareModule.invoke` methods.
 *
 * Module name: "Share"
 */
interface WebFShare {
  /**
   * Share an image with optional text and subject.
   *
   * @param imageData Binary image data to share.
   * @param text Text to include with the share.
   * @param subject Optional subject line for the share.
   */
  share(
    imageData: ArrayBuffer | Uint8Array,
    text: string,
    subject?: string
  ): Promise<boolean>;

  /**
   * Share text content (and optional URL) using a structured options object.
   *
   * This will be passed as the first argument to the Dart module and is
   * compatible with the existing `handleShareText` implementation.
   */
  shareText(options: ShareTextOptions): Promise<boolean>;

  /**
   * Save an image to device storage.
   *
   * @param imageData Binary image data to save.
   * @param filename Optional filename without extension.
   */
  save(
    imageData: ArrayBuffer | Uint8Array,
    filename?: string
  ): Promise<ShareSaveResult>;

  /**
   * Save an image to a temporary location for preview display.
   *
   * @param imageData Binary image data to save.
   * @param filename Optional filename for the preview image.
   */
  saveForPreview(
    imageData: ArrayBuffer | Uint8Array,
    filename?: string
  ): Promise<ShareSaveResult>;
}

