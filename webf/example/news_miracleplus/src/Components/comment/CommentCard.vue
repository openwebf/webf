<template>
    <div class="comment-card">
      <!-- Title -->
      <h2 class="title">{{ item.item.resource.brief }}</h2>
  
      <!-- Description -->
      <p class="description">{{ truncatedContent }}</p>
  
      <!-- Bottom info -->
      <card-bottom-info 
          :userName="item.account.name"
          :createdAt="item.createdAt"
          :viewsCount="item.item.viewsCount"
          :likesCount="item.item.likesCount"
          :commentsCount="item.item.commentsCount"
      />
    </div>
  </template>
  
  <script>
  import CardBottomInfo from '../CardBottomInfo.vue'
  export default {
    name: 'CommentCard',
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
      computedCreatedAt() {
        const now = new Date();
        const createdAt = new Date(this.item.createdAt);
        const diffTime = Math.abs(now - createdAt);
        const diffMinutes = Math.floor(diffTime / (1000 * 60));
        const diffHours = Math.floor(diffTime / (1000 * 60 * 60));
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffHours < 1) {
          return `${diffMinutes}分钟前`;
        } else if (diffDays < 1) {
          return `${diffHours}小时前`;
        } else {
          return `${diffDays}天前`;
        }
      },
      truncatedContent() {
        const content = this.item.item.content || '';
        return content.length > 100 ? content.slice(0, 100) + '...' : content;
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .comment-card {
    background: var(--card-background);
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;
  
    .title {
      font-size: 16px;
      font-weight: bold;
      margin-bottom: 8px;
      color: var(--font-color-primary);
    }
  
    .description {
      font-size: 14px;
      color: var(--font-color-secondary);
      margin-bottom: 12px;
      line-height: 1.5;
    }
  
    .bottom-info {
      display: flex;
      align-items: center;
      font-size: 12px;
      color: var(--secondary-font-color);
  
      .source, .time {
        margin-right: 12px;
      }
  
      .stats {
        display: flex;
  
        span {
          margin-left: 12px;
          display: flex;
          align-items: center;
        }
  
        .icon {
          margin-right: 4px;
        }
      }
    }
  }
  </style>