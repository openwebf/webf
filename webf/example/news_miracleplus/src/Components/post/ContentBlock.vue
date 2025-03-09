<template>
    <div v-if="content" class="content-block">
      <div class="block-title">{{ title }}</div>
      <div class="block-content">{{ content }}</div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'ContentBlock',
    props: {
      title: String,
      content: String
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .content-block {
    margin: 16px 0;
    padding: 16px;
    background: #F8F9FA;
    border-radius: 8px;
  
    .block-title {
      font-size: 16px;
      font-weight: 600;
      color: #1C1C1E;
      margin-bottom: 8px;
    }
  
    .block-content {
      font-size: 14px;
      line-height: 1.6;
      color: #3C3C43;
      white-space: pre-wrap;
    }
  }
  </style>