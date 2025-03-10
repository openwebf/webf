<template>
    <webf-router-link :path="path" @onscreen="onScreen">
      <slot v-if="isMounted"></slot>
    </webf-router-link>
  </template>

  <script>
  export default {
    name: 'RouterView',
    props: {
      path: {
        type: String,
        required: true,
      },
    },
    data() {
      return {
        isMounted: false,
      }
    },
    methods: {
      onScreen() {
        this.isMounted = true;
      }
    }
  }
  </script>