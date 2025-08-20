import { defineComponent, computed, ref, inject, provide, h, PropType, Component } from 'vue';
import { matchPath } from '../utils/pathMatcher';
import type { RouteContext } from '../types';

/**
 * Route component - represents a single route that conditionally renders its element
 * 
 * Props:
 * - path: Route pattern (e.g., "/user/:id")
 * - element: Component to render when route is active
 * - title: Optional title for the route
 * - prerender: Whether to mount the component immediately
 */
export const Route = defineComponent({
  name: 'Route',
  props: {
    path: {
      type: String,
      required: true
    },
    element: {
      type: [Object, String] as PropType<Component | string>,
      required: true
    },
    title: {
      type: String,
      required: false
    },
    prerender: {
      type: Boolean,
      default: false
    }
  },
  setup(props) {
    
    // Inject route context from parent Routes component
    const routeContext = inject<RouteContext>('route-context');

    // Local state
    const isMounted = ref(props.prerender || false);

    // Check if this route is active
    const isActive = computed(() => {
      if (!routeContext) {
        return false;
      }
      
      const currentPath = routeContext.activePath;
      if (!currentPath) {
        return false;
      }
      
      // Check if the route pattern matches
      const match = matchPath(props.path, currentPath);
      const isActive = match !== null;
      return isActive;
    });

    // Handle dynamic component loading
    const computedElement = computed(() => {
      if (typeof props.element === 'string') {
        // If element is a string, return the string for dynamic component resolution
        return props.element;
      }
      return props.element;
    });

    // Handle onscreen event for lazy loading and route activation
    const onScreen = (event: Event) => {
      if (!isMounted.value) {
        isMounted.value = true;
      }
      
      // Trigger hybridrouterchange event to notify Routes component
      // Similar to React's WebFRouterLink behavior
      const hybridRouterEvent = new CustomEvent('hybridrouterchange', {
        detail: {
          kind: 'didPush',
          path: props.path,
          state: (event as any).detail?.state || null,
          params: (event as any).detail?.params || null
        }
      });
      
      document.dispatchEvent(hybridRouterEvent);
    };

    // Provide route-specific context
    if (routeContext) {
      const routeSpecificContext = computed(() => {
        const match = routeContext.activePath ? matchPath(props.path, routeContext.activePath) : null;
        
        if (match) {
          return {
            path: props.path,
            params: routeContext.params,
            routeParams: match.params,
            activePath: routeContext.activePath,
            routeEventKind: routeContext.routeEventKind
          };
        }
        
        return {
          path: props.path,
          params: undefined,
          routeParams: undefined,
          activePath: routeContext.activePath,
          routeEventKind: undefined
        };
      });
      
      provide('route-specific-context', routeSpecificContext);
    }

    return () => {
      
      // Match React behavior: render if mounted (received onscreen event), regardless of route matching
      const shouldRender = isMounted.value;
      
      if (shouldRender) {
        try {
          const component = h(computedElement.value as Component);
          return h('webf-router-link', {
            path: props.path,
            title: props.title,
            onOnscreen: onScreen
          }, [component]);
        } catch (error) {
          return h('webf-router-link', {
            path: props.path,
            title: props.title,
            onOnscreen: onScreen
          }, ['Error loading component']);
        }
      } else {
        return h('webf-router-link', {
          path: props.path,
          title: props.title,
          onOnscreen: onScreen
        }, []);
      }
    };
  }
});