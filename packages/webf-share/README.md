# @openwebf/webf-share

🚀 **Ready-to-use WebF Share integration library** - Share content and save screenshots with zero configuration!

Effortlessly share images, text, and save screenshots to device storage with a simple, type-safe API.

## ✨ **Features**

- 🎯 **Zero configuration** - Just install and use
- ✅ **TypeScript support** with full type safety
- 📸 **Easy screenshot capture** from canvas, images, or DOM elements
- 🔗 **Native sharing** through platform share dialog
- 💾 **Save to device** storage with custom filenames
- 🖼️ **Preview generation** for temporary display
- ⚛️ **React hook** included for React applications
- 🛡️ **Robust error handling** 
- 📱 **Cross-platform** - Works on iOS, Android, and macOS

## 📦 **Installation**

```bash
npm install @openwebf/webf-share
# or
yarn add @openwebf/webf-share
# or
pnpm add @openwebf/webf-share
```

**Requirements:**
- WebF application with `webf_share` Flutter module installed  
- Automatically includes `@openwebf/webf-enterprise-typings` for complete WebF type coverage

## 🚀 **Quick Start**

### Share Text

```typescript
import { WebFShare } from '@openwebf/webf-share';

// Simple text sharing
await WebFShare.shareText({
  title: 'Check this out!',
  text: 'Amazing content from my WebF app',
  url: 'https://openwebf.com'
});
```

### Share Screenshots

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

// Capture and share canvas content
const canvas = document.querySelector('canvas');
const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);

await WebFShare.shareImage({
  imageData,
  text: 'Check out this amazing creation!',
  subject: 'My WebF App Creation'
});
```

### Save Screenshots

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

// Save any DOM element as screenshot
const targetElement = document.querySelector('#screenshot-area');
const imageData = await ShareHelpers.elementToArrayBuffer(targetElement);

const result = await WebFShare.saveScreenshot({
  imageData,
  filename: 'my_screenshot'
});

if (result.success) {
  console.log('Screenshot saved to:', result.filePath);
}
```

### React Integration

```typescript
import { useWebFShare, ShareHelpers } from '@openwebf/webf-share';

function ShareButton() {
  const { shareImage, saveScreenshot, isSharing, isSaving } = useWebFShare();

  const handleShare = async () => {
    const canvas = document.querySelector('canvas');
    const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
    
    await shareImage({
      imageData,
      text: 'Shared from my WebF app!'
    });
  };

  return (
    <button onClick={handleShare} disabled={isSharing}>
      {isSharing ? 'Sharing...' : 'Share Image'}
    </button>
  );
}
```

## 📚 **API Reference**

### Main API

#### `WebFShare.shareText(options)`

Share text content through the platform's native share dialog.

```typescript
await WebFShare.shareText({
  title: 'My App',
  text: 'Check out this awesome content!',
  url: 'https://example.com'
});
```

#### `WebFShare.shareImage(options)`

Share an image with text through the platform's native share dialog.

```typescript
const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);

await WebFShare.shareImage({
  imageData,
  text: 'Amazing creation!',
  subject: 'My App - Screenshot'
});
```

#### `WebFShare.saveScreenshot(options)`

Save an image to device storage.

```typescript
const result = await WebFShare.saveScreenshot({
  imageData,
  filename: 'custom_name' // optional
});

console.log('Saved to:', result.filePath);
```

#### `WebFShare.saveForPreview(options)`

Save an image for temporary preview display.

```typescript
const result = await WebFShare.saveForPreview({
  imageData,
  filename: 'preview'
});

// Display the preview
const img = document.createElement('img');
img.src = result.filePath; // file:///tmp/preview.png
document.body.appendChild(img);
```

#### `WebFShare.isAvailable()`

Check if WebF Share module is available.

```typescript
if (WebFShare.isAvailable()) {
  // Safe to use sharing features
}
```

### Helper Functions

#### Image Conversion

```typescript
// Convert canvas to ArrayBuffer
const imageData = await ShareHelpers.canvasToArrayBuffer(canvas, 0.8);

// Convert image element to ArrayBuffer
const imageData = await ShareHelpers.imageToArrayBuffer(imgElement, 0.8);

// Convert video frame to ArrayBuffer
const imageData = await ShareHelpers.videoToArrayBuffer(videoElement, 0.8);

// Convert DOM element to ArrayBuffer (WebF specific)
const imageData = await ShareHelpers.elementToArrayBuffer(divElement, 0.8);

// Convert blob to ArrayBuffer
const imageData = await ShareHelpers.blobToArrayBuffer(blob);
```

