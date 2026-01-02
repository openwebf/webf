import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import { flutterAttached } from '@openwebf/vue-core-ui';

// @ts-ignore
// globalThis.__WEBF_VUE_ROUTER_DEBUG__ = true;

createApp(App).directive('flutter-attached', flutterAttached).mount('#app')
