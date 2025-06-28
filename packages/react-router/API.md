# API Reference

## Components

### `<Routes>`

The container component that provides routing context to all child routes.

```tsx
interface RoutesProps {
  children: React.ReactNode;
}
```

### `<Route>`

Defines a single route in your application.

```tsx
interface RouteProps {
  path: string;              // The path pattern for this route
  element: React.ReactNode;  // Component to render when route is active
  prerender?: boolean;       // Whether to pre-render this route (default: false)
}
```

## Hooks

### `useNavigate()`

Returns an object with navigation methods.

```tsx
function useNavigate(): NavigationMethods

interface NavigationMethods {
  navigate: NavigateFunction;
  pop: (result?: any) => void;
  popUntil: (path: string) => void;
  popAndPush: (path: string, state?: any) => Promise<void>;
  pushAndRemoveUntil: (newPath: string, untilPath: string, state?: any) => Promise<void>;
  canPop: () => boolean;
  maybePop: (result?: any) => boolean;
}

type NavigateFunction = {
  (to: string, options?: NavigateOptions): void;
  (delta: number): void;
}

interface NavigateOptions {
  replace?: boolean;
  state?: any;
}
```

### `useLocation()`

Returns the current location object.

```tsx
function useLocation(): Location & { isActive: boolean }

interface Location {
  pathname: string;    // Current route path
  state: any;         // State passed during navigation
  key?: string;       // Unique key for this location
  isActive: boolean;  // Whether this is the active route
}
```

### `useRouteContext()`

Returns detailed route context information.

```tsx
function useRouteContext(): RouteContext & { isActive: boolean }

interface RouteContext<S = any> {
  path: string | undefined;
  params: S | undefined;
  activePath: string | undefined;
  routeEventKind?: 'didPushNext' | 'didPush' | 'didPop' | 'didPupNext';
  isActive: boolean;
}
```

### `useRoutes()`

Creates routes from a configuration array.

```tsx
function useRoutes(routes: RouteObject[]): React.ReactElement | null

interface RouteObject {
  path: string;
  element: React.ReactNode;
  prerender?: boolean;
  children?: RouteObject[];  // Not supported yet
}
```

## WebFRouter API

Direct access to the underlying router.

```tsx
const WebFRouter: {
  // Properties
  state: any;                                    // Current route state
  path: string;                                  // Current route path
  
  // Navigation methods
  push(path: string, state?: any): Promise<void>;
  replace(path: string, state?: any): void;
  back(): void;
  pop(result?: any): void;
  popUntil(path: string): void;
  popAndPushNamed(path: string, state?: any): Promise<void>;
  pushNamedAndRemoveUntilRoute(newPath: string, untilPath: string, state?: any): Promise<void>;
  canPop(): boolean;
  maybePop(result?: any): boolean;
}
```

## Event Types

### `HybridRouterChangeEvent`

Event fired when route changes occur.

```tsx
interface HybridRouterChangeEvent extends SyntheticEvent {
  readonly state: any;
  readonly kind: 'didPushNext' | 'didPush' | 'didPop' | 'didPupNext';
  readonly path: string;
}
```

## Component Types

### `WebFRouterLink`

Internal component used by Route for WebF integration.

```tsx
interface WebFHybridRouterProps {
  path: string;
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
  children?: ReactNode;
}
```

## Type Definitions

### Navigation Types

```tsx
// Navigation function overloads
interface NavigateFunction {
  (to: string, options?: NavigateOptions): void;
  (delta: number): void;
}

// Navigation options
interface NavigateOptions {
  replace?: boolean;  // Replace current entry instead of pushing
  state?: any;       // State to pass to the new route
}
```

### Route Event Types

```tsx
type RouteEventKind = 'didPushNext' | 'didPush' | 'didPop' | 'didPupNext';

// Event handler type
type HybridRouterChangeEventHandler = EventHandler<HybridRouterChangeEvent>;
```

## Usage Examples

### Basic Navigation

```tsx
const { navigate } = useNavigate();

// Simple navigation
navigate('/home');

// With options
navigate('/profile', { 
  replace: true,
  state: { userId: '123' }
});

// Relative navigation
navigate(-1); // Go back
```

### Advanced Navigation

```tsx
const nav = useNavigate();

// Pop until specific route
nav.popUntil('/dashboard');

// Pop and push in one operation
await nav.popAndPush('/new-route', { data: 'value' });

// Push and remove all until root
await nav.pushAndRemoveUntil('/success', '/');

// Conditional pop
if (nav.canPop()) {
  nav.pop();
}

// Maybe pop (returns false if can't pop)
const didPop = nav.maybePop();
```

### Accessing Route Information

```tsx
// Get current location
const location = useLocation();
console.log(location.pathname); // Current path
console.log(location.state);    // Passed state
console.log(location.isActive); // Is this the active route

// Get route context
const context = useRouteContext();
console.log(context.path);           // Route path
console.log(context.params);         // Route parameters/state
console.log(context.activePath);     // Currently active path
console.log(context.routeEventKind); // Last route event type
```

### Pre-rendering for Performance

```tsx
// Enable pre-rendering on specific routes
<Routes>
  <Route path="/" element={<Home />} />
  <Route path="/heavy" element={<HeavyComponent />} prerender />
</Routes>

// Or with useRoutes
const routes = useRoutes([
  { path: '/', element: <Home /> },
  { path: '/heavy', element: <HeavyComponent />, prerender: true }
]);
```