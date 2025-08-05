import { defineComponent, provide, reactive, onMounted, onUnmounted, h } from 'vue';
import { WebFRouter } from '../router/WebFRouter';
import { RouteParams, matchPath } from '../utils/pathMatcher';
import type { RouteContext, HybridRouterChangeEvent } from '../types';

/**
 * Routes component - provides routing context to child Route components
 * 
 * This component listens for hybrid router change events and provides
 * route context to all child Route components.
 */
export const Routes = defineComponent({
  name: 'Routes',
  setup(_, { slots }) {
    
    // Global route state - exactly like React version
    const routeState = reactive<RouteContext>({
      path: undefined,
      activePath: WebFRouter.path, // Initialize with current path - no normalization
      params: undefined,
      routeParams: undefined,
      routeEventKind: undefined
    });

    // Provide route context to child components
    provide('route-context', routeState);

    // Handle route change events
    const handleRouteChange = (event: Event) => {
      const routeEvent = event as unknown as HybridRouterChangeEvent;
      const eventDetail = (event as any).detail;
      
      // Only update activePath for push events - exactly like React version
      const newActivePath = (routeEvent.kind === 'didPushNext' || routeEvent.kind === 'didPush')
        ? routeEvent.path
        : routeState.activePath;
        
      // Extract route parameters
      let routeParams = eventDetail?.params || undefined;
      if (!routeParams && newActivePath) {
        // Try to extract parameters from registered route patterns
        const registeredRoutes = Array.from(document.querySelectorAll('webf-router-link'));
        for (const routeElement of registeredRoutes) {
          const routePath = routeElement.getAttribute('path');
          if (routePath && routePath.includes(':')) {
            const match = matchPath(routePath, newActivePath);
            if (match) {
              routeParams = match.params;
              break;
            }
          }
        }
      }
      
      const eventState = eventDetail?.state || routeEvent.state;

      // Update state based on event kind
      routeState.path = routeEvent.path;
      routeState.activePath = newActivePath;
      routeState.params = eventState;
      routeState.routeParams = routeParams;
      routeState.routeEventKind = routeEvent.kind;
      
    };

    // Listen to hybridrouterchange event
    onMounted(() => {
      document.addEventListener('hybridrouterchange', handleRouteChange);
    });

    onUnmounted(() => {
      document.removeEventListener('hybridrouterchange', handleRouteChange);
    });

    return () => {
      const children = slots.default?.();
      return h('div', {}, children);
    };
  }
});