#### Utility Functions

```typescript
// Generate timestamp-based filename
const filename = ShareHelpers.generateFilename('screenshot'); // screenshot_2023-10-15T14-30-45-123Z

// Create text share object
const shareData = ShareHelpers.createTextShare('Title', 'Content', 'https://url.com');
```

### React Hook

```typescript
const {
  shareText,        // Function to share text
  shareImage,       // Function to share images
  saveScreenshot,   // Function to save screenshots
  saveForPreview,   // Function to save for preview
  isSharing,        // Boolean indicating sharing in progress
  isSaving,         // Boolean indicating saving in progress
  lastResult,       // Last operation result
  isAvailable       // Whether WebF Share is available
} = useWebFShare();
```

## 🎯 **Real-World Examples**

### Gaming App Screenshot Sharing

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

class GameScreenshot {
  async shareHighScore(canvas: HTMLCanvasElement, score: number) {
    const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
    
    return WebFShare.shareImage({
      imageData,
      text: `🎮 Just scored ${score} points in this awesome game! Can you beat it?`,
      subject: 'My High Score Achievement'
    });
  }
  
  async saveProgressScreenshot(canvas: HTMLCanvasElement, level: number) {
    const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
    const filename = ShareHelpers.generateFilename(`level_${level}_progress`);
    
    return WebFShare.saveScreenshot({ imageData, filename });
  }
}
```

### Social Media Integration

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

const SocialShareComponent = ({ contentElement }) => {
  const shareToSocial = async () => {
    // Capture the content area
    const imageData = await ShareHelpers.elementToArrayBuffer(contentElement);
    
    // Share with social context
    await WebFShare.shareImage({
      imageData,
      text: 'Check out this amazing content from my WebF app! 🚀\n\nBuilt with @openwebf - bringing web tech to native apps!',
      subject: 'Amazing WebF Content'
    });
  };

  return <button onClick={shareToSocial}>Share to Social Media</button>;
};
```

### Document Preview System

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

class DocumentPreview {
  private previews: string[] = [];
  
  async createPreview(canvas: HTMLCanvasElement, docName: string): Promise<string | null> {
    try {
      const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
      
      const result = await WebFShare.saveForPreview({
        imageData,
        filename: `${docName}_preview`
      });
      
      if (result.success && result.filePath) {
        this.previews.push(result.filePath);
        return result.filePath;
      }
      
      return null;
    } catch (error) {
      console.error('Failed to create preview:', error);
      return null;
    }
  }
  
  displayPreviews(container: HTMLElement) {
    container.innerHTML = '';
    
    this.previews.forEach((filePath, index) => {
      const img = document.createElement('img');
      img.src = filePath;
      img.className = 'preview-thumbnail';
      img.onclick = () => this.openFullPreview(filePath);
      container.appendChild(img);
    });
  }
  
  private openFullPreview(filePath: string) {
    // Open preview in full size
    const modal = document.createElement('div');
    modal.className = 'preview-modal';
    modal.innerHTML = `<img src="${filePath}" style="max-width: 100%; max-height: 100%;">`;
    modal.onclick = () => modal.remove();
    document.body.appendChild(modal);
  }
}
```

### E-commerce Product Sharing

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

const ProductShare = ({ productCanvas, productInfo }) => {
  const shareProduct = async () => {
    const imageData = await ShareHelpers.canvasToArrayBuffer(productCanvas);
    
    await WebFShare.shareImage({
      imageData,
      text: `🛍️ Check out this ${productInfo.name}!\n\n💰 Only $${productInfo.price}\n⭐ ${productInfo.rating}/5 stars\n\nGet it now: ${productInfo.url}`,
      subject: `${productInfo.name} - Special Offer`
    });
  };

  const saveProductImage = async () => {
    const imageData = await ShareHelpers.canvasToArrayBuffer(productCanvas);
    const filename = `${productInfo.name.replace(/\s+/g, '_')}_${Date.now()}`;
    
    const result = await WebFShare.saveScreenshot({ imageData, filename });
    
    if (result.success) {
      alert(`Product image saved: ${result.platformInfo || result.filePath}`);
    }
  };

  return (
    <div className="product-actions">
      <button onClick={shareProduct}>Share Product</button>
      <button onClick={saveProductImage}>Save Image</button>
    </div>
  );
};
```

