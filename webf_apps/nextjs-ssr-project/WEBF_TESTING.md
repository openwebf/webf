# WebF Next.js Testing Guide

This project tests Next.js features in the WebF runtime environment, specifically focusing on Server Components, Client Components, and React SSR capabilities.

## Features Being Tested

### 1. Server Components (`/server-component`)
- **What it tests**: Components that render entirely on the server
- **Key behaviors**:
  - No JavaScript bundle required for display
  - Static content that doesn't change after initial render
  - Async data fetching during server render
  - Suspense boundaries for loading states

### 2. Client Components (`/client-component`)
- **What it tests**: Interactive components requiring JavaScript hydration
- **Key behaviors**:
  - React hydration on the client side
  - Event handlers and state management
  - Real-time updates (timer component)
  - Interactive buttons and counters

### 3. Hybrid Components (`/hybrid`)
- **What it tests**: Mixed server and client components on the same page
- **Key behaviors**:
  - Server components render immediately
  - Client components require hydration for interactivity
  - Combination of static and dynamic content

## WebF Testing Checklist

### Server Components
- [ ] Page loads without JavaScript enabled
- [ ] Server data displays immediately
- [ ] Timestamps and random numbers remain static
- [ ] No hydration warnings in console
- [ ] Suspense fallbacks work correctly

### Client Components
- [ ] Page shows initial server-rendered content
- [ ] JavaScript hydration occurs after page load
- [ ] Buttons become clickable after hydration
- [ ] Timer starts updating after hydration
- [ ] State updates work correctly
- [ ] Event handlers function properly

### Hybrid Pages
- [ ] Server content displays immediately
- [ ] Client content becomes interactive after hydration
- [ ] No layout shifts during hydration
- [ ] Mixed rendering works seamlessly

### SSR Performance
- [ ] Fast initial page load
- [ ] Server-rendered HTML visible before JS
- [ ] Minimal cumulative layout shift (CLS)
- [ ] Proper meta tags and SEO elements
- [ ] No hydration mismatches

## Running the Tests

### Development Mode
```bash
npm run dev
```
Visit `http://localhost:3000` and navigate through the test pages.

### Production Build
```bash
npm run build
npm start
```
Test the production build to ensure SSR works correctly.

### Testing with WebF
1. Build the application: `npm run build`
2. Start the production server: `npm start`
3. Load the application in WebF runtime
4. Navigate through each test page
5. Check console for any errors or warnings
6. Verify all features work as expected

## Expected Behavior in WebF

### What Should Work
- Server components should render immediately
- Static content should display without JavaScript
- Basic navigation between pages
- CSS styling and layout
- Images and static assets

### What May Require JS Support
- Interactive buttons and counters
- Real-time timer updates
- Form submissions
- Dynamic content updates
- Client-side routing

### Potential Issues to Watch For
- Hydration mismatches
- JavaScript execution errors
- CSS-in-JS compatibility issues
- Event handler binding problems
- State management issues

## Debugging Tips

1. **Check Network Tab**: Verify which assets are loaded
2. **Monitor Console**: Look for hydration warnings or errors
3. **Disable JavaScript**: Test server components in isolation
4. **Compare with Browser**: Verify behavior matches standard browsers
5. **Check HTML Source**: Ensure server-rendered content is present

## Configuration Notes

- `reactStrictMode: true` - Helps catch potential issues
- `experimental.serverActions: true` - Enables server actions
- Source maps enabled in development for debugging
- Headers configured for security and caching

## Next Steps

Based on test results, you may need to:
- Adjust WebF's JavaScript runtime support
- Implement missing React features
- Optimize hydration process
- Fix specific component rendering issues
- Enhance event handling capabilities