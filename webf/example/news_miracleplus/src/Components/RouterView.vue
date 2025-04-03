<template>
    <webf-router-link :path="path" @onscreen="onScreen" :title="title" @hybridrouterchange="onRouterChange">
      <slot v-if="isMounted"></slot>
    </webf-router-link>
  </template>

  <script>
  import tabBarManager from '@/utils/tabBarManager';

  export default {
    name: 'RouterView',
    props: {
      path: {
        type: String,
        required: true,
      },
      title: {
        type: String
      }
    },
    data() {
      return {
        isMounted: false,
      }
    },
    methods: {
      onScreen() {
        this.isMounted = true;
      },
      onRouterChange(e) {
        // 通知 tabBarManager 路由变化
        console.log('route change', e, e.state);
        tabBarManager.setCurrentPath(this.path);
      }
    }
  }
  </script>