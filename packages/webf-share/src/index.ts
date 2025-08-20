/**
 * @openwebf/webf-share
 * Ready-to-use WebF Share integration library
 * 
 * This library provides a simple API to share content and save screenshots in WebF applications.
 * Just install and use - no need to manually call invokeModuleAsync.
 */

// Import WebF types from the official typings package
import { webf } from '@openwebf/webf-enterprise-typings';

/**
 * Options for sharing text content
 */
export interface ShareTextOptions {
  /** Title/subject for the share */
  title?: string;
  /** Text content to share */
  text?: string;
  /** URL to include in the share */
  url?: string;
}

/**
 * Options for sharing image content
 */
export interface ShareImageOptions {
  /** Image data as ArrayBuffer or Uint8Array */
  imageData: ArrayBuffer | Uint8Array;
  /** Text to share with the image */
  text: string;
  /** Subject/title for the share */
  subject?: string;
}

/**
 * Options for saving screenshots
 */
export interface SaveScreenshotOptions {
  /** Image data as ArrayBuffer or Uint8Array */
  imageData: ArrayBuffer | Uint8Array;
  /** Optional filename (without extension) */
  filename?: string;
}

/**
 * Options for saving preview images
 */
export interface SavePreviewOptions {
  /** Image data as ArrayBuffer or Uint8Array */
  imageData: ArrayBuffer | Uint8Array;
  /** Filename for the preview (without extension) */
  filename: string;
}

/**
 * Result from save operations
 */
export interface SaveResult {
  /** Whether the operation was successful */
  success: boolean;
  /** Full path where the file was saved */
  filePath?: string;
  /** Platform-specific storage location info */
  platformInfo?: string;
  /** Human-readable message about the operation */
  message: string;
  /** Error message if the operation failed */
  error?: string;
}

/**
 * Error thrown when WebF is not available
 */
export class WebFNotAvailableError extends Error {
  constructor() {
    super('WebF is not available. Make sure you are running in a WebF environment with the Share module installed.');
    this.name = 'WebFNotAvailableError';
  }
}

/**
 * Main WebF Share API
 */
export class WebFShare {
  /**
   * Check if WebF Share is available
   */
  static isAvailable(): boolean {
    return typeof webf !== 'undefined' && 
           typeof webf.invokeModuleAsync === 'function';
  }

  /**
   * Share text content
   * 
   * @example
   * ```typescript
   * import { WebFShare } from '@openwebf/webf-share';
   * 
   * const success = await WebFShare.shareText({
   *   title: 'Check this out!',
   *   text: 'Amazing content from WebF app',
   *   url: 'https://openwebf.com'
   * });
   * ```
   */
  static async shareText(options: ShareTextOptions): Promise<boolean> {
    if (!this.isAvailable()) {
      throw new WebFNotAvailableError();
    }

    try {
      // Support both new object format and legacy format
      const result = await webf.invokeModuleAsync(
        'Share',
        'shareText',
        options
      );
      return Boolean(result);
    } catch (error) {
      console.error('Share text failed:', error);
      return false;
    }
  }

  /**
   * Share image with text
   * 
   * @example
   * ```typescript
   * import { WebFShare, ShareHelpers } from '@openwebf/webf-share';
   * 
   * const canvas = document.querySelector('canvas');
   * const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
   * 
   * const success = await WebFShare.shareImage({
   *   imageData,
   *   text: 'Check out this amazing content!',
   *   subject: 'WebF Demo Screenshot'
   * });
   * ```
   */
  static async shareImage(options: ShareImageOptions): Promise<boolean> {
    if (!this.isAvailable()) {
      throw new WebFNotAvailableError();
    }

    try {
      const result = await webf.invokeModuleAsync(
        'Share',
        'share',
        options.imageData,
        options.text,
        options.subject || 'Shared from WebF App'
      );
      return Boolean(result);
    } catch (error) {
      console.error('Share image failed:', error);
      return false;
    }
  }

