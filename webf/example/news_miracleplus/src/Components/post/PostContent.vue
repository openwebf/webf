<template>
    <div class="post-content">
      <div class="title">{{ post.title }}</div>
      <div class="content" v-html="formattedContent"></div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'PostContent',
    props: {
      post: {
        type: Object,
        required: true
      }
    },
    computed: {
      formattedContent() {
        return this.formatContent(this.post.content);
      }
    },
    methods: {
      formatContent(content) {
        try {
          const parsedContent = JSON.parse(content);
          return parsedContent.map(block => {
            if (block.type === 'paragraph') {
              return `<p>${block.children.map(child => child.text).join('')}</p>`;
            }
            return '';
          }).join('');
        } catch (e) {
          return content;
        }
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .post-content {
    margin: 16px 0;
    
    .title {
      font-size: 18px;
      font-weight: bold;
      margin-bottom: 12px;
    }
  }
  </style>