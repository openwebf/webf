# @openwebf/webf-deeplink

🚀 **Ready-to-use WebF DeepLink integration library** - No setup required, just install and go!

Open external apps, email clients, phone dialers, maps, and more with a simple, type-safe API.

## ✨ **Features**

- 🎯 **Zero configuration** - Just install and use
- ✅ **TypeScript support** with full type safety
- 🔗 **Built-in helpers** for common scenarios (email, phone, maps, etc.)
- ⚛️ **React hook** included for React applications
- 🛡️ **Error handling** with fallback support
- 📱 **Cross-platform** - Works on iOS, Android, and macOS

## 📦 **Installation**

```bash
npm install @openwebf/webf-deeplink
# or
yarn add @openwebf/webf-deeplink
# or
pnpm add @openwebf/webf-deeplink
```

**Requirements:**
- WebF application with `webf_deeplink` Flutter module installed
- Automatically includes `@openwebf/webf-enterprise-typings` for complete WebF type coverage

## 🚀 **Quick Start**

### Basic Usage

```typescript
import { DeepLinkHelpers } from '@openwebf/webf-deeplink';

// Open email client
await DeepLinkHelpers.openEmail({
  to: 'demo@example.com',
  subject: 'Hello from WebF!',
  body: 'This email was opened from a WebF app.'
});

// Open phone dialer
await DeepLinkHelpers.openPhone('+1234567890');

// Open maps with location
await DeepLinkHelpers.openMaps({
  latitude: 37.7749,
  longitude: -122.4194,
  query: 'San Francisco'
});
```

### Advanced Usage

```typescript
import { WebFDeepLink, DeepLinkHelpers } from '@openwebf/webf-deeplink';

// Custom deep link with fallback
const result = await WebFDeepLink.openDeepLink({
  url: 'whatsapp://send?text=Hello%20from%20WebF!',
  fallbackUrl: 'https://wa.me/?text=Hello%20from%20WebF!'
});

if (result.success) {
  console.log('WhatsApp opened successfully!');
} else {
  console.error('Failed to open WhatsApp:', result.error);
}
```

### React Integration

```typescript
import { useWebFDeepLink } from '@openwebf/webf-deeplink';

function MyComponent() {
  const { openDeepLink, isProcessing, isAvailable } = useWebFDeepLink();

  const handleEmailClick = async () => {
    if (!isAvailable) {
      alert('DeepLink not available');
      return;
    }

    const result = await openDeepLink({
      url: 'mailto:support@example.com?subject=Support%20Request'
    });

    if (result.success) {
      console.log('Email client opened!');
    }
  };

  return (
    <button 
      onClick={handleEmailClick} 
      disabled={isProcessing}
    >
      {isProcessing ? 'Opening...' : 'Send Email'}
    </button>
  );
}
```

## 📚 **API Reference**

### Main API

#### `WebFDeepLink.openDeepLink(options)`

Open any deep link URL with optional fallback.

```typescript
const result = await WebFDeepLink.openDeepLink({
  url: 'custom-app://action?param=value',
  fallbackUrl: 'https://example.com/fallback'
});
```

#### `WebFDeepLink.isAvailable()`

Check if WebF DeepLink module is available.

```typescript
if (WebFDeepLink.isAvailable()) {
  // Safe to use deep links
}
```

### Helper Functions

All helper functions return a `Promise<OpenDeepLinkResult>`:

#### Email
```typescript
await DeepLinkHelpers.openEmail({
  to: 'user@example.com',
  subject: 'Hello!',
  body: 'Message content',
  cc: 'cc@example.com',
  bcc: 'bcc@example.com'
});
```

#### Phone & SMS
```typescript
// Open phone dialer
await DeepLinkHelpers.openPhone('+1234567890');

// Open SMS app
await DeepLinkHelpers.openSMS({
  phoneNumber: '+1234567890',
  message: 'Hello from WebF!'
});
```

#### Maps & Location
```typescript
// Open with coordinates
await DeepLinkHelpers.openMaps({
  latitude: 37.7749,
  longitude: -122.4194,
  query: 'San Francisco'
});

// Open with search query only
await DeepLinkHelpers.openMaps({
  query: 'restaurants near me'
});
```

#### App Stores
```typescript
// iOS App Store
await DeepLinkHelpers.openAppStore('123456789', 'ios');

// Google Play Store
await DeepLinkHelpers.openAppStore('com.example.app', 'android');
```