  /**
   * Save screenshot to device storage
   * 
   * @example
   * ```typescript
   * import { WebFShare, ShareHelpers } from '@openwebf/webf-share';
   * 
   * const canvas = document.querySelector('canvas');
   * const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
   * 
   * const result = await WebFShare.saveScreenshot({
   *   imageData,
   *   filename: 'my_screenshot'
   * });
   * 
   * if (result.success) {
   *   console.log('Saved to:', result.filePath);
   * }
   * ```
   */
  static async saveScreenshot(options: SaveScreenshotOptions): Promise<SaveResult> {
    if (!this.isAvailable()) {
      throw new WebFNotAvailableError();
    }

    try {
      const filename = options.filename || `screenshot_${Date.now()}`;
      const result = await webf.invokeModuleAsync(
        'Share',
        'save',
        options.imageData,
        filename
      );

      if (result === true || (typeof result === 'object' && result !== null && (result as any).success === 'true')) {
        return {
          success: true,
          message: 'Screenshot saved successfully',
          filePath: typeof result === 'object' && result !== null ? (result as any).filePath : undefined,
          platformInfo: typeof result === 'object' && result !== null ? (result as any).platformInfo : undefined
        };
      } else {
        return {
          success: false,
          message: typeof result === 'object' && result !== null && (result as any).message 
            ? (result as any).message 
            : 'Failed to save screenshot',
          error: typeof result === 'object' && result !== null ? (result as any).error : undefined
        };
      }
    } catch (error) {
      return {
        success: false,
        message: 'Failed to save screenshot',
        error: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }

  /**
   * Save image for preview (temporary file)
   * 
   * @example
   * ```typescript
   * import { WebFShare, ShareHelpers } from '@openwebf/webf-share';
   * 
   * const canvas = document.querySelector('canvas');
   * const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
   * 
   * const result = await WebFShare.saveForPreview({
   *   imageData,
   *   filename: 'preview_image'
   * });
   * 
   * if (result.success) {
   *   // Display the preview
   *   const img = document.createElement('img');
   *   img.src = result.filePath; // file:///tmp/preview_image.png
   *   document.body.appendChild(img);
   * }
   * ```
   */
  static async saveForPreview(options: SavePreviewOptions): Promise<SaveResult> {
    if (!this.isAvailable()) {
      throw new WebFNotAvailableError();
    }

    try {
      const result = await webf.invokeModuleAsync(
        'Share',
        'saveForPreview',
        options.imageData,
        options.filename
      );

      if (result && typeof result === 'object') {
        return {
          success: (result as any).success === 'true',
          message: (result as any).message || 'Preview saved',
          filePath: (result as any).filePath,
          error: (result as any).success === 'true' ? undefined : (result as any).error
        };
      } else {
        return {
          success: false,
          message: 'Failed to save preview',
          error: 'Invalid response format'
        };
      }
    } catch (error) {
      return {
        success: false,
        message: 'Failed to save preview',
        error: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }
}

/**
 * Helper functions for working with image data and sharing
 */
export const ShareHelpers = {
  /**
   * Convert a canvas element to ArrayBuffer for sharing
   * @param canvas - HTML Canvas element
   * @param quality - Image quality (0-1) for JPEG format
   * @returns Promise resolving to ArrayBuffer containing image data
   */
  canvasToArrayBuffer: async (canvas: HTMLCanvasElement, quality: number = 0.8): Promise<ArrayBuffer> => {
    return new Promise((resolve, reject) => {
      canvas.toBlob((blob) => {
        if (!blob) {
          reject(new Error('Failed to convert canvas to blob'));
          return;
        }
        
        const reader = new FileReader();
        reader.onload = () => {
          if (reader.result instanceof ArrayBuffer) {
            resolve(reader.result);
          } else {
            reject(new Error('Failed to convert blob to ArrayBuffer'));
          }
        };
        reader.onerror = () => reject(new Error('FileReader error'));
        reader.readAsArrayBuffer(blob);
      }, 'image/png', quality);
    });
  },

  /**
   * Convert an Image element to ArrayBuffer for sharing
   * @param img - HTML Image element
   * @param quality - Image quality (0-1) for JPEG format
   * @returns Promise resolving to ArrayBuffer containing image data
   */
  imageToArrayBuffer: async (img: HTMLImageElement, quality: number = 0.8): Promise<ArrayBuffer> => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    
    if (!ctx) {
      throw new Error('Failed to get canvas context');
    }
    
    canvas.width = img.naturalWidth || img.width;
    canvas.height = img.naturalHeight || img.height;
    
    ctx.drawImage(img, 0, 0);
    
    return ShareHelpers.canvasToArrayBuffer(canvas, quality);
  },

  /**
   * Convert a video element to ArrayBuffer (first frame)
   * @param video - HTML Video element
   * @param quality - Image quality (0-1)
   * @returns Promise resolving to ArrayBuffer containing image data
   */
  videoToArrayBuffer: async (video: HTMLVideoElement, quality: number = 0.8): Promise<ArrayBuffer> => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    
    if (!ctx) {
      throw new Error('Failed to get canvas context');
    }
    
    canvas.width = video.videoWidth || video.width;
    canvas.height = video.videoHeight || video.height;
    
    ctx.drawImage(video, 0, 0);
    
    return ShareHelpers.canvasToArrayBuffer(canvas, quality);
  },

  /**
   * Convert a Blob to ArrayBuffer
   * @param blob - Blob object
   * @returns Promise resolving to ArrayBuffer
   */
  blobToArrayBuffer: async (blob: Blob): Promise<ArrayBuffer> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        if (reader.result instanceof ArrayBuffer) {
          resolve(reader.result);
        } else {
          reject(new Error('Failed to convert blob to ArrayBuffer'));
        }
      };
      reader.onerror = () => reject(new Error('FileReader error'));
      reader.readAsArrayBuffer(blob);
    });
  },

  /**
   * Convert HTML element to ArrayBuffer by capturing it as an image
   * @param element - HTML element to capture
   * @param quality - Image quality (0-1)
   * @returns Promise resolving to ArrayBuffer
   */
  elementToArrayBuffer: async (element: HTMLElement, quality: number = 0.8): Promise<ArrayBuffer> => {
    // Check if element has toBlob method (WebF specific)
    if (typeof (element as any).toBlob === 'function') {
      const blob = await (element as any).toBlob(window.devicePixelRatio || 1.0);
      return ShareHelpers.blobToArrayBuffer(blob);
    }
    
    throw new Error('Element does not support toBlob method. This method is only available in WebF environment.');
  },

  /**
   * Generate a timestamp-based filename
   * @param prefix - Filename prefix (default: 'image')
   * @returns Filename with timestamp
   */
  generateFilename: (prefix: string = 'image'): string => {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    return `${prefix}_${timestamp}`;
  },

  /**
   * Create a simple text share object
   * @param title - Share title
   * @param text - Share text content
   * @param url - Optional URL to include
   */
  createTextShare: (title: string, text: string, url?: string): ShareTextOptions => ({
    title,
    text,
    url
  })
};

