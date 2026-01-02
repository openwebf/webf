/**
 * Vue directive to listen to WebF Flutter attachment lifecycle events.
 *
 * Usage:
 *   app.directive('flutter-attached', flutterAttached)
 *
 * Template:
 *   <div v-flutter-attached="onAttached" />
 *   <div v-flutter-attached="{ onAttached, onDetached }" />
 */

const STATE = Symbol('webf.flutterAttached');

function normalize(value) {
  if (typeof value === 'function') {
    return { onAttached: value, onDetached: undefined };
  }
  if (value && typeof value === 'object') {
    return {
      onAttached: value.onAttached ?? value.attached,
      onDetached: value.onDetached ?? value.detached,
    };
  }
  return { onAttached: undefined, onDetached: undefined };
}

export const flutterAttached = {
  mounted(el, binding) {
    const callbacks = normalize(binding.value);
    const state = {
      callbacks,
      handleAttached(event) {
        state.callbacks.onAttached?.(event);
      },
      handleDetached(event) {
        state.callbacks.onDetached?.(event);
      },
    };

    el[STATE] = state;
    el.addEventListener('onscreen', state.handleAttached);
    el.addEventListener('offscreen', state.handleDetached);
  },

  updated(el, binding) {
    const state = el[STATE];
    if (!state) return;
    state.callbacks = normalize(binding.value);
  },

  unmounted(el) {
    const state = el[STATE];
    if (!state) return;
    el.removeEventListener('onscreen', state.handleAttached);
    el.removeEventListener('offscreen', state.handleDetached);
    delete el[STATE];
  },
};

export const vFlutterAttached = flutterAttached;

