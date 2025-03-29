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
    background: var(--background-secondary);
    border-radius: 8px;
  
    .block-title {
      font-size: 16px;
      font-weight: 600;
      color: var(--font-color-primary);
      margin-bottom: 8px;
    }
  
    .block-content {
      font-size: 14px;
      line-height: 1.6;
      color: var(--font-color-secondary);
      white-space: pre-wrap;
    }
  }
  </style>