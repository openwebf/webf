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
  import { parseRichContent, checkIsRichContent } from '@/utils/parseRichContent';
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
        return parseRichContent(this.post.content);
      },
      isRichContent() {
        return checkIsRichContent(this.post.content);
      },
      renderedMarkdown() {
        const md = markdownit()
        const result = md.render(this.post.content || '');
        return result;
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
