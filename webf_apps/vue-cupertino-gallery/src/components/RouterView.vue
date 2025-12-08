<template>
    <webf-router-link :path="path" @onscreen="onScreen" :title="title">
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
      }
    }
  }
  </script>