import { defineComponent, h, PropType, ref } from 'vue';
import { debugLog } from './debug';

export interface HybridRouterChangeEvent extends Event {
  readonly state: any;
  readonly kind: 'didPushNext' | 'didPush' | 'didPop' | 'didPopNext';
  readonly path: string;
}

export type HybridRouterChangeEventHandler = (event: HybridRouterChangeEvent) => void;

export interface WebFHybridRouterProps {
  path: string;
  title?: string;
  theme?: 'material' | 'cupertino';
  onScreen?: HybridRouterChangeEventHandler;
  offScreen?: HybridRouterChangeEventHandler;
}

export const WebFRouterLink = defineComponent({
  name: 'WebFRouterLink',
  props: {
    path: { type: String, required: true },
    title: { type: String, required: false },
    theme: { type: String as PropType<'material' | 'cupertino'>, required: false },
    onScreen: { type: Function as PropType<HybridRouterChangeEventHandler>, required: false },
    offScreen: { type: Function as PropType<HybridRouterChangeEventHandler>, required: false },
  },
  setup(props, { slots }) {
    const isRender = ref(false);

    const handleOnScreen = (event: Event) => {
      isRender.value = true;
      debugLog('router-link:onscreen', {
        elementPath: props.path,
        detail: (event as any)?.detail,
      });
      props.onScreen?.(event as unknown as HybridRouterChangeEvent);
    };

    const handleOffScreen = (event: Event) => {
      debugLog('router-link:offscreen', {
        elementPath: props.path,
        detail: (event as any)?.detail,
      });
      props.offScreen?.(event as unknown as HybridRouterChangeEvent);
    };

    return () =>
      h(
        'webf-router-link',
        {
          path: props.path,
          title: props.title,
          theme: props.theme,
          onOnscreen: handleOnScreen,
          onOffscreen: handleOffScreen,
        },
        isRender.value ? slots.default?.() : undefined
      );
  },
});
