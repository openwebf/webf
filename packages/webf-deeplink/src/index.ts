/**
 * @openwebf/webf-deeplink
 * Ready-to-use WebF DeepLink integration library
 * 
 * This library provides a simple API to work with deep links in WebF applications.
 * Just install and use - no need to manually call invokeModuleAsync.
 */

// Import WebF types from the official typings package
import { webf } from '@openwebf/webf-enterprise-typings';

/**
 * Parameters for opening a deep link
 */
export interface OpenDeepLinkOptions {
  /** The URL to open */
  url: string;
  /** Fallback URL if the primary URL fails */
  fallbackUrl?: string;
}

/**
 * Result from opening a deep link
 */
export interface OpenDeepLinkResult {
  /** Whether the operation was successful */
  success: boolean;
  /** The URL that was attempted */
  url: string;
  /** Human-readable message about the operation */
  message: string;
  /** Whether fallback was used */
  fallback?: boolean;
  /** Error message if the operation failed */
  error?: string;
  /** Platform information */
  platform?: string;
}

/**
 * Error thrown when WebF is not available
 */
export class WebFNotAvailableError extends Error {
  constructor() {
    super('WebF is not available. Make sure you are running in a WebF environment with the DeepLink module installed.');
    this.name = 'WebFNotAvailableError';
  }
}

/**
 * Main WebF DeepLink API
 */
export class WebFDeepLink {
  /**
   * Check if WebF DeepLink is available
   */
  static isAvailable(): boolean {
    return typeof webf !== 'undefined' && 
           typeof webf.invokeModuleAsync === 'function';
  }

