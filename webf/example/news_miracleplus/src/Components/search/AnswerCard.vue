<template>
  <div class="answer-card">
    <div class="question-title">{{ data.question.title }}</div>
    <div class="content" :numberOfLines="3">{{ parsedContent }}</div>
    <div class="footer">
      <share-link-count 
        :viewsCount="data.viewsCount" 
        :likesCount="data.likesCount" 
        :commentsCount="data.commentsCount" 
      />
    </div>
  </div>
</template>

<script>
import ShareLinkCount from '../ShareLinkCount.vue';
import { parseRichContent } from '@/utils/parseRichContent';
export default {
  name: 'AnswerCard',
  components: {
    ShareLinkCount,
  },
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  computed: {
    parsedContent() {
      const content = parseRichContent(this.data.content);
      return content.length > 100 ? content.substring(0, 100) + '...' : content;
    }
  },
  methods: {
    viewDetail() {
      window.webf.hybridHistory.pushState({
        id: this.data.id
      }, '/answer');
    }
  }
}
</script>

<style lang="scss" scoped>
.answer-card {
  padding: 16px;
  background-color: var(--background-primary);
  border-radius: 8px;
  margin-top: 8px;

  .question-title {
    font-size: 16px;
    font-weight: 500;
    color: var(--font-color-primary);
    margin-bottom: 8px;
  }

  .content {
    font-size: 14px;
    color: var(--font-color-secondary);
    line-height: 20px;
    margin-bottom: 12px;
  }

  .footer {
    flex-direction: row;
    align-items: center;
  }
}
</style>
