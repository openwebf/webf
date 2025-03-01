<template>
  <div class="answer-card">
    <text class="question-title">{{ data.question.title }}</text>
    <text class="content" :numberOfLines="3">{{ parsedContent }}</text>
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
      try {
        const content = JSON.parse(this.data.content);
        const text = content
          .filter(block => block.type === 'paragraph')
          .map(block => block.children.map(child => child.text).join(''))
          .join('\n')
          .trim();
        
        return text.length > 100 ? text.substring(0, 100) + '...' : text;
      } catch (e) {
        return '';
      }
    },
  },
  methods: {
    // TODO: 
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
  background-color: var(--background-color);
  border-radius: 8px;
  margin-top: 8px;

  .question-title {
    font-size: 16px;
    font-weight: 500;
    color: #333333;
    margin-bottom: 8px;
  }

  .content {
    font-size: 14px;
    color: #666666;
    line-height: 20px;
    margin-bottom: 12px;
  }

  .footer {
    flex-direction: row;
    align-items: center;
  }
}
</style>
