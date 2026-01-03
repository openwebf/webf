# WebF Quickstart - Quick Reference

## Setup Checklist

- [ ] Node.js installed (LTS version)
- [ ] WebF Go downloaded and installed
- [ ] Project created with Vite
- [ ] Dependencies installed (`npm install`)
- [ ] Dev server running (`npm run dev`)
- [ ] App loaded in WebF Go

## Essential Commands

```bash
# Create project
npm create vite@latest my-app
cd my-app
npm install

# Development
npm run dev                    # Desktop (localhost)
npm run dev -- --host          # Mobile (network access)

# Production
npm run build                  # Create production build
npm run preview                # Preview production build
```

## Network URLs by Platform

| Platform | URL Pattern | Example |
|----------|-------------|---------|
| Desktop | `http://localhost:PORT` | `http://localhost:5173` |
| Mobile | `http://NETWORK-IP:PORT` | `http://192.168.1.100:5173` |

**Critical**: Mobile devices cannot access `localhost` - always use Network URL!

## Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Mobile can't connect | Use `npm run dev -- --host` and Network URL |
| Different WiFi | Put both devices on same network |
| Firewall blocks | Allow port 5173 (or your dev server port) |
| HMR not working | Hard refresh or restart dev server |
| DevTools won't connect | Must use desktop Chrome browser |

## Port Configuration

Default Vite port: `5173`

To change port:
```bash
# Option 1: Flag
npm run dev -- --port 3000

# Option 2: vite.config.js
export default {
  server: {
    port: 3000,
    host: true  // Expose on network
  }
}
```

## DevTools Setup

1. Click floating button in WebF Go
2. Click "Copy" → Gets `devtools://...` URL
3. Paste in desktop Chrome
4. Use Console, Elements, Network tabs
5. ⚠️ Breakpoints don't work - use `console.log()`

## Supported Frameworks

All work out-of-the-box with Vite:

- ✅ React (16, 17, 18, 19)
- ✅ Vue (2, 3)
- ✅ Svelte
- ✅ Preact
- ✅ Solid
- ✅ Qwik
- ✅ Vanilla JS

## HTTPS for Mobile Testing

Some APIs require HTTPS. To enable:

```bash
npm install -D @vitejs/plugin-basic-ssl
```

```js
// vite.config.js
import basicSsl from '@vitejs/plugin-basic-ssl'

export default {
  plugins: [basicSsl()],
  server: {
    https: true
  }
}
```

Then use `https://192.168.x.x:5173` instead of `http://`

## Common Vite Flags

```bash
# Network access (mobile testing)
npm run dev -- --host

# Custom port
npm run dev -- --port 3000

# Open browser automatically
npm run dev -- --open

# Clear cache
npm run dev -- --force
```

## File Structure

```
my-webf-app/
├── src/
│   ├── main.jsx          # Entry point
│   ├── App.jsx           # Root component
│   └── index.css         # Global styles
├── public/               # Static assets
├── index.html            # HTML template
├── package.json          # Dependencies
└── vite.config.js        # Vite configuration
```

## Environment Detection

Check if running in WebF:

```javascript
// WebF exposes global WebF object
if (typeof WebF !== 'undefined') {
  console.log('Running in WebF');
} else {
  console.log('Running in browser');
}
```

## Next Skill After Setup

After successful setup, you'll need:

1. **Async Rendering** (`webf-async-rendering`) - Most important concept
2. **API Compatibility** (`webf-api-compatibility`) - What works/doesn't work
3. **Routing Setup** (`webf-routing-setup`) - Multi-screen navigation