  /**
   * Open a deep link URL
   * 
   * @example
   * ```typescript
   * import { WebFDeepLink } from '@openwebf/webf-deeplink';
   * 
   * try {
   *   const result = await WebFDeepLink.openDeepLink({
   *     url: 'mailto:demo@example.com?subject=Hello',
   *     fallbackUrl: 'https://example.com/contact'
   *   });
   *   
   *   if (result.success) {
   *     console.log('Deep link opened successfully');
   *   } else {
   *     console.error('Failed to open deep link:', result.message);
   *   }
   * } catch (error) {
   *   console.error('Error:', error.message);
   * }
   * ```
   */
  static async openDeepLink(options: OpenDeepLinkOptions): Promise<OpenDeepLinkResult> {
    if (!this.isAvailable()) {
      throw new WebFNotAvailableError();
    }

    try {
      const result = await webf.invokeModuleAsync(
        'DeepLink',
        'openDeepLink',
        {
          url: options.url,
          fallbackUrl: options.fallbackUrl || window.location.href
        }
      );

      return {
        success: true,
        url: options.url,
        message: 'Deep link opened successfully',
        ...(typeof result === 'object' && result !== null ? result : {})
      };
    } catch (error) {
      return {
        success: false,
        url: options.url,
        message: 'Failed to open deep link',
        error: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }
}

/**
 * Convenient helper functions for common deep link scenarios
 */
export const DeepLinkHelpers = {
  /**
   * Open an email client with pre-filled content
   */
  openEmail: async (options: {
    to?: string;
    subject?: string;
    body?: string;
    cc?: string;
    bcc?: string;
  }): Promise<OpenDeepLinkResult> => {
    const params = new URLSearchParams();
    if (options.subject) params.append('subject', options.subject);
    if (options.body) params.append('body', options.body);
    if (options.cc) params.append('cc', options.cc);
    if (options.bcc) params.append('bcc', options.bcc);
    
    const url = `mailto:${options.to || ''}${params.toString() ? '?' + params.toString() : ''}`;
    return WebFDeepLink.openDeepLink({ url });
  },

  /**
   * Open phone dialer with a number
   */
  openPhone: async (phoneNumber: string): Promise<OpenDeepLinkResult> => {
    const url = `tel:${phoneNumber}`;
    return WebFDeepLink.openDeepLink({ url });
  },

  /**
   * Open SMS app with pre-filled content
   */
  openSMS: async (options: {
    phoneNumber?: string;
    message?: string;
  }): Promise<OpenDeepLinkResult> => {
    const url = `sms:${options.phoneNumber || ''}${options.message ? '?body=' + encodeURIComponent(options.message) : ''}`;
    return WebFDeepLink.openDeepLink({ url });
  },

  /**
   * Open a location in maps
   */
  openMaps: async (options: {
    latitude?: number;
    longitude?: number;
    query?: string;
  }): Promise<OpenDeepLinkResult> => {
    let url: string;
    
    if (options.latitude && options.longitude) {
      url = `geo:${options.latitude},${options.longitude}`;
      if (options.query) {
        url += `?q=${encodeURIComponent(options.query)}`;
      }
    } else if (options.query) {
      url = `geo:0,0?q=${encodeURIComponent(options.query)}`;
    } else {
      throw new Error('Either coordinates or query must be provided');
    }

    return WebFDeepLink.openDeepLink({ url });
  },

  /**
   * Open App Store (iOS) or Play Store (Android)
   */
  openAppStore: async (appId: string, platform: 'ios' | 'android' = 'ios'): Promise<OpenDeepLinkResult> => {
    const url = platform === 'ios' 
      ? `itms-apps://itunes.apple.com/app/id${appId}`
      : `market://details?id=${appId}`;
    
    const fallbackUrl = platform === 'ios'
      ? `https://apps.apple.com/app/id${appId}`
      : `https://play.google.com/store/apps/details?id=${appId}`;

    return WebFDeepLink.openDeepLink({ url, fallbackUrl });
  },

  /**
   * Open a web URL in the default browser
   */
  openWebURL: async (url: string): Promise<OpenDeepLinkResult> => {
    // Ensure URL has a protocol
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url;
    }
    return WebFDeepLink.openDeepLink({ url });
  },

  /**
   * Open a custom app scheme
   */
  openCustomScheme: async (
    scheme: string, 
    fallbackUrl?: string
  ): Promise<OpenDeepLinkResult> => {
    return WebFDeepLink.openDeepLink({ 
      url: scheme, 
      fallbackUrl: fallbackUrl || window.location.href 
    });
  }
};

/**
 * React hook for deep link functionality (if using React)
 */
export const useWebFDeepLink = () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const React = (globalThis as any)?.React;
  const useState = React?.useState || (() => [null, () => {}]);

  const [isProcessing, setIsProcessing] = useState(false);
  const [lastResult, setLastResult] = useState(null);

  const openDeepLink = async (options: OpenDeepLinkOptions): Promise<OpenDeepLinkResult> => {
    setIsProcessing(true);
    try {
      const result = await WebFDeepLink.openDeepLink(options);
      setLastResult(result);
      return result;
    } finally {
      setIsProcessing(false);
    }
  };

  return {
    openDeepLink,
    isProcessing,
    lastResult,
    isAvailable: WebFDeepLink.isAvailable()
  };
};

// Common URL schemes for popular applications
export const COMMON_URL_SCHEMES = {
  /** WhatsApp messaging */
  WHATSAPP: 'whatsapp://',
  /** Spotify music */
  SPOTIFY: 'spotify://',
  /** Instagram social */
  INSTAGRAM: 'instagram://',
  /** Twitter social */
  TWITTER: 'twitter://',
  /** YouTube videos */
  YOUTUBE: 'youtube://',
  /** Email client */
  MAILTO: 'mailto:',
  /** Phone dialer */
  TEL: 'tel:',
  /** SMS messaging */
  SMS: 'sms:',
  /** Maps application */
  MAPS: 'maps://',
  /** Geographic coordinates */
  GEO: 'geo:',
  /** App Store (iOS) */
  APP_STORE: 'itms-apps://',
  /** Google Play Store (Android) */
  PLAY_STORE: 'market://',
} as const;

/**
 * Default export for convenience
 */
export default WebFDeepLink;