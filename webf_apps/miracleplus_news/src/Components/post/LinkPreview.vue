<template>
    <DisplayContent 
      :item="{
        title: title,
        linkDescription: introduction,
        logoUrl: logoUrl
      }"
      class="link-preview"
    />
  </template>
  
  <script>
  import DisplayContent from '@/Components/DisplayContent.vue';
  
  export default {
    name: 'LinkPreview',
    components: {
      DisplayContent
    },
    props: {
      title: String,
      introduction: String,
      logoUrl: String
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .link-preview {
    margin: 16px 0;
  }
  </style>