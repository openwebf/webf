import { createApp } from 'vue'
import App from './App.vue'
import './main.css';
import store from './store';

createApp(App).use(store).mount('#app');

console.log('loaded');