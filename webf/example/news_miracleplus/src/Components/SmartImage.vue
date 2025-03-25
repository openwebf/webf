<template>
    <img 
      v-if="!isSvg" 
      :src="src"
      :width="width"
      :height="height"
      :style="imageStyle"
      :class="$attrs.class"
      @load="$emit('load', $event)"
      @error="$emit('error', $event)"
    >
    <flutter-svg-img
      v-else
      :src="src"
      :width="width"
      :height="height"
      :style="imageStyle"
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
      
      imageStyle() {
        return {
          'object-fit': this.fit,
          'object-position': this.position
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