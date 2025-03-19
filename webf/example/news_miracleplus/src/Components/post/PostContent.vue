<template>
    <div class="post-content">
      <div class="title">{{ post.title }}</div>
      <div class="content" v-if="isRichContent">
        <div class="content" v-html="formattedContent"></div>
      </div>
      <div class="markdown-wrapper" v-else>
        <div class="markdown-content" v-html="renderedMarkdown"></div>
      </div>
    </div>
  </template>
  
  <script>
  import markdownit from 'markdown-it'
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
      },
      isRichContent() {
        let result = false;
        try {
          JSON.parse(this.post.content);
          result = true;
        } catch (e) {
          result = false;
        }
        return result;
      },
      renderedMarkdown() {
        const md = markdownit()
        const result = md.render(this.post.content || '');
        return result;
      }
    },
    methods: {
      formatContent(content) {
        console.log('content', content);
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