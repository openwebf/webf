import { defineComponent, computed, ref, h, PropType } from 'vue';
import { WebFRouterLink } from '../utils/RouterLink';

/**
 * Route Component
 *
 * Responsible for managing page rendering and delegating mount/lifecycle to `webf-router-link`.
 */
export const Route = defineComponent({
  name: 'Route',
  props: {
    title: {
      type: String,
      required: false,
    },
    path: {
      type: String,
      required: true
    },
    mountedPath: {
      type: String,
      required: false,
    },
    prerender: {
      type: Boolean,
      default: false
    },
    element: {
      type: [Object, String, Function] as PropType<any>,
      required: true
    },
    theme: {
      type: String as PropType<'material' | 'cupertino'>,
      required: false,
    },
  },
  setup(props) {
    const hasRendered = ref(false);
    const shouldRenderChildren = computed(() => props.prerender || hasRendered.value);

    const handleOnScreen = () => {
      hasRendered.value = true;
    };

    const handleOffScreen = () => {};

    return () => {
      const pathToMount = props.mountedPath ?? props.path;

      return h(
        WebFRouterLink,
        {
          path: pathToMount,
          title: props.title,
          theme: props.theme,
          onPrerendering: handleOnScreen,
          onScreen: handleOnScreen,
          offScreen: handleOffScreen,
        },
        {
          default: () => (shouldRenderChildren.value ? h(props.element as any) : null),
        }
      );
    };
  }
});
