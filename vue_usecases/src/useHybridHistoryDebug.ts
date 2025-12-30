import { onMounted, onUnmounted, ref } from 'vue';
import { WebFRouter } from '@openwebf/vue-router';

function snapshot() {
  return {
    path: WebFRouter.path,
    state: WebFRouter.state,
    stack: WebFRouter.stack.map((e) => ({ path: e.path, state: e.state })),
  };
}

export function useHybridHistoryDebug() {
  const debug = ref(snapshot());

  const handle = () => {
    debug.value = snapshot();
  };

  onMounted(() => {
    document.addEventListener('hybridrouterchange', handle);
    handle();
  });

  onUnmounted(() => {
    document.removeEventListener('hybridrouterchange', handle);
  });

  return debug;
}