### Art/Drawing App Integration

```typescript
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

class ArtAppSharing {
  async shareArtwork(canvas: HTMLCanvasElement, artworkTitle: string, artistName: string) {
    const imageData = await ShareHelpers.canvasToArrayBuffer(canvas, 0.9); // High quality
    
    return WebFShare.shareImage({
      imageData,
      text: `🎨 "${artworkTitle}" by ${artistName}\n\nCreated with our amazing WebF art app! ✨\n\n#DigitalArt #WebFApp #Creative`,
      subject: `Artwork: ${artworkTitle}`
    });
  }
  
  async saveToGallery(canvas: HTMLCanvasElement, artworkTitle: string, artistName: string) {
    const imageData = await ShareHelpers.canvasToArrayBuffer(canvas, 1.0); // Best quality for saving
    const filename = `${artistName}_${artworkTitle}_${ShareHelpers.generateFilename()}`.replace(/\s+/g, '_');
    
    return WebFShare.saveScreenshot({ imageData, filename });
  }
  
  async createThumbnail(canvas: HTMLCanvasElement, artworkId: string) {
    // Create smaller thumbnail for gallery
    const thumbnailCanvas = document.createElement('canvas');
    const ctx = thumbnailCanvas.getContext('2d');
    
    thumbnailCanvas.width = 200;
    thumbnailCanvas.height = 200;
    
    ctx.drawImage(canvas, 0, 0, 200, 200);
    
    const imageData = await ShareHelpers.canvasToArrayBuffer(thumbnailCanvas, 0.7);
    
    return WebFShare.saveForPreview({
      imageData,
      filename: `thumb_${artworkId}`
    });
  }
}
```

## ⚠️ **Error Handling**

```typescript
import { WebFShare, WebFNotAvailableError } from '@openwebf/webf-share';

const safeShare = async () => {
  try {
    // Always check availability first
    if (!WebFShare.isAvailable()) {
      alert('Sharing not available in this environment');
      return;
    }

    const success = await WebFShare.shareText({
      title: 'My App',
      text: 'Check this out!'
    });

    if (!success) {
      console.log('User cancelled share or sharing failed');
    }
  } catch (error) {
    if (error instanceof WebFNotAvailableError) {
      console.error('WebF not available:', error.message);
    } else {
      console.error('Unexpected error:', error);
    }
  }
};
```

## 🔧 **Migration from Manual Usage**

### Before (Manual API calls)
```typescript
// ❌ Manual, complex, error-prone
const canvas = document.querySelector('canvas');
const blob = await canvas.toBlob(window.devicePixelRatio || 1.0);
const arrayBuffer = await blob.arrayBuffer();

const result = await window.webf.invokeModuleAsync(
  'Share',
  'share',
  arrayBuffer,
  'Check this out!',
  'My App - Screenshot'
);
```

### After (This Library)
```typescript
// ✅ Simple, type-safe, error-handled
import { WebFShare, ShareHelpers } from '@openwebf/webf-share';

const canvas = document.querySelector('canvas');
const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);

await WebFShare.shareImage({
  imageData,
  text: 'Check this out!',
  subject: 'My App - Screenshot'
});
```

## 💡 **Best Practices**

1. **Always check availability** before using:
   ```typescript
   if (!WebFShare.isAvailable()) {
     // Show fallback UI
   }
   ```

2. **Use appropriate image quality** based on use case:
   ```typescript
   // For sharing (smaller file)
   const imageData = await ShareHelpers.canvasToArrayBuffer(canvas, 0.8);
   
   // For saving (best quality)
   const imageData = await ShareHelpers.canvasToArrayBuffer(canvas, 1.0);
   ```

3. **Provide meaningful filenames**:
   ```typescript
   const filename = `${appName}_${feature}_${ShareHelpers.generateFilename()}`;
   ```

4. **Handle errors gracefully** with user feedback:
   ```typescript
   const result = await WebFShare.saveScreenshot({ imageData, filename });
   if (result.success) {
     showToast('Screenshot saved successfully!');
   } else {
     showToast('Failed to save screenshot: ' + result.error);
   }
   ```

## 📄 **License**

MIT - see the main WebF project for details.

## 🤝 **Contributing**

This package is part of the [WebF project](https://github.com/openwebf/webf). Contributions welcome!