import { defineComponent, h, PropType, ref, onMounted, onUnmounted, inject, computed, ComputedRef } from 'vue';
import { debugLog } from './debug';
import { isWebF } from '../platform';
import type { RouteContext } from '../types';

export interface HybridRouterChangeEvent extends Event {
  readonly state: any;
  readonly kind: 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext';
  readonly path: string;
}

export type HybridRouterChangeEventHandler = (event: HybridRouterChangeEvent) => void;

export interface HybridRouterPrerenderingEvent extends Event {}

export type HybridRouterPrerenderingEventHandler = (event: HybridRouterPrerenderingEvent) => void;

export interface WebFHybridRouterProps {
  path: string;
  title?: string;
  theme?: 'material' | 'cupertino';
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
  onPrerendering?: HybridRouterPrerenderingEventHandler;
}

export const WebFRouterLink = defineComponent({
  name: 'WebFRouterLink',
  props: {
    path: { type: String, required: true },
    title: { type: String, required: false },
    theme: { type: String as PropType<'material' | 'cupertino'>, required: false },
    onScreen: { type: Function as PropType<HybridRouterChangeEventHandler>, required: false },
    offScreen: { type: Function as PropType<HybridRouterChangeEventHandler>, required: false },
    onPrerendering: { type: Function as PropType<HybridRouterPrerenderingEventHandler>, required: false },
  },
  setup(props, { slots }) {
    const isWebFPlatform = isWebF();
    // In browser mode, render immediately; in WebF mode, wait for prerendering event
    const isRender = ref(!isWebFPlatform);

    // Inject route context to determine visibility in browser mode
    const routeSpecificContext = inject<ComputedRef<RouteContext> | undefined>('route-specific-context', undefined);
    const globalRouteContext = inject<RouteContext | undefined>('route-context', undefined);

    // In browser mode, determine if this route should be visible
    const isActiveInBrowser = computed(() => {
      if (isWebFPlatform) return true; // WebF handles visibility via custom element

      // Check route-specific context first (provided by RouteContextProvider)
      if (routeSpecificContext?.value) {
        const ctx = routeSpecificContext.value;
        // Route is active if its mountedPath matches the global activePath
        return ctx.activePath === ctx.mountedPath || ctx.activePath === props.path;
      }

      // Fall back to global route context
      if (globalRouteContext) {
        return globalRouteContext.activePath === props.path ||
               globalRouteContext.mountedPath === props.path;
      }

      // If no context, default to visible (standalone usage)
      return true;
    });

    const handleOnScreen = (event: Event) => {
      isRender.value = true;
      debugLog('router-link:onscreen', {
        elementPath: props.path,
        detail: (event as any)?.detail,
      });
      props.onScreen?.(event as unknown as HybridRouterChangeEvent);
    };

    const handlePrerendering = (event: Event) => {
      isRender.value = true;
      debugLog('router-link:prerendering', {
        elementPath: props.path,
        detail: (event as any)?.detail,
      });
      props.onPrerendering?.(event as unknown as HybridRouterPrerenderingEvent);
    };

    const handleOffScreen = (event: Event) => {
      debugLog('router-link:offscreen', {
        elementPath: props.path,
        detail: (event as any)?.detail,
      });
      props.offScreen?.(event as unknown as HybridRouterChangeEvent);
    };

    // Browser-specific: simulate onScreen event on mount
    onMounted(() => {
      if (!isWebFPlatform) {
        // In browser mode, fire onScreen event (content already rendered)
        const syntheticEvent = new CustomEvent('onscreen', {
          detail: { path: props.path },
        }) as unknown as HybridRouterChangeEvent;
        props.onScreen?.(syntheticEvent);
      }
    });

    // Browser-specific: simulate offScreen event on unmount
    onUnmounted(() => {
      if (!isWebFPlatform) {
        const syntheticEvent = new CustomEvent('offscreen', {
          detail: { path: props.path },
        }) as unknown as HybridRouterChangeEvent;
        props.offScreen?.(syntheticEvent);
      }
    });

    return () => {
      // WebF platform: use custom webf-router-link element
      if (isWebFPlatform) {
        return h(
          'webf-router-link',
          {
            path: props.path,
            title: props.title,
            theme: props.theme,
            onOnscreen: handleOnScreen,
            onPrerendering: handlePrerendering,
            onOffscreen: handleOffScreen,
          },
          isRender.value ? slots.default?.() : undefined
        );
      }

      // Browser platform: use standard div with data attributes
      // Only show content when this route is active
      const shouldShow = isActiveInBrowser.value;

      return h(
        'div',
        {
          'data-router-link': '',
          'data-path': props.path,
          'data-title': props.title,
          style: shouldShow ? { display: 'contents' } : { display: 'none' },
        },
        shouldShow ? slots.default?.() : undefined
      );
    };
  },
});
