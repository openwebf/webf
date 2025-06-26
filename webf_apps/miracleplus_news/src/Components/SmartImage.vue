<template>
    <img 
      v-if="!isSvg" 
      :src="src"
      :width="width"
      :height="height"
      :style="computedStyle"
      :class="$attrs.class"
      @load="$emit('load', $event)"
      @error="$emit('error', $event)"
    >
    <flutter-svg-img
      v-else
      :src="src"
      :width="width"
      :height="height"
      :style="computedStyle"
      :class="$attrs.class"
      @load="$emit('load', $event)"
      @error="$emit('error', $event)"
    >
    </flutter-svg-img>
  </template>
  
  <script>
  export default {
    name: 'SmartImage',
    inheritAttrs: false,
    props: {
      src: {
        type: String,
        required: true
      },
      width: {
        type: [Number, String],
        default: null
      },
      height: {
        type: [Number, String],
        default: null
      },
      // object-fit
      fit: {
        type: String,
        default: 'contain',
        validator: (value) => ['fill', 'contain', 'cover', 'none', 'scale-down'].includes(value)
      },
      // object-position
      position: {
        type: String,
        default: 'center'
      }
    },
  
    computed: {
      isSvg() {
        return this.src?.toLowerCase().endsWith('.svg')
      },
      
      computedStyle() {
        // 合并基础样式、object-fit/position 和外部传入的样式
        return {
          display: 'inline-block',
          'object-fit': this.fit,
          'object-position': this.position,
          ...(this.$attrs.style || {})  // 合并外部传入的 style
        }
      }
    },
  
    emits: ['load', 'error']
  }
  </script>
  
  <style scoped>
  img, webf-svg-img {
    display: inline-block;
  }
  </style>