/**
 * React hook for share functionality (if using React)
 */
export const useWebFShare = () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const React = (globalThis as any)?.React;
  const useState = React?.useState || (() => [null, () => {}]);

  const [isSharing, setIsSharing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [lastResult, setLastResult] = useState(null);

  const shareText = async (options: ShareTextOptions): Promise<boolean> => {
    setIsSharing(true);
    try {
      const result = await WebFShare.shareText(options);
      setLastResult({ type: 'shareText', success: result });
      return result;
    } finally {
      setIsSharing(false);
    }
  };

  const shareImage = async (options: ShareImageOptions): Promise<boolean> => {
    setIsSharing(true);
    try {
      const result = await WebFShare.shareImage(options);
      setLastResult({ type: 'shareImage', success: result });
      return result;
    } finally {
      setIsSharing(false);
    }
  };

  const saveScreenshot = async (options: SaveScreenshotOptions): Promise<SaveResult> => {
    setIsSaving(true);
    try {
      const result = await WebFShare.saveScreenshot(options);
      setLastResult({ type: 'saveScreenshot', ...result });
      return result;
    } finally {
      setIsSaving(false);
    }
  };

  const saveForPreview = async (options: SavePreviewOptions): Promise<SaveResult> => {
    setIsSaving(true);
    try {
      const result = await WebFShare.saveForPreview(options);
      setLastResult({ type: 'saveForPreview', ...result });
      return result;
    } finally {
      setIsSaving(false);
    }
  };

  return {
    shareText,
    shareImage,
    saveScreenshot,
    saveForPreview,
    isSharing,
    isSaving,
    lastResult,
    isAvailable: WebFShare.isAvailable()
  };
};

/**
 * Default export for convenience
 */
export default WebFShare;