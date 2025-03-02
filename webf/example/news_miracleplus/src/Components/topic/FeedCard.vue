<template>
  <div class="feed-card" @click="viewDetail">
      <!-- share link -->
      <template v-if="isShareLink">
          <div class="title">{{ item.item.title }}</div>
          <div class="description">{{ item.item.content }}</div>
          <div class="link-preview" v-if="item.item.logoUrl">
              <img :src="item.item.logoUrl" class="link-logo" />
          </div>
      </template>

      <!-- question -->
      <template v-else-if="isQuestion">
          <div class="title">{{ item.item.title }}</div>
      </template>

      <!-- answer -->
      <template v-else-if="isAnswer">
          <div class="title">{{ item.item.question.title }}</div>
          <div class="description">{{ parsedContent }}</div>
      </template>

      <!-- bottom info -->
      <card-bottom-info 
          :userName="feedType"
          :createdAt="item.createdAt"
          :viewsCount="item.item.viewsCount"
          :likesCount="item.item.likesCount"
          :commentsCount="item.item.commentsCount"
      />
  </div>
</template>

<script>
import CardBottomInfo from '@/Components/CardBottomInfo.vue';
export default {
  name: 'FeedCard',
  components: {
    CardBottomInfo
  },
  props: {
      item: {
          type: Object,
          required: true
      }
  },
  computed: {
      isShareLink() {
          return this.item.actionType === 'topic_new_share_link';
      },
      isQuestion() {
          return this.item.actionType === 'topic_new_question';
      },
      isAnswer() {
          return this.item.actionType === 'topic_new_answer';
      },
      isPinned() {
          return this.item.pinnedAt !== null;
      },
      feedType() {
          switch (this.item.actionType) {
              case 'topic_new_share_link':
                  return '分享';
              case 'topic_new_question':
                  return '问题';
              case 'topic_new_answer':
                  return '回答';
              default:
                  return '';
          }
      },
      userAvatar() {
          return this.item.item.user?.avatar || '';
      },
      parsedContent() {
          try {
              const content = JSON.parse(this.item.item.content);
              const text = content.map(block => {
                  if (block.type === 'paragraph') {
                      return block.children.map(child => child.text).join('');
                  }
                  return '';
              }).join('\n');
              return text.length > 100 ? text.substring(0, 100) + '...' : text;
          } catch (e) {
              return this.item.item.content || '';
          }
      }
  },
  methods: {
      formatTime(time) {
          const date = new Date(time);
          const now = new Date();
          const diff = now - date;
          const minutes = Math.floor(diff / 1000 / 60);
          const hours = Math.floor(minutes / 60);
          const days = Math.floor(hours / 24);
          const months = Math.floor(days / 30);
          const years = Math.floor(months / 12);

          if (minutes < 60) return `${minutes}分钟前`;
          if (hours < 24) return `${hours}小时前`;
          if (days < 30) return `${days}天前`;
          if (months < 12) return `${months}个月前`;
          return `${years}年前`;
      },
      viewDetail() {
          const route = this.isAnswer ? '/answer' : 
                       this.isQuestion ? '/question' : 
                       this.isShareLink ? '/share_link' : '';
          if (route) {
            const params = { id: this.item.item.id };
            if (this.isAnswer) {
              params.questionId = this.item.item.question.id;
            }
            window.webf.hybridHistory.pushState(params, route);
          }
      }
  }
}
</script>

<style lang="scss" scoped>
.feed-card {
  background: var(--background-primary);
  padding: 16px;
  border-bottom: 1px solid var(--border-secondary);

  .top-link {
      color: var(--link-color);
      font-size: 12px;
      margin-bottom: 8px;
  }

  .title {
      font-size: 16px;
      font-weight: 500;
      color: var(--font-color);
      margin-bottom: 8px;
  }

  .question-title {
      font-size: 14px;
      color: var(--secondary-font-color);
      margin-bottom: 8px;
  }

  .description {
      font-size: 15px;
      color: var(--font-color);
      margin-bottom: 12px;
      line-height: 1.5;
  }

  .link-preview {
      margin-bottom: 12px;
      
      .link-logo {
          width: 120px;
          height: 120px;
          border-radius: 4px;
      }
  }
}
</style>