#### Web URLs
```typescript
// Open in default browser
await DeepLinkHelpers.openWebURL('https://openwebf.com');

// Auto-adds https:// if missing
await DeepLinkHelpers.openWebURL('openwebf.com');
```

#### Custom Schemes
```typescript
await DeepLinkHelpers.openCustomScheme(
  'spotify://playlist/123456',
  'https://open.spotify.com/playlist/123456'
);
```

### React Hook

```typescript
const {
  openDeepLink,    // Function to open deep links
  isProcessing,    // Boolean indicating if a request is in progress
  lastResult,      // Last operation result
  isAvailable      // Whether WebF DeepLink is available
} = useWebFDeepLink();
```

### Constants

```typescript
import { COMMON_URL_SCHEMES } from '@openwebf/webf-deeplink';

// Pre-defined URL schemes
COMMON_URL_SCHEMES.WHATSAPP;   // 'whatsapp://'
COMMON_URL_SCHEMES.SPOTIFY;    // 'spotify://'
COMMON_URL_SCHEMES.MAILTO;     // 'mailto:'
COMMON_URL_SCHEMES.TEL;        // 'tel:'
// ... and more
```

## 🎯 **Common Use Cases**

### Contact Actions

```typescript
import { DeepLinkHelpers } from '@openwebf/webf-deeplink';

const ContactCard = ({ contact }) => {
  return (
    <div>
      <button onClick={() => DeepLinkHelpers.openPhone(contact.phone)}>
        📞 Call
      </button>
      <button onClick={() => DeepLinkHelpers.openSMS({
        phoneNumber: contact.phone,
        message: 'Hi! I found your contact in this WebF app.'
      })}>
        💬 Text
      </button>
      <button onClick={() => DeepLinkHelpers.openEmail({
        to: contact.email,
        subject: 'Hello from WebF App'
      })}>
        ✉️ Email
      </button>
    </div>
  );
};
```

### Social Sharing

```typescript
import { DeepLinkHelpers, COMMON_URL_SCHEMES } from '@openwebf/webf-deeplink';

const SocialShare = ({ message, url }) => {
  const shareToWhatsApp = () => DeepLinkHelpers.openCustomScheme(
    `${COMMON_URL_SCHEMES.WHATSAPP}send?text=${encodeURIComponent(message + ' ' + url)}`
  );

  const shareToTwitter = () => DeepLinkHelpers.openCustomScheme(
    `${COMMON_URL_SCHEMES.TWITTER}post?message=${encodeURIComponent(message)}&url=${encodeURIComponent(url)}`
  );

  return (
    <div>
      <button onClick={shareToWhatsApp}>Share to WhatsApp</button>
      <button onClick={shareToTwitter}>Share to Twitter</button>
    </div>
  );
};
```

### Location Services

```typescript
import { DeepLinkHelpers } from '@openwebf/webf-deeplink';

const LocationButton = ({ place }) => {
  const openInMaps = () => DeepLinkHelpers.openMaps({
    latitude: place.lat,
    longitude: place.lng,
    query: place.name
  });

  return (
    <button onClick={openInMaps}>
      📍 Open in Maps
    </button>
  );
};
```

### App Recommendations

```typescript
import { DeepLinkHelpers } from '@openwebf/webf-deeplink';

const AppRecommendation = ({ appId, platform }) => {
  const openAppStore = () => DeepLinkHelpers.openAppStore(appId, platform);

  return (
    <button onClick={openAppStore}>
      📱 Get this app
    </button>
  );
};
```

## ⚠️ **Error Handling**

```typescript
import { WebFDeepLink, WebFNotAvailableError } from '@openwebf/webf-deeplink';

try {
  const result = await WebFDeepLink.openDeepLink({
    url: 'custom-scheme://action'
  });
  
  if (!result.success) {
    console.error('Deep link failed:', result.error);
  }
} catch (error) {
  if (error instanceof WebFNotAvailableError) {
    console.error('WebF not available:', error.message);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

## 💡 **Tips**

1. **Always check availability** in production:
   ```typescript
   if (!WebFDeepLink.isAvailable()) {
     // Show alternative UI or fallback
   }
   ```

2. **Use helper functions** for common scenarios instead of raw URLs
3. **Provide fallback URLs** for better user experience
4. **Handle errors gracefully** with try-catch blocks

## 📄 **License**

MIT - see the main WebF project for details.

## 🤝 **Contributing**

This package is part of the [WebF project](https://github.com/openwebf/webf). Contributions